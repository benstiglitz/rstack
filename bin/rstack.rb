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

    # push ARGV onto the stack
    vm.exec [:cons, ARGV.dup]

    # read prelude
    prelude_path = File.join(File.dirname(File.dirname(__FILE__)), 'lib', 'prelude.rs')
    prelude = Optimizer.optimize(Lexer.lex(File.read(prelude_path)))

    begin
	vm.exec(prelude)
    rescue Exception => e
	puts "Caught \"#{e}\"\n"
	pp e.backtrace if $DEBUG
    end
end
