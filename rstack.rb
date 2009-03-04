module RStack
    class VM
	def initialize
	    @stack = []
	    @compiling = false
	    @target = []
	    @tokens_stack = []
	end

	def exec(tokens)
	    @tokens_stack.push @tokens
	    @tokens = tokens
	    while @tokens.length > 0
		exec_token @tokens.shift
	    end
	    @tokens = @tokens_stack.pop
	end

	def exec_token(token)
	    if @compiling
		if token == :']'
		    @compiling = false
		    @stack.push @target
		    @target = []
		end
		@target.push token
		return
	    end

	    case token
	    when :num
		@stack.push(@tokens.shift)
	    when :add
		@stack.push(@stack.pop + @stack.pop)
	    when :stack_print
		p @stack
	    when :swap
		@stack[-2, 2] = @stack[-2, 2].reverse
	    when :'['
		@compiling = true
	    when :call
		exec @stack.pop
	    else
		if @stack.length > 0 and @stack[-1].respond_to? token
		    target = @stack.pop
		    arity = target.method(token).arity
		    if arity > 0
			args = @stack[-arity, arity]
			@stack[-arity, arity] = []
			result = target.send(token, *args)
		    else
			result = target.send(token)
		    end
		    @stack.push result unless result.nil?
		else
		    throw "Unknown token #{token}"
		end
	    end
	end
    end

    class Lexer
	def self.lex(input)
	    @tokens = []
	    input.split.each do |token|
		if is_number(token)
		    @tokens += [:num, token.to_i]
		else
		    @tokens << token.to_sym
		end
	    end
	    @tokens
	end

	private
	def self.is_number(token)
	    token.to_i.to_s == token
	end
    end

    class Optimizer
	class ArithmeticOperation
	    def self.===(op)
		return [:+, :-, :*, :/].include?(op)
	    end
	end
	def self.optimize(tokens)
	    token_match(tokens, [:num, Fixnum, :num, Fixnum, ArithmeticOperation]) { |w| [:num, w[3].send(w[4], w[1])] }
	    token_match(tokens, [:num, Fixnum, :num, Fixnum, :swap]) { |w| a = w[1]; w[1] = w[3]; w[3] = a; w[0,4] }
	    tokens
	end

	private
	# token_match([:num, Fixnum, :num, Fixnum])
	def self.token_match(tokens, pattern)
	    return if pattern.length > tokens.length
	    offset = 0

	    while offset <= tokens.length - pattern.length
		window = tokens[offset, pattern.length]
		matched = true
		window.each_with_index do |token, index|
		    unless pattern[index] === token
			matched = false
			break
		    end
		end
		if matched
		    tokens[offset, pattern.length] = yield window
		else
		    offset = offset + 1
		end
	    end
	end
    end
end

if __FILE__ == $0
    include RStack
    VM.new.exec(Optimizer.optimize(Lexer.lex("2 4 + 3 swap / [ stack_print ] call")))
end
