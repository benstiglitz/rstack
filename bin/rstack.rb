#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'lib')
require 'rstack'
require 'pp'

def prompt
    print "rstack> "
    STDIN.gets
end
if __FILE__ == $0
    include RStack
    vm = VM.new

    # read prelude
    unless ARGV.include?('--no-prelude')
	prelude_path = File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'prelude.rs')
	vm.exec(Optimizer.optimize(Lexer.lex(File.read(prelude_path))))
    end

    # start REPL
    while input = prompt
	begin
	    vm.exec(Optimizer.optimize(Lexer.lex(input)))
	    vm.exec([:stack_print])
	rescue Exception => e
	    puts "Caught \"#{e}\"\n"
	    pp e.backtrace if $DEBUG
	end
    end
end
