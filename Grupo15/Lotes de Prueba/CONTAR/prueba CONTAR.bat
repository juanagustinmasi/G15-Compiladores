flex ../Lexico.l
bison -dyv ../sintactico.y
gcc lex.yy.c y.tab.c -o segunda.exe
pause
segunda.exe prueba--CONTAR.txt
del lex.yy.c
del y.tab.c
del y.output
del y.tab.h
pause
