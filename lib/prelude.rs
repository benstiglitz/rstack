:; [ def ] def

( Compiler words )
:lex [ Lexer :lex 1 #f native_call ] ;
:optimize [ Optimizer :optimize 1 #f native_call ] ;
:compile [ lex optimize ] ;

:read [ STDIN :gets 0 #f native_call ] ;
:eval [ compile call ] ;

:print [ Kernel :print 1 #f native_call drop ] ;

:loop [ 9999999999999 :times 0 #t native_call ] ;

:1rep [ "rstack> " print read eval stack_print ] ;
:repl [ [ 1rep ] loop ] ;

"--no-prelude" swap :include? 1 #f native_call [ ] [
    ( start prelude )

    ( end prelude )
] if

repl
