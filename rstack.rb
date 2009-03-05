module RStack
    class VM
	def initialize
	    @stack = []
	    @compiling = false
	    @target = []
	    @tokens_stack = []
	    @tokens = []
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
		else
		    @target.push token
		end
		return
	    end

	    case token
	    when :cons
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
	    when :drop
		if @stack.length > 0
		    @stack.pop
		else
		    throw "Stack underflow"
		end
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
		if is_fixnum(token)
		    @tokens += [:cons, token.to_i]
		elsif is_float(token)
		    @tokens += [:cons, token.to_f]
		elsif is_symbol(token)
		    @tokens += [:cons, token[1, token.length - 1].to_sym]
		elsif is_constant(token)
		    @tokens += [:cons, Kernel.const_get(token)]
		else
		    @tokens << token.to_sym
		end
	    end
	    @tokens
	end

	private
	def self.is_fixnum(token)
	    token.to_i.to_s == token
	end
	def self.is_float(token)
	    token.to_f.to_s == token
	end
	def self.is_symbol(token)
	    token[0] == ":"[0]
	end
	def self.is_constant(token)
	    token[0] >= 65 and token[0] <= 90
	end
    end

    class Optimizer
	class ArithmeticOperation
	    def self.===(op)
		return [:+, :-, :*, :/].include?(op)
	    end
	end
	def self.optimize(tokens)
	    old_tokens = []
	    while tokens != old_tokens
		old_tokens = tokens.dup
		token_match(tokens, 'Constant arithmetic', [:cons, Numeric, :cons, Numeric, ArithmeticOperation]) { |w| [:cons, w[3].send(w[4], w[1])] }
		token_match(tokens, 'Constant swap', [:cons, Object, :cons, Object, :swap]) { |w| a = w[1]; w[1] = w[3]; w[3] = a; w[0,4] }
		token_match(tokens, 'Call hoist', [:'[', Object, :']', :call]) { |w| w[1] }
	    end
	    tokens
	end

	private
	# token_match([:cons, Fixnum, :cons, Fixnum])
	def self.token_match(tokens, pass_name, pattern)
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
		    old_tokens = tokens.dup
		    tokens[offset, pattern.length] = yield window
		    puts "#{pass_name}: #{old_tokens.inspect} -> #{tokens.inspect}" if $DEBUG
		else
		    offset = offset + 1
		end
	    end
	end
    end
end

def prompt
    print "rstack> "
    gets
end
if __FILE__ == $0
    include RStack
    vm = VM.new
    while input = prompt
	vm.exec(Optimizer.optimize(Lexer.lex(input)))
	vm.exec([:stack_print])
    end
end
