module RStack
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

