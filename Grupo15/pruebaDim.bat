flex Lexico.l
bison -dyv sintactico.y
gcc lex.yy.c y.tab.c -o programa.exe
pause
programa.exe pruebadim.txt

del programa.exe