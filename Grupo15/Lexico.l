%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <conio.h>
	#include <string.h>
	#include "y.tab.h"

    #define LIMITE_REAL 2147483647
    #define LIMITE_ENTERO 32768
    #define LIMITE_CADENA 300
    #define LIMITE_ID 30

	int error(char* mensaje);
	int validarLongitudCadena();
	void quitarComillas();

	FILE  *yyin;
	char auxS[100];
	char mensajeDeError[200];
	int finDeclaraciones = 0;

%}

%option noyywrap
%option yylineno

DIGITO 	[0-9]
LETRA 	[a-zA-ZñÑ]
ID		{LETRA}({LETRA}|{DIGITO})*
ENTERO		{DIGITO}+
REAL	{DIGITO}+"."{DIGITO}*|{DIGITO}*"."{DIGITO}+
CUALQUIERA	{LETRA}|{DIGITO}|.
STRING	\"[^"\n]*\"
CARACTER ({DIGITO}|{LETRA}|{CUALQUIERA}|.|_)+
COMENTARIO_I "*-"
COMENTARIO_F "-*"
COMENTARIO_SIMPLE {COMENTARIO_I}({CARACTER}|[\r\n])*{COMENTARIO_F}
COMENTARIO {COMENTARIO_I}({CARACTER}|{COMENTARIO_SIMPLE}|[\r\n])*{COMENTARIO_F}
ESPACIO     " "


%%
 /* Inicio del programa */
 /* Declaracion de palabras reservadas y tokens del programa */

"while"                     { return WHILE;}
"if"						{ return OP_IF;}
"Else"						{ return ELSE;}
"and"						{ return OP_AND;}
"or"						{ return OP_OR;}
"not"						{ return OP_NOT;}
"Float"						{ return TIPO_REAL;}
"Integer"					{ return TIPO_ENTERO;} 
"String"					{ return TIPO_STRING;}
"CONST"						{ return CONST;}
"PUT"						{ return PUT;}
"GET"						{ return GET;}
"DIM"						{ return DIM;}
"AS"						{ return AS;}


 /* Operadores */
":"							{ return ASIG;}
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
"<>"						{ return DISTINTO;}

 /* Otros simbolos */
"("							{ return PA;}
")"							{ return PC;}
"["							{ return CA;}
"]"							{ return CC;}
","							{ return COMA;}
";"							{ return PUNTO_COMA;}
"_"							{ return GUION_BAJO;}
"{"						{ return LLAVE_ABIERTA;}
"}"						{ return LLAVE_CERRADA;}
"="							{ return OP_ASIG_IGUAL;}


 /* Identificadores y constantes */	

{ID}						{
								if(strlen(yytext) <= 30){
									yylval.str_val = strdup(yytext);
									insertarEnTabla(normalizar(yytext), "ID", yytext, "");
									return ID;
								}
								error("intenta limitar tus nombres de variables a 30 caracteres");
							}



	
{REAL}					{
								if(atof(yytext)<=3.40282347e+38F){
									yylval.float_val = atof(yytext);
									insertarEnTabla(normalizar(yytext), "REAL", yytext, "");
									return REAL;
								}
								error("Superaste el tamanio maximo permitido para float");

							}

{ENTERO}					{
								if(atoll(yytext)<=2147483647){
									yylval.int_val = atoi(yytext);
									insertarEnTabla(normalizar(yytext), "ENTERO", yytext, "");
									return ENTERO;
								}
								error("Superaste el tamanio maximo permitido para enteros.");
							} 


{STRING}				{
						if(validarLongitudCadena() == 0) {
								sprintf(mensajeDeError, "Cadena %s excede los %d caracteres de longitud.", yytext, LIMITE_CADENA);
				 				error(mensajeDeError);
							}
							sprintf(auxS,"%s", yytext);
							quitarComillas();
							yylval.str_val=auxS; 
							insertarEnTabla(normalizar(yytext), "STRING", yytext, auxS);
							return STRING;
							}

{ESPACIO}
\n
\t
\r\n
.
%%


int validarLongitudCadena(){
	if((strlen(yytext) - 2) <= LIMITE_CADENA){
		return 1;
	}
	return 0;
}


void quitarComillas() {
	int i = 0;
	while(auxS[i+1] != '\"') {
		auxS[i] = auxS[i+1];
		i++;
	}
	auxS[i] = '\0';
}

char* normalizar(char* cadena)
{
	char *aux = (char *) malloc(sizeof(char) * (strlen(cadena)) + 2);
	strcpy(aux,"_");
	strcat(aux,cadena);
	return aux;
}
