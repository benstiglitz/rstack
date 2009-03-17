#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'lib')
require 'rstack'

def prompt
    print "rstack> "
    gets
end
if __FILE__ == $0
    include RStack
    vm = VM.new
    while input = prompt
	begin
	    vm.exec(Optimizer.optimize(Lexer.lex(input)))
	    vm.exec([:stack_print])
	rescue Exception => e
	    puts "Caught \"#{e}\"\n"
	end
    end
end
