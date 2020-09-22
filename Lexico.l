%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include <string.h>
	#include "y.tab.h"

    #define LIMITE_REAL 2147483647
    #define LIMITE_ENTERO 32768
    #define LIMITE_CADENA 30
    #define LIMITE_ID 30

	int error(char* mensaje);

	FILE  *yyin;
%}

%option noyywrap
%option yylineno

DIGITO 	[0-9]
LETRA 	[a-zA-ZñÑ]
ID		{LETRA}({LETRA}|{DIGITO})*
CTE_INT		{DIGITO}+
CTE_FLOAT	{DIGITO}+"."{DIGITO}*|{DIGITO}*"."{DIGITO}+
CUALQUIERA	{LETRA}|{DIGITO}|.
CTE_STRING	\"{CUALQUIERA}*\"
ESPACIO     " "

%%

{COMENTARIOS}               { (\\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/)|(\/.*)}

"WHILE"                     { return WHILE;}
"CONDITION"                 { return CONDITION;}
"IF"						{ return OP_IF;}
"ELSE"						{ return ELSE;}
"ENDIF"						{ return ENDIF;}
"AND"						{ return OP_AND;}
"OR"						{ return OP_OR;}
"NOT"						{ return OP_NOT;}
"VAR"					    { return VAR;}
"ENDVAR"					{ return ENDVAR;}
"FLOAT"						{ return TIPO_REAL;}
"STRING"					{ return TIPO_CADENA;}
"INT"						{ return TIPO_ENTERO;} 


 /* Operadores */
":="						{ return ASIG;}
"+"							{ return MAS;}
"-"							{ return MENOS;}
"*"							{ return POR;}
"/"							{ return DIVIDIDO;}

 /* Comparadores */
"<"							{ return MENOR;}
">"							{ return MAYOR;}
"<="						{ return MENOR_IGUAL;}
">="						{ return MAYOR_IGUAL;}
"=="						{ return IGUAL;}
"=/="						{ return DISTINTO;}

 /* Otros simbolos */
"("							{ return PA;}
")"							{ return PC;}
"["							{ return CA;}
"]"							{ return CC;}
","							{ return COMA;}
";"							{ return PUNTO_COMA;}
":"							{ return DOS_PUNTOS;}
"\("						{ return PARENTESIS_ABIERTO;}
"\)"						{ return PARENTESIS_CERRADO;}