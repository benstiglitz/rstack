module RStack
    class VM
	def initialize
	    @stack = []
	end

	def exec(tokens)
	    @tokens = tokens
	    while @tokens.length > 0
		exec_token @tokens.shift
	    end
	end

	def exec_token(token)
	    case token
	    when :num
		@stack.push(@tokens.shift)
	    when :add
		@stack.push(@stack.pop + @stack.pop)
	    when :stack_print
		p @stack
	    else
		if @stack.length > 0 and @stack[-1].respond_to? token
		    result = @stack.pop.send(token)
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
		return [:+, :-, :*, :/]
	    end
	end
	def self.optimize(tokens)
	    token_match(tokens, [:num, Fixnum, :num, Fixnum, ArithmeticOperation]) { |w| [:num, w[1].send(w[4], w[3])] }
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
    VM.new.exec(Optimizer.optimize(Lexer.lex("2 4 + 3 / to_f stack_print")))
end
