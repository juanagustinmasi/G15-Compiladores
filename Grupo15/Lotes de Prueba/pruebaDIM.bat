flex ../Lexico.l
bison -dyv ../sintactico.y
gcc lex.yy.c y.tab.c -o programa.exe
pause
programa.exe pruebaDIM.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
del programa.exe
pause
