module RStack
    class Lexer
	def self.lex(input)
	    @comment = false
	    @tokens = []
            input = input.scan(/\".*\"|\S+/)
            until input.empty?
                token = input.shift
                if @comment
		    if token == ')'
			@comment = false
		    end
                elsif token[0] == '"'[0]
                    @tokens += [:cons, token[1, token.length - 2]]
                elsif is_fixnum(token)
		    @tokens += [:cons, token.to_i]
		elsif is_float(token)
		    @tokens += [:cons, token.to_f]
		elsif is_symbol(token)
		    @tokens += [:cons, token[1, token.length - 1].to_sym]
		elsif is_constant(token)
		    @tokens += [:cons, Kernel.const_get(token)]
		elsif is_boolean(token)
		    @tokens += [:cons, token[1] == "t"[0] ? true : false]
		elsif token == '('
		    @comment = true
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
	def self.is_boolean(token)
	    token[0] == "#"[0] and (token[1] == "t"[0] or token[1] == "f"[0])
	end
    end
end
