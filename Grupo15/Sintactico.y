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

#define SIN_MEMORIA 0
#define DATO_DUPLICADO 0
#define TODO_BIEN 1
#define PILA_VACIA 0
#define COLA_VACIA 0
#define TAM_TABLA 300
#define TAM_NOMBRE 100
#define TAM 35
#define TAM_VALOR 100
#define TAM_TIPO 50
#define CAD_MAX 50
#define TAM_LINEA 300
#define TAM_NOMB_LINEA 100

typedef struct
{
	char clave[TAM_NOMBRE];
	char tipodato[TAM_TIPO];
	char valor[TAM_VALOR];
	char longitud[TAM];
} info_t;

typedef struct sNodo
{
			info_t info;
			struct sNodo *sig;
} nodo_t;

typedef nodo_t *lista_t;

typedef struct
	{
		char descripcion[TAM];
		char posicion_a[TAM];
		char posicion_b[TAM];
		char posicion_c[TAM];
	} info_cola_t;

	typedef struct sNodoCola
	{
		info_cola_t info;
		struct sNodoCola *sig;
	} nodo_cola_t;

	typedef struct
	{
		nodo_cola_t *pri, *ult;
	} cola_t;


lista_t l_ts;
info_t d;
cola_t cola_tipo_id;
info_cola_t info_tipo_id;

/* PROTOTIPOS */

void crear_cola(cola_t *c);
int poner_en_cola(cola_t *c, info_cola_t *d);
int sacar_de_cola(cola_t *c, info_cola_t *d);
void crearTabla(lista_t *l_ts);
void clear_ts();
int insertarEnTabla(lista_t *l_ts, info_t *d);
int insertar_en_orden(lista_t *p, info_t *d);
int sacar_repetidos(lista_t *p, info_t *d, int (*cmp)(info_t*d1, info_t*d2), int elimtodos);
//void guardarEnTabla(char* nombre, char* tipo, char* valor, char* longitud);
int buscarEnTabla(char* nombre);
void crear_lista(lista_t *p);
void guardar_lista(lista_t *p, FILE *arch);
int comparar(info_t*d1, info_t*d2);

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
					strcpy(info_tipo_id.descripcion, yyval.str_val);
					poner_en_cola(&cola_tipo_id, &info_tipo_id);
					insertarEnTabla(&l_ts, &d);
					printf("definicion OK\n");
				};



lista_tipo_dato: 

	 lista_tipo_dato COMA TIPO_ENTERO{ printf("lista tipo dato, ENTERO OK\n\n");
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "Integer");
		 insertarEnTabla(&l_ts, &d);}
	
	| lista_tipo_dato COMA TIPO_REAL{ printf("lista tipo dato, REAL OK\n\n");
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "Float");
//		 printf("__%s,%s__",d.clave,d.tipodato);
		 insertarEnTabla(&l_ts, &d);
		}

	| lista_tipo_dato COMA TIPO_STRING{ printf("lista tipo dato, STRING OK\n\n");
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "String");
		 insertarEnTabla(&l_ts, &d);}  
  	|TIPO_ENTERO       
		{
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "Integer");
//		 printf("__%s,%s__",d.clave,d.tipodato);
		 insertarEnTabla(&l_ts, &d);
		printf("TIPO_ENTERO en tipo_variable OK\n");
		}
  	|TIPO_REAL  
		{
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "Float");
		insertarEnTabla(&l_ts, &d);
		printf("TIPO_REAL en tipo_variable OK\n");
		}
	|TIPO_STRING
		{
		 sacar_de_cola(&cola_tipo_id, &info_tipo_id);
		 strcpy(d.clave, info_tipo_id.descripcion);
		 strcpy(d.tipodato, "String");
		insertarEnTabla(&l_ts, &d);
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
		|ENTERO 	 		{printf("factor -> Cte_entera OK\n\n");
							strcpy(d.clave, yytext);
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const Integer");
							insertarEnTabla(&l_ts, &d);
						}
		|REAL 		 		{printf("factor -> Cte_Real OK\n\n");
							strcpy(d.clave, yytext);
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const Real");
							insertarEnTabla(&l_ts, &d);
						}
		|STRING 	 		{printf("factor -> Cte_String OK\n\n");
							strcpy(d.clave, yytext);
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const String");
							insertarEnTabla(&l_ts, &d);
						}
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
	
		clear_ts();
		crear_lista(&l_ts);
		crear_cola(&cola_tipo_id);
		yyparse();
		crearTabla(&l_ts);
	}
	fclose(yyin);
	return 0;
}

void clear_ts() {
	FILE *arch=fopen("ts.txt","w");
	fclose(arch);
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

void crear_cola(cola_t *c) {
	c->pri=NULL;
	c->ult=NULL;
}

int poner_en_cola(cola_t *c, info_cola_t *d) {
	nodo_cola_t *nue=(nodo_cola_t*)malloc(sizeof(nodo_cola_t));

	if(nue==NULL)
		return SIN_MEMORIA;

	nue->info=*d;
	nue->sig=NULL;
	if(c->ult==NULL)
		c->pri=nue;
	else
		c->ult->sig=nue;

	c->ult=nue;

	return TODO_BIEN;
}

int sacar_de_cola(cola_t *c, info_cola_t *d) {
	nodo_cola_t *aux;

	if(c->pri==NULL)
		return COLA_VACIA;

	aux=c->pri;
	*d=aux->info;
	c->pri=aux->sig;
	free(aux);

	if(c->pri==NULL)
		c->ult=NULL;

	return TODO_BIEN;
}

void crear_lista(lista_t *p) {
    *p=NULL;
}

void crearTabla(lista_t *p) {
	info_t aux;
	FILE *arch=fopen("tablaSimbolos.txt","w");
	printf("\n");
	printf("creando tabla de simbolos...\n");
	guardar_lista(p, arch);
	fclose(arch);
	printf("tabla de simbolos creada\n");
}

int insertarEnTabla(lista_t *l_ts, info_t *d) {
	insertar_en_orden(l_ts,d);
	sacar_repetidos(l_ts,d,comparar,0);
	strcpy(d->clave,"\0");
	strcpy(d->tipodato,"\0");
	strcpy(d->valor,"\0");
	strcpy(d->longitud,"\0");
}

int insertar_en_orden(lista_t *p, info_t *d) {
	nodo_t*nue;
	while(*p && comparar(&(*p)->info,d)>0)
			p=&(*p)->sig;

	if(*p && (((*p)->info.clave)-(d->clave))==0) {
		(*p)->info=(*d);
		return DATO_DUPLICADO;
	}

	nue=(nodo_t*)malloc(sizeof(nodo_t));
	if(nue==NULL)
			return SIN_MEMORIA;

	nue->info=*d;
	nue->sig=*p;
	*p=nue;
	return TODO_BIEN;
}

int sacar_repetidos(lista_t *p, info_t *d, int (*cmp)(info_t*d1, info_t*d2), int elimtodos) {
	nodo_t*aux;
	lista_t*q;

	while(*p) {
		q=&(*p)->sig;
		while(*p && *q) {
			if(cmp(&(*p)->info,&(*q)->info)==0) {
				aux=*q;
				*q=aux->sig;
				free(aux);
			} else
				q=&(*q)->sig;
		}
		p=&(*p)->sig;
	}

	return TODO_BIEN;
}

void guardar_lista(lista_t *p, FILE *arch) {
	// titulos
	fprintf(arch,"%-35s %-16s %-35s %-35s", "NOMBRE", "TIPO DE DATO", "VALOR", "LONGITUD");	
	// datos
	while(*p) {
		printf("\n%s %s %s %s\n", (*p)->info.clave, (*p)->info.tipodato, (*p)->info.valor, (*p)->info.longitud);
		fprintf(arch,"\n%-35s %-16s %-35s %-35s", (*p)->info.clave, (*p)->info.tipodato, (*p)->info.valor, (*p)->info.longitud);
		p=&(*p)->sig;
	}

}

int comparar(info_t *d1, info_t *d2) {
	return strcmp(d1->clave,d2->clave);
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