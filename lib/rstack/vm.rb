module RStack
    class VM
	def define_primitive(token, &block)
	    @dictionary[token] = Proc.new
	end

	def initialize
	    @stack = []
	    @compiling = false
	    @target = []
	    @tokens_stack = []
	    @tokens = []

	    @dictionary = {}
	    define_primitive :cons do
		@stack.push(@tokens.shift)
	    end
	    define_primitive :add do
		@stack.push(@stack.pop + @stack.pop)
	    end
	    define_primitive :stack_print do
		p @stack
	    end
	    define_primitive :swap do
		@stack[-2, 2] = @stack[-2, 2].reverse
	    end
	    define_primitive :'[' do
		@compiling = true
	    end
	    define_primitive :call do
		exec @stack.pop
	    end
	    define_primitive :drop do
		if @stack.length > 0
		    @stack.pop
		else
		    throw "Stack underflow"
		end
	    end
	    define_primitive :def do
		args = @stack.pop
		name = @stack.pop
		vm = self
		meth = Proc.new { vm.exec(args) }
		@dictionary[name] = meth
	    end
	    define_primitive :over do
		if @stack.length > 1
		    @stack.push @stack[-2]
		else
		    throw "Stack underflow"
		end
	    end
	    define_primitive :rot do
		if @stack.length > 2
		    substack = @stack[-3, 3]
		    substack.push substack.shift
		    @stack[-3, 3] = substack
		else
		    throw "Stack underflow"
		end
	    end
	    define_primitive :native_call do
		arity = @stack.pop
		message = @stack.pop
		receiver = @stack.pop
		args = []
		arity.times do
		    args.unshift @stack.pop
		end
		result = receiver.send(message, *args)
		@stack.push result
	    end
	end

	def exec(tokens)
	    @tokens_stack.push @tokens
	    @tokens = tokens.dup
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

	    if @dictionary[token]
		@dictionary[token].call
	    elsif @stack.length > 0 and @stack[-1].respond_to? token
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
