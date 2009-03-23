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
	    nil
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
	    when :def
		args = @stack.pop
		name = @stack.pop
		vm = self
		meth = Proc.new { vm.exec(args) }
		Object.instance_eval { define_method(name, meth) }
	    when :over
		if @stack.length > 1
		    @stack.push @stack[-2]
		else
		    throw "Stack underflow"
		end
	    when :rot
		if @stack.length > 2
		    substack = @stack[-3, 3]
		    substack.push substack.shift
		    @stack[-3, 3] = substack
		else
		    throw "Stack underflow"
		end
	    when :"<native-call>"
		arity = @stack.pop
		message = @stack.pop
		receiver = @stack.pop
		args = []
		arity.times do
		    args.unshift @stack.pop
		end
		result = receiver.send(message, *args)
		@stack.push result
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
end
