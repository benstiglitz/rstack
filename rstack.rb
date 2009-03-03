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
		throw "Unknown token"
	    end
	end
    end
end

if __FILE__ == $0
    RStack::VM.new.exec([:num, 2, :num, 4, :add, :stack_print])
end
