%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include <string.h>
#include <ctype.h>

FILE  *yyin;
char *yyltext;
char *yytext;

/* Funciones necesarias */
int yylex();
int yyerror();
void error(char *mensaje);

/* -------- TABLA DE SIMBOLOS -------- */

#define TAM_TABLA 300
#define TAM_NOMBRE 100
#define TAM_VALOR 100
#define TAM_TIPO 50
#define CAD_MAX 50
#define TAM_LINEA 300
#define TAM_NOMB_LINEA 100

typedef struct
{
	char nombre [TAM_NOMBRE];
	char tipo  [TAM_TIPO];
	char valor [TAM_VALOR];
	int longitud;
} structTablaS;

structTablaS tablaSimbolos[TAM_TABLA];

/* PROTOTIPOS */

void crearTabla();
void insertarEnTabla(char*, char*, char*, char*);
void guardarEnTabla(char* nombre, char* tipo, char* valor, char* longitud);
int buscarEnTabla(char* nombre);

/* VARIABLES */

int cantTokens = 0;
int constantes = 0;
int i = 0;



%}

%union {
	int int_val;
	double float_val;
	char *str_val;
}


%start start_programa

/* Lista de Tokens */

%token WHILE
OP_IF
ELSE
OP_AND
OP_OR
OP_NOT
TIPO_REAL
TIPO_ENTERO
TIPO_STRING
CONST
PUT
GET
ASIG
MAS
MENOS
POR
DIVIDIDO
MENOR
MAYOR
MENOR_IGUAL
MAYOR_IGUAL
IGUAL
DISTINTO
PA
PC
CA
CC
COMA
PUNTO_COMA
DOS_PUNTOS
CTE_STRING
CTE_FLOAT
CTE_INT
DIM
AS
ESPACIO
GUION_BAJO
LLAVE_ABIERTA
LLAVE_CERRADA
REAL
ENTERO
ID
STRING
OP_ASIG_IGUAL
CONTAR
CUALQUIERA
NOT
%%

start_programa : 
		programa
            { printf("\n Compilacion exitosa\n");};



programa : 
		bloque_declaracion  bloque_programa
        	{ printf("Programa OK\n\n");};

bloque_declaracion: 
		 DIM MENOR lista_definiciones MAYOR AS MENOR lista_tipo_dato MAYOR
                     { printf("bloque_definiciones OK\n");};


lista_definiciones: 
		lista_definiciones COMA definicion 
                {printf("lista_definiciones definicion OK\n");} 
        | definicion 
                { printf("lista_definiciones->definicion OK\n");}


definicion: 
		ID 
                {   printf("%s\n", yylval.str_val);
					printf("definicion OK\n");
				};



lista_tipo_dato: 

	 lista_tipo_dato COMA TIPO_ENTERO{ printf("lista tipo dato, ENTERO OK\n\n");}
	
	| lista_tipo_dato COMA TIPO_REAL{ printf("lista tipo dato, REAL OK\n\n");} 
	| lista_tipo_dato COMA TIPO_STRING{ printf("lista tipo dato, STRING OK\n\n");} 
  	|TIPO_ENTERO       
		{
		printf("TIPO_ENTERO en tipo_variable OK\n");
		}
  	|TIPO_REAL 
		{
		printf("TIPO_REAL en tipo_variable OK\n");
		}
	|TIPO_STRING
		{
			printf("TIPO_STRING en tipo_variable OK \n");
		}	



bloque_programa : 
		bloque_programa sentencia 
        	{printf("bloque_programa -> bloque_programa sentencia OK \n\n");}
        | sentencia 
            {printf("bloque_programa -> sentencia OK \n\n");}
		| LLAVE_ABIERTA sentencia LLAVE_CERRADA 		{printf("bloque_programa -> {sentencia } OK \n\n");}
		| LLAVE_ABIERTA bloque_programa sentencia LLAVE_CERRADA {printf("bloque_programa -> {bloque_programa sentencia} OK \n\n");}
sentencia : 
		asignacion 				{printf("sentencia -> asignacion OK \n\n");}
		| bloque_condicional	{printf("sentencia -> bloque_condicional OK \n\n");} 
		| bloque_iteracion 		{printf("sentencia -> bloque_iteracion OK \n\n");}
		| entrada_datos			{printf("sentencia -> entrada_datos OK \n\n");}
		| salida_datos			{printf("sentencia -> salida_datos OK \n\n");}
		

entrada_datos: 
		GET ID PUNTO_COMA 
			{printf("GET ID -> OK \n\n");}

salida_datos: 
		PUT STRING PUNTO_COMA 
			{printf("PRINT CADENA OK \n\n");}
		| PUT ID  PUNTO_COMA
			{printf("PRINT ID OK\n\n");}
		| PUT CA TIPO_STRING CC PUNTO_COMA
			{printf("PRINT CUALQUIER TEXTO OK\n");}
			
			
		

bloque_iteracion:
		 WHILE condicion LLAVE_ABIERTA bloque_programa LLAVE_CERRADA
		   {printf("bloque WHILE -> OK\n\n");}

asignacion:
		 	 ID ASIG expresion PUNTO_COMA 				{printf("asignacion OK \n\n");}
			|CONST ID OP_ASIG_IGUAL ENTERO PUNTO_COMA 	{ printf("CONST ID = ENTERO; -> OK\n\n");}
			|CONST ID OP_ASIG_IGUAL REAL PUNTO_COMA 	{ printf("CONST ID = REAL; -> OK\n\n");}
			|CONST ID OP_ASIG_IGUAL STRING PUNTO_COMA 	{ printf("CONST ID = STRING; -> OK\n\n");}
			|ID OP_ASIG_IGUAL STRING PUNTO_COMA			{ printf(" ID = STRING; -> OK\n\n");}

expresion:
		expresion MAS termino  		{printf("expresion -> exp + term OK \n\n");}
		| expresion MENOS termino   {printf("expresion -> exp - term OK \n\n");}
		| termino					{printf("expresion ->term OK \n\n");}

termino: 
		termino POR factor 			{printf("term -> term * factor OK \n\n");}
		| termino DIVIDIDO factor   {printf("term -> term / factor OK \n\n");}
		| factor					{printf("term -> factor OK \n\n");}

factor: ID 				 	{printf("factor -> ID OK\n\n");}
		|ENTERO 	 		{printf("factor -> Cte_entera OK\n\n");}
		|REAL 		 		{printf("factor -> Cte_Real OK\n\n");}
		|STRING 	 		{printf("factor -> Cte_String OK\n\n");}
		|PA expresion PC 	{printf("factor -> ( expresion ) OK\n\n");}
		|funcion_contar 	{printf("funcion_contar -> contar OK \n\n");}


funcion_contar:
		CONTAR PA expresion PUNTO_COMA CA lista_expresiones CC PC {printf("Funcion contar -> OK");}

lista_expresiones:
		lista_expresiones COMA expresion { printf("expresion -> expresion , expresion OK\n\n");}
		|expresion	{printf("expresion -> expresion OK\n\n");}


bloque_condicional: 
				bloque_if 
					{printf("bloque_condicional\n");}

bloque_if: 
		OP_IF condicion  bloque_programa  { printf("Condicion OK\n\n");} 
		| OP_IF condicion   bloque_programa  ELSE  bloque_programa  {printf("Condicion con Else OK \n\n");}

condicion:
		 PA comparacion OP_AND comparacion PC {printf("Comparacion And OK\n\n");}
		| PA comparacion OP_OR comparacion PC {printf("Comparacion OR OK\n\n");}
		| PA OP_NOT condicion PC			  {printf("Comparacion NOT OK\n\n");} 	
		| PA comparacion PC 				  {printf("Comparacion -> OK\n\n");}	
			
comparacion : 
		expresion MAYOR expresion			{printf("mayor  OK \n\n");}
		| expresion MENOR expresion			{printf("menor OK \n\n");}
		| expresion MAYOR_IGUAL expresion 	{printf("mayor igual OK \n\n");}
		| expresion MENOR_IGUAL expresion	{printf("menor igual OK \n\n");}
		|expresion IGUAL expresion			{printf("igual OK \n\n");}
		|expresion DISTINTO expresion		{printf("distinto OK \n\n");}
			

%%

int main(int argc,char *argv[]){

	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}else {
		
		yyparse();
		crearTabla();
	}
	fclose(yyin);
	return 0;
}

void error(char *mensaje) {
	printf("%s\n", mensaje);
	yyerror();
}

int yyerror(void){
	printf("ERROR EN COMPILACION.\n");
	system ("Pause");
	exit (1);
}

void crearTabla(){
	if(cantTokens == -1)
	yyerror();

	FILE* arch = fopen("tablaSimbolos.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo tablaSimbolos.txt\n");
		return;
	}

	fprintf(arch,"%-15s%-10s%-15s%-10s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	fprintf(arch, "\n");

	fclose(arch);
}

void insertarEnTabla(char* nombre, char* tipo, char* valor, char* longitud){
	if (buscarEnTabla(nombre) == 1)
	{
		guardarEnTabla(nombre, tipo, valor, longitud);
	}
}

void guardarEnTabla(char* nombre, char* tipo, char* valor, char* longitud)
{
    FILE *arch = fopen("tablaSimbolos.txt", "r+");
    if (!arch)
    {
        arch = fopen("tablaSimbolos.txt", "w+");
        crearTabla(arch);
        fprintf(arch, "%-15s%-10s%-15s%-10d\n", &(tablaSimbolos[i].nombre), &(tablaSimbolos[i].tipo) , &(tablaSimbolos[i].valor), tablaSimbolos[i].longitud);
        fclose(arch);
    }
    else
    {
    	fprintf(arch, "%-15s%-10s%-15s%-10d\n", &(tablaSimbolos[i].nombre), &(tablaSimbolos[i].tipo) , &(tablaSimbolos[i].valor), tablaSimbolos[i].longitud);

        fclose(arch);
    }
}

int buscarEnTabla(char* nombre){
	char linea[TAM_LINEA],
		nombreLinea[TAM_NOMB_LINEA];

	FILE *arch = fopen("tablaSimbolos.txt", "r");
    if(arch!= NULL)
	{
		while(fgets(linea,sizeof(linea),arch))
		{

			if(strcmp(nombreLinea, nombre) == 0){
				fclose(arch);
				return 1;
			} else {
				return 0;
			}
		}
	}
	fclose(arch);
	return 0;
}