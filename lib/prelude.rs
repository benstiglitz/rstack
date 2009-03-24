:; [ def ] def

( Compiler words )
:lex [ Lexer :lex 1 native_call ] ;
:optimize [ Optimizer :optimize 1 native_call ] ;
:compile [ lex optimize ] ;
:eval [ compile call ] ;
