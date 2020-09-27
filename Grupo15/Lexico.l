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
DIM			^<({CTE_STRING}|{LETRA})(\,{CTE_STRING}|{LETRA})*>$
AS			^<({CTE_STRING})(\,{CTE_STRING})*>$

%%

CARACTER ({DIGITO}|{LETRA}|{SIMBOLO}|.|_)+
COMENTARIO_I "*-"
COMENTARIO_F "-*"
COMENTARIO_SIMPLE {COMENTARIO_I}({CARACTER}|[\r\n])*{COMENTARIO_F}
COMENTARIO {COMENTARIO_I}({CARACTER}|{COMENTARIO_SIMPLE}|[\r\n])*{COMENTARIO_F}


"WHILE"                     { return WHILE;}
"ENDWHILE"                  { return ENDWHILE;}
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
"CONST"						{ return CONST;}
"PUT"						{ return PRINT;}
"GET"						{ return SCAN;}



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


{CTE_STRING}				{
							 if( strlen(yytext) <= 30 + 2){
									int length = strlen(yytext-1); //saco 1 comilla
									char nombre_cte[length];
									strcpy(nombre_cte, yytext+1); //Copio salteando la primera comilla
									strcpy(nombre_cte + strlen(nombre_cte) - 1, "\0"); //Sobrescribo la ultima comilla con \0
									strcpy(yylval.string_val, nombre_cte);
									return CTE_STRING;
								}
								error("Maximo permitido de string 30 caracteres");
							}

	
{CTE_FLOAT}					{
								if(atof(yytext)<=3.40282347e+38F){
									yylval.float_val = atof(yytext);
									return CTE_FLOAT;
								}
								error("Superaste el tamanio maximo permitido para float");

							}

{CTE_INT}					{
								if(atoll(yytext)<=2147483647){
									yylval.int_val = atoi(yytext);
									return CTE_INT;
								}
								error("Superaste el tamanio maximo permitido para enteros.");
							}

{ID}						{
								if(strlen(yytext) <= 30){
									yylval.string_val = strdup(yytext);
									return ID;
								}
								error("intenta limitar tus nombres de variables a 30 caracteres. Dale, soy generoso.");
							}


{DIM}						{

							}


{ESPACIO}
\n
\t
\r\n
.

%%


int error(char* mensaje)
{
	printf("Error lexico: %s\n", mensaje);
	system ("Pause");
	exit (1);
}


int yyerror(char* mensaje)
 {
	printf("Syntax Error [linea %d]: %s\n", yylineno, mensaje);
	system ("Pause");
	exit (1);
 }
