:; [ def ] def

( Compiler words )
:lex [ Lexer :lex 1 #f native_call ] ;
:optimize [ Optimizer :optimize 1 #f native_call ] ;
:compile [ lex optimize ] ;
:eval [ compile call ] ;
