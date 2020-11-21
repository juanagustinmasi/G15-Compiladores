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
#define NUMERO_INICIAL_TERCETO 10
#define __CONTAR_CONTADOR "__CONTAR_CONTADOR"

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

typedef struct
	{
		char descripcion[TAM];
		int numero_terceto;
	} info_pila_t;

	typedef struct sNodoPila
	{
		info_pila_t info;
		struct sNodoPila *sig;
	} nodo_pila_t;
	
	typedef nodo_pila_t *pila_t;

lista_t l_ts;
info_t d;
cola_t cola_tipo_id;
info_cola_t info_tipo_id;
cola_t cola_terceto;
info_cola_t info_terceto_get;
info_cola_t info_terceto_put;
info_cola_t info_terceto_factor;
info_cola_t info_terceto_asig;
info_cola_t info_terceto_termino;
info_cola_t info_terceto_expresion;
info_cola_t terceto_if;
info_cola_t terceto_cmp;
info_cola_t terceto_contar;

info_cola_t	terceto_operador_logico;
pila_t comparaciones;
info_pila_t comparador;
info_pila_t comparacion;
pila_t saltos_incondicionales;
info_pila_t salto_incondicional;
info_pila_t saltos;
info_pila_t salto;
pila_t pila_saltos;
pila_t comparaciones_or;
info_pila_t comparacion_or;
pila_t comparaciones_and;
info_pila_t comparacion_and;


/* PROTOTIPOS */
char *guion_cadena(char cad[TAM]);
char * charReplace(char * str, char caracter, char nuevo_caracter);
void crear_cola(cola_t *c);
int poner_en_cola(cola_t *c, info_cola_t *d);
int sacar_de_cola(cola_t *c, info_cola_t *d);
void crearTabla(lista_t *l_ts);
void clear_ts();
int insertarEnTabla(lista_t *l_ts, info_t *d);
int insertar_en_orden(lista_t *p, info_t *d);
int sacar_repetidos(lista_t *p, info_t *d, int (*cmp)(info_t*d1, info_t*d2), int elimtodos);
int buscarEnTabla(char* nombre);
void crear_lista(lista_t *p);
void guardar_lista(lista_t *p, FILE *arch);
int comparar(info_t*d1, info_t*d2);
char *invertirOperadorLogico(char *operador_logico);
int crearTerceto(info_cola_t *info_terceto);
void leerTerceto(int numero_terceto, info_cola_t *info_terceto_output);
void modificarTerceto(int numero_terceto, info_cola_t *info_terceto_input);
char *normalizarPunteroTerceto(int terceto_puntero);
void clear_intermedia();
void crear_intermedia(cola_t *cola_intermedia);
void guardar_intermedia(cola_t *p, FILE *arch);
void crear_pila(pila_t *p);
int poner_en_pila(pila_t *p, info_pila_t *d);
int sacar_de_pila(pila_t*p, info_pila_t *d);

/* VARIABLES */

int cantTokens = 0;
int constantes = 0;
int i = 0;
int numero_terceto = NUMERO_INICIAL_TERCETO;
int cant_total_tercetos=0;
int numero_terceto_if;
char cadena[TAM+1];
char char_puntero_terceto[TAM];
int p_terceto_expresion;
int p_terceto_termino;
int p_terceto_factor;
int p_terceto_if;
int p_terceto_contar;
int p_contar_pivot;
int p_contar;

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
        	{ printf("Programa OK\n\n");}
			


bloque_declaracion: 
		 declaracion						{ printf("declaracion OK\n");}
		 | bloque_declaracion declaracion 	{ printf("bloque declaracion, declaracion OK\n");} 
		 
		 
declaracion:
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
		 strcpy(d.valor, yylval.str_val);
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
		 strcpy(d.valor, yylval.str_val);
		insertarEnTabla(&l_ts, &d);
		printf("TIPO_STRING en tipo_variable OK \n");
		}	



bloque_programa : 
		bloque_programa sentencia 
        	{printf("bloque_programa -> bloque_programa sentencia OK \n\n");}
		 
        | sentencia 
            {printf("bloque_programa -> sentencia OK \n\n");}
		/* | LLAVE_ABIERTA sentencia LLAVE_CERRADA 		{			
																	//saltos.numero_terceto=numero_terceto;
																	//poner_en_pila(&comparaciones,&comparacion);
																	//printf("___%d___",saltos.numero_terceto);
																	printf("bloque_programa -> {sentencia } OK \n\n");}
		| LLAVE_ABIERTA bloque_programa sentencia LLAVE_CERRADA {	//saltos.numero_terceto=numero_terceto;
																	//poner_en_pila(&comparaciones,&comparacion);
																	//printf("___%d___",saltos.numero_terceto);
																	printf("bloque_programa -> {bloque_programa sentencia} OK \n\n");}
 */
sentencia : 
		asignacion 				{printf("sentencia -> asignacion OK \n\n");}
		| bloque_condicional	{printf("sentencia -> bloque_condicional OK \n\n");} 
		| bloque_iteracion 		{printf("sentencia -> bloque_iteracion OK \n\n");}
		| entrada_datos			{printf("sentencia -> entrada_datos OK \n\n");}
		| salida_datos			{printf("sentencia -> salida_datos OK \n\n");}
		| funcion_contar 		{printf("sentencia -> contar OK \n\n");}
entrada_datos: 
		GET ID PUNTO_COMA 
			{printf("GET ID -> OK \n\n");
			strcpy(info_terceto_get.posicion_a, "GET");
			strcpy(info_terceto_get.posicion_b, yylval.str_val);
			strcpy(info_terceto_get.posicion_c, "_");
			crearTerceto(&info_terceto_get);}

salida_datos: 
		PUT STRING  
			{printf("PRINT CADENA OK \n\n");
			strcpy(info_terceto_put.posicion_a, "PUT");
			printf("CADENA: __%s__",yytext);
			strcpy(info_terceto_put.posicion_b, yytext);
			strcpy(info_terceto_put.posicion_c, "_");
			crearTerceto(&info_terceto_put);
			strcpy(d.clave, guion_cadena(charReplace(yytext, ' ', '_')));
			strcpy(d.valor, yytext);
			strcpy(d.tipodato, "const String");
			sprintf(d.longitud, "%d", strlen(yytext)-2);
			insertarEnTabla(&l_ts, &d);
			}PUNTO_COMA{}
		| PUT ID  PUNTO_COMA
			{printf("PRINT ID OK\n\n");
			strcpy(info_terceto_put.posicion_a, "PUT");
			strcpy(info_terceto_put.posicion_b, yylval.str_val);
			strcpy(info_terceto_put.posicion_c, "_");
			crearTerceto(&info_terceto_put);}
		| PUT CA TIPO_STRING CC PUNTO_COMA
			{printf("PRINT CUALQUIER TEXTO OK\n");
			strcpy(info_terceto_put.posicion_a, "PUT");
			strcpy(info_terceto_put.posicion_b, yylval.str_val);
			strcpy(info_terceto_put.posicion_c, "_");
			crearTerceto(&info_terceto_put);}
		
		

bloque_iteracion:
		 WHILE condicion LLAVE_ABIERTA bloque_programa LLAVE_CERRADA
		   {printf("bloque WHILE -> OK\n\n");}

asignacion:
		 	ID {		
				strcpy(info_terceto_asig.posicion_b, yylval.str_val);
			  } ASIG{
				strcpy(info_terceto_asig.posicion_a, yytext);
			  } expresion PUNTO_COMA{
				strcpy(info_terceto_asig.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
				crearTerceto(&info_terceto_asig);
			  	printf("asignacion OK \n\n");}

			|CONST ID OP_ASIG_IGUAL {
												strcpy(info_terceto_asig.posicion_b, $<str_val>2);
			} ENTERO  	{ 
													strcpy(info_terceto_asig.posicion_a, "=");
													strcpy(info_terceto_asig.posicion_c, yytext);
													crearTerceto(&info_terceto_asig);
														printf("CONST ID = ENTERO; -> OK\n\n");
															}
			PUNTO_COMA{};
			|CONST ID OP_ASIG_IGUAL {
												strcpy(info_terceto_asig.posicion_b, $<str_val>2);
			} REAL 	{ 
											   strcpy(info_terceto_asig.posicion_a, "=");
											   strcpy(info_terceto_asig.posicion_c, yytext);
											   crearTerceto(&info_terceto_asig);
											   printf("CONST ID = REAL; -> OK\n\n");}
			PUNTO_COMA{};
			|CONST ID OP_ASIG_IGUAL {
												strcpy(info_terceto_asig.posicion_b, $<str_val>2);
			}STRING  	{ 
												strcpy(info_terceto_asig.posicion_a, "=");
												strcpy(info_terceto_asig.posicion_c, yytext);
												crearTerceto(&info_terceto_asig);
												strcpy(d.clave, guion_cadena(charReplace(yytext, ' ', '_')));
												strcpy(d.valor, yytext);
												strcpy(d.tipodato, "const String");
												sprintf(d.longitud, "%d", strlen(yytext)-2);
												insertarEnTabla(&l_ts, &d);
												printf("CONST ID = STRING; -> OK\n\n");}
			PUNTO_COMA{};
			|ID OP_ASIG_IGUAL {
												strcpy(info_terceto_asig.posicion_b, $<str_val>2);
			}STRING 	{ 
				
												strcpy(info_terceto_asig.posicion_a, "=");
												strcpy(info_terceto_asig.posicion_c, yytext);
												crearTerceto(&info_terceto_asig);
												strcpy(d.clave, guion_cadena(charReplace(yytext, ' ', '_')));
												strcpy(d.valor, yytext);
												strcpy(d.tipodato, "const String");
												sprintf(d.longitud, "%d", strlen(yytext)-2);
												insertarEnTabla(&l_ts, &d);
												printf(" ID = STRING; -> OK\n\n");}
			PUNTO_COMA{};

expresion:
		expresion MAS termino  		{printf("expresion -> exp + term OK \n\n");
									strcpy(info_terceto_expresion.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
									strcpy(info_terceto_expresion.posicion_a, "+");
									strcpy(info_terceto_expresion.posicion_c, normalizarPunteroTerceto(p_terceto_termino));
									p_terceto_expresion = crearTerceto(&info_terceto_expresion);}
		| expresion MENOS termino   {printf("expresion -> exp - term OK \n\n");
									strcpy(info_terceto_expresion.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
									strcpy(info_terceto_expresion.posicion_a, "-");
									strcpy(info_terceto_expresion.posicion_c, normalizarPunteroTerceto(p_terceto_termino));
									p_terceto_expresion = crearTerceto(&info_terceto_expresion);}
		| termino					{printf("expresion ->term OK \n\n");
									p_terceto_expresion = p_terceto_termino;}

termino: 
		termino POR factor 			{printf("term -> term * factor OK \n\n");
									strcpy(info_terceto_termino.posicion_b, normalizarPunteroTerceto(p_terceto_termino));
									strcpy(info_terceto_termino.posicion_a, "*");
									strcpy(info_terceto_termino.posicion_c, normalizarPunteroTerceto(p_terceto_factor));
									p_terceto_termino = crearTerceto(&info_terceto_termino);}
		| termino DIVIDIDO factor   {printf("term -> term / factor OK \n\n");
									strcpy(info_terceto_termino.posicion_b, normalizarPunteroTerceto(p_terceto_termino));
									strcpy(info_terceto_termino.posicion_a, "/");
									strcpy(info_terceto_termino.posicion_c, normalizarPunteroTerceto(p_terceto_factor));
									p_terceto_termino = crearTerceto(&info_terceto_termino);}
		| factor					{printf("term -> factor OK \n\n");
									p_terceto_termino = p_terceto_factor;}

factor: ID 				 	{printf("factor -> ID OK\n\n");
							strcpy(info_terceto_factor.posicion_a, yytext);
							strcpy(info_terceto_factor.posicion_b, "_");
							strcpy(info_terceto_factor.posicion_c, "_");
							p_terceto_factor = crearTerceto(&info_terceto_factor);}
		|ENTERO 	 		{printf("factor -> Cte_entera OK\n\n");
							strcpy(info_terceto_factor.posicion_a, yytext);
							strcpy(info_terceto_factor.posicion_b, "_");
							strcpy(info_terceto_factor.posicion_c, "_");
							p_terceto_factor = crearTerceto(&info_terceto_factor);
							strcpy(d.clave,guion_cadena(yytext));
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const Integer");
							insertarEnTabla(&l_ts, &d);
						}
		|REAL 		 		{printf("factor -> Cte_Real OK\n\n");
							strcpy(info_terceto_factor.posicion_a, yytext);
							strcpy(info_terceto_factor.posicion_b, "_");
							strcpy(info_terceto_factor.posicion_c, "_");
							p_terceto_factor = crearTerceto(&info_terceto_factor);
							strcpy(d.clave, guion_cadena(yytext));
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const Real");
							insertarEnTabla(&l_ts, &d);
						}
		|STRING 	 		{printf("factor -> Cte_String OK\n\n");
							strcpy(info_terceto_factor.posicion_a, yytext);
							strcpy(info_terceto_factor.posicion_b, "_");
							strcpy(info_terceto_factor.posicion_c, "_");
							p_terceto_factor = crearTerceto(&info_terceto_factor);
							strcpy(d.clave, guion_cadena(charReplace(yytext, ' ', '_')));
							strcpy(d.valor, yytext);
							strcpy(d.tipodato, "const String");
							sprintf(d.longitud, "%d", strlen(yytext)-2);
							insertarEnTabla(&l_ts, &d);
						}
		|PA expresion PC 	{
							printf("factor -> ( expresion ) OK\n\n");
							p_terceto_factor = p_terceto_expresion;
							}
		|funcion_contar 	{
							printf("funcion_contar -> contar OK \n\n");
							strcpy(info_terceto_factor.posicion_a, "__CONTAR_CONTADOR");
							strcpy(info_terceto_factor.posicion_b, "_");
							strcpy(info_terceto_factor.posicion_c, "_");
							
							p_terceto_factor = p_terceto_contar;
							}


funcion_contar:
		CONTAR {
			// si el ID está en las lista "__IGUALES_RETURN" suma 1, si no suma 0
			strcpy(d.clave, __CONTAR_CONTADOR);
			strcpy(d.tipodato, "Integer");
	//		strcpy(d.valor, "0");
			insertarEnTabla(&l_ts, &d);
			// inicializar __CONTAR_CONTADOR en cero
		//	crearTerceto(&terceto_cmp);
			strcpy(terceto_contar.posicion_a, ":=");
			strcpy(terceto_contar.posicion_b, __CONTAR_CONTADOR);
			strcpy(terceto_contar.posicion_c, "0");
			crearTerceto(&terceto_contar);}
			

		PA expresion {p_contar_pivot = p_terceto_expresion;
					
							printf("___%d___PUNTERO__",p_terceto_expresion);
								} PUNTO_COMA 
		CA lista_expresiones CC PC {
						//		strcpy(info_terceto_factor.posicion_a, "__CONTAR_CONTADOR");
						//		strcpy(info_terceto_factor.posicion_b, "_");
						//		strcpy(info_terceto_factor.posicion_c, "_");	
						//	crearTerceto(&terceto_contar);				
			//					p_terceto_contar = crearTerceto(&terceto_contar);
								printf("Funcion contar -> OK");}

lista_expresiones:
		lista_expresiones COMA expresion {  strcpy(terceto_contar.posicion_a, "CMP");
			strcpy(terceto_contar.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
			strcpy(terceto_contar.posicion_c, normalizarPunteroTerceto(p_contar_pivot));
			
			strcpy(terceto_contar.posicion_b, normalizarPunteroTerceto(crearTerceto(&terceto_contar)+4));
			strcpy(terceto_contar.posicion_a, "BNE");
			strcpy(terceto_contar.posicion_c, "_");
			crearTerceto(&terceto_contar);
			
			strcpy(terceto_contar.posicion_a, "+");
			strcpy(terceto_contar.posicion_b, __CONTAR_CONTADOR);
			strcpy(terceto_contar.posicion_c, "1");

			strcpy(terceto_contar.posicion_c, normalizarPunteroTerceto(crearTerceto(&terceto_contar)));
			strcpy(terceto_contar.posicion_a, ":=");
			strcpy(terceto_contar.posicion_b, __CONTAR_CONTADOR);
			p_terceto_contar = crearTerceto(&terceto_contar);

//			strcpy(terceto_contar.posicion_a, "COMPARACION");
//			strcpy(terceto_contar.posicion_c, "_");
//			strcpy(terceto_contar.posicion_b, "_");
//			crearTerceto(&terceto_contar);
											
			printf("expresion -> expresion , expresion OK\n\n");}

		|expresion {  strcpy(terceto_contar.posicion_a, "CMP");
			strcpy(terceto_contar.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
			strcpy(terceto_contar.posicion_c, normalizarPunteroTerceto(p_contar_pivot));
			
			strcpy(terceto_contar.posicion_b, normalizarPunteroTerceto(crearTerceto(&terceto_contar)+4));
			strcpy(terceto_contar.posicion_a, "BNE");
			strcpy(terceto_contar.posicion_c, "_");
			crearTerceto(&terceto_contar);
			
			strcpy(terceto_contar.posicion_a, "+");
			strcpy(terceto_contar.posicion_b, __CONTAR_CONTADOR);
			strcpy(terceto_contar.posicion_c, "1");

			strcpy(terceto_contar.posicion_c, normalizarPunteroTerceto(crearTerceto(&terceto_contar)));
			strcpy(terceto_contar.posicion_a, ":=");
			strcpy(terceto_contar.posicion_b, __CONTAR_CONTADOR);
			p_terceto_contar = crearTerceto(&terceto_contar);

		//	strcpy(terceto_contar.posicion_a, "COMPARACION");
		//	strcpy(terceto_contar.posicion_c, "_");
		//	strcpy(terceto_contar.posicion_b, "_");
		//	crearTerceto(&terceto_contar);

			printf("expresion -> expresion OK\n\n");}


bloque_condicional: 
				bloque_if 
					{printf("bloque_condicional\n");}

bloque_if: 
		OP_IF condicion  LLAVE_ABIERTA bloque_programa LLAVE_CERRADA{ info_cola_t terceto;

																		if(sacar_de_pila(&comparaciones_or, &comparacion_or) != PILA_VACIA) {
																			leerTerceto(comparacion_or.numero_terceto, &terceto);
																			// asignar al operador lógico el terceto al que debe saltar
																			if(sacar_de_pila(&pila_saltos, &salto) != PILA_VACIA) {		
																				strcpy(terceto.posicion_b, normalizarPunteroTerceto(salto.numero_terceto));
																				modificarTerceto(comparacion.numero_terceto, &terceto);
																				}
																		}
																	} 
											
		| OP_IF condicion  LLAVE_ABIERTA bloque_programa LLAVE_CERRADA  ELSE 
												 {
													 
													printf("Condicion con Else OK \n\n");
													info_cola_t terceto;
													if(sacar_de_pila(&comparaciones_or, &comparacion_or) != PILA_VACIA) {
													leerTerceto(comparacion_or.numero_terceto, &terceto);
													// asignar al operador lógico el terceto al que debe saltar
													if(sacar_de_pila(&pila_saltos, &salto) != PILA_VACIA) {
													
													strcpy(terceto.posicion_b, normalizarPunteroTerceto(salto.numero_terceto+1));
													modificarTerceto(comparacion_or.numero_terceto, &terceto);
													//Al finalizar el if (si era verdadero) salta incondicionalmente sin pasar por el ELSE
													strcpy(terceto_if.posicion_a, "BRA");	
													strcpy(terceto_if.posicion_c, "_");
													salto_incondicional.numero_terceto = crearTerceto(&terceto_if);
													poner_en_pila(&saltos_incondicionales, &salto_incondicional);
													}}
											}
											LLAVE_ABIERTA bloque_programa LLAVE_CERRADA {
														info_cola_t terceto;
														sacar_de_pila(&saltos_incondicionales, &salto_incondicional);	
														if(sacar_de_pila(&pila_saltos, &salto) != PILA_VACIA) {	
															leerTerceto(salto_incondicional.numero_terceto, &terceto);	
															strcpy(terceto.posicion_b, normalizarPunteroTerceto(salto.numero_terceto));
															modificarTerceto(salto_incondicional.numero_terceto, &terceto);		
														}
																										
													}

condicion:
		 PA comparacion  
		 {// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			// como es un OR por true va directo al "IF"
			// sin evaluar la segunda condición
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir donde debe saltar por false
			comparacion_or.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones_or, &comparacion_or);
			 printf("Condicion compuesta OR OK\n\n");}
		 OP_OR comparacion PC{// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);}
		| PA comparacion OP_AND comparacion PC {printf("Condicion compuesta And OK\n\n");}
		| PA OP_NOT condicion PC			  {printf("Condicion compuesta NOT OK\n\n");} 	  
		| PA comparacion PC 				  {// crear terceto con el "CMP"		
												crearTerceto(&terceto_cmp);
												// crear terceto del operador de la comparación
											   	strcpy(terceto_operador_logico.posicion_b, "_"); 
												strcpy(terceto_operador_logico.posicion_c, "_");
												// apilamos la posición del operador, para luego escribir a donde debe saltar el terceto por false
												comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
												poner_en_pila(&comparaciones_or, &comparador);
											   	printf("Comparacion -> OK\n\n");}	
					
comparacion : 
		expresion MAYOR {strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
					// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
						strcpy(terceto_operador_logico.posicion_a, "BLE");
						strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion	{strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));				
					printf("comparacion mayor  OK \n\n");}

		| expresion MENOR {
							strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
							// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BGE");
								strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion			{strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
							printf("comparacion menor OK \n\n");}

		| expresion MAYOR_IGUAL {strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
								// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BLT");
								strcpy(terceto_cmp.posicion_a, "CMP");
		  }expresion {   strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			  			printf("comparacion mayor igual OK \n\n");}
		  
		| expresion MENOR_IGUAL {
								strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
								// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BGT");
								strcpy(terceto_cmp.posicion_a, "CMP");
								strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		} expresion { printf("comparacion menor igual OK \n\n");}

		| expresion IGUAL {
						strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
						// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
			            strcpy(terceto_operador_logico.posicion_a, "BNE");
			            strcpy(terceto_cmp.posicion_a, "CMP");
		}expresion { 	strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
						printf("comparacion igual OK \n\n");}

		|expresion DISTINTO {
							strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
							// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
							strcpy(terceto_operador_logico.posicion_a, "BEQ");
							strcpy(terceto_cmp.posicion_a, "CMP");
		}expresion { 	strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
						printf("comparacion distinto OK \n\n");}

%%

int main(int argc,char *argv[]){

	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}else {
	
		
		clear_intermedia();
		crear_lista(&l_ts);
		crear_cola(&cola_tipo_id);
		crear_cola(&cola_terceto);
		crear_pila(&comparaciones);
		crear_pila(&pila_saltos);
		crear_pila(&comparaciones_or);
		crear_pila(&comparaciones_and);
		crear_pila(&saltos_incondicionales);
		yyparse();
		crearTabla(&l_ts);
		crear_intermedia(&cola_terceto);
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









int crearTerceto(info_cola_t *info_terceto) {
	poner_en_cola(&cola_terceto, info_terceto);
	return numero_terceto++;
}

char *normalizarPunteroTerceto(int terceto_puntero) {
	char_puntero_terceto[0] = '\0';
	sprintf(char_puntero_terceto, "[%d]", terceto_puntero);
	return char_puntero_terceto;
}

// limpiar una intermedia de una ejecución anterior
void clear_intermedia() {
	FILE *arch=fopen("intermedia.txt","w");
	fclose(arch);
}

void crear_intermedia(cola_t *cola_intermedia) {
	info_t aux;
	FILE *arch=fopen("intermedia.txt","w");
	printf("\n");
	printf("creando intermedia...\n");
	guardar_intermedia(cola_intermedia, arch);
	fclose(arch);
	printf("intermedia creada\n");
}

void guardar_intermedia(cola_t *p, FILE *arch) {
	int numero = NUMERO_INICIAL_TERCETO;
	info_cola_t info_terceto;
	while(sacar_de_cola(&cola_terceto, &info_terceto) != COLA_VACIA) {
	
		printf("[%d](%s,%s,%s)\n", numero,info_terceto.posicion_a ,info_terceto.posicion_b ,info_terceto.posicion_c);
		fprintf(arch,"[%d](%s,%s,%s)\n", numero++, info_terceto.posicion_a ,info_terceto.posicion_b ,info_terceto.posicion_c);
	}
	cant_total_tercetos=numero;
}

void leerTerceto(int numero_terceto, info_cola_t *info_terceto_output) {
	int index = NUMERO_INICIAL_TERCETO;
	cola_t aux;
	info_cola_t info_aux;
	
	crear_cola(&aux);
	while(sacar_de_cola(&cola_terceto, &info_aux) != COLA_VACIA) {
		poner_en_cola(&aux, &info_aux);
		if(index == numero_terceto) {
			// encontramos el terceto buscado
			strcpy(info_terceto_output->posicion_a, info_aux.posicion_a);
			strcpy(info_terceto_output->posicion_b, info_aux.posicion_b);
			strcpy(info_terceto_output->posicion_c, info_aux.posicion_c);
		}
		index++;
	}
	while(sacar_de_cola(&aux, &info_aux) != COLA_VACIA) {
		poner_en_cola(&cola_terceto, &info_aux);
	}
}

void modificarTerceto(int numero_terceto, info_cola_t *info_terceto_input) {
	int index = NUMERO_INICIAL_TERCETO;
	cola_t aux;
	info_cola_t info_aux;
	
	crear_cola(&aux);
	while(sacar_de_cola(&cola_terceto, &info_aux) != COLA_VACIA) {
		if(index == numero_terceto) {
			poner_en_cola(&aux, info_terceto_input);
		} else {
			poner_en_cola(&aux, &info_aux);
		}
		index++;
	}
	while(sacar_de_cola(&aux, &info_aux) != COLA_VACIA) {
		poner_en_cola(&cola_terceto, &info_aux);
	}
}

void crear_pila(pila_t *p) {
	*p=NULL;
}

int poner_en_pila(pila_t *p, info_pila_t *d) {
	nodo_pila_t *nue=(nodo_pila_t*)malloc(sizeof(nodo_pila_t));

	if(nue==NULL)
		return SIN_MEMORIA;

	nue->info=*d;
	nue->sig=*p;
	*p=nue;

	return TODO_BIEN;
}


int sacar_de_pila(pila_t *p, info_pila_t *d) {
	nodo_pila_t *aux;

	if(*p==NULL)
		return PILA_VACIA;

	aux=*p;
	*d=aux->info;
	*p=aux->sig;
	free(aux);

	return TODO_BIEN;
}

char *invertirOperadorLogico(char *operador_logico) {
	if(strcmp(operador_logico, "BLT") == 0)  {
		return "BGE";
	}
	if(strcmp(operador_logico, "BLE") == 0)  {
		return "BGT";
	}
	if(strcmp(operador_logico, "BGT") == 0)  {
		return "BLE";
	}
	if(strcmp(operador_logico, "BGE") == 0)  {
		return "BLT";
	}
	if(strcmp(operador_logico, "BNE") == 0)  {
		return "BEQ";
	}
	if(strcmp(operador_logico, "BEQ") == 0)  {
		return "BNE";
	}
}


char *guion_cadena(char cad[TAM]) {
	char guion[TAM+1]="_" ;
	strcat(guion,cad);
	strcpy(cadena,guion);
	return cadena;
}

char * charReplace(char * str, char caracter, char nuevo_caracter) {
	int i;
	for(i = 0; i <= strlen(str); i++)
	{
		if(str[i] == caracter)  
		{
			str[i] = nuevo_caracter;
		}
	}
	return str;
}
