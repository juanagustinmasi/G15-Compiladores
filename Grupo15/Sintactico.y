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
            { printf("\n TODO OK\n");};

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
							//p_terceto_factor = p_terceto_contar;
							}


funcion_contar:
		CONTAR PA expresion PUNTO_COMA CA lista_expresiones CC PC {printf("Funcion contar -> OK");}

lista_expresiones:
		lista_expresiones COMA expresion { printf("expresion -> expresion , expresion OK\n\n");}
		|expresion	{printf("expresion -> expresion OK\n\n");}


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
													
<<<<<<< Updated upstream
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
=======
			info_cola_t terceto;		

			// por cada comparación que se haga en la condición
			int compraciones_condicion = 1;
			while(compraciones_condicion) {
				compraciones_condicion--;
				// desapilar y escribir la posición a la que se debe saltar 
				// si no se cumple la condición del if
				sacar_de_pila(&comparaciones, &comparador);
				leerTerceto(comparador.numero_terceto, &terceto);
				if (strcmp(terceto.posicion_b, "AND") == 0) {
					// si es una condición AND tiene más comparaciones para desapilar
					compraciones_condicion++;
				}
				// asignar al operador (por ejemplo un "BNE") el terceto al que debe saltar
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_fin_then));
				modificarTerceto(comparador.numero_terceto, &terceto);		

				 info_cola_t terceto;
			strcpy(terceto_if.posicion_a, "ENDIF");
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
		 	p_terceto_fin_if = crearTerceto(&terceto_if);

			sacar_de_pila(&saltos_incondicionales, &salto_incondicional);
			leerTerceto(salto_incondicional.numero_terceto, &terceto);
			strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_fin_if));
			modificarTerceto(salto_incondicional.numero_terceto, &terceto);		
												 } 
}																								
													
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
			 printf("Comparacion OR OK\n\n");}
=======
			 printf("Condicion compuesta OR -> OK\n\n");}
>>>>>>> Stashed changes
		 OP_OR comparacion PC{// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);}
<<<<<<< Updated upstream
		| PA comparacion OP_AND comparacion PC {printf("Comparacion And OK\n\n");}
		| PA OP_NOT condicion PC			  {printf("Comparacion NOT OK\n\n");} 	  
=======
		| PA comparacion OP_AND comparacion PC {printf("Condicion compuesta AND -> OK\n\n");}
		| PA OP_NOT condicion PC			  {printf("Condicion compuesta NOT -> OK\n\n");} 	  
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
					printf("mayor  OK \n\n");}
=======
					printf("Comparacion mayor -> OK \n\n");}
>>>>>>> Stashed changes

		| expresion MENOR {
								strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
								// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BGE");
								strcpy(terceto_cmp.posicion_a, "CMP");
<<<<<<< Updated upstream
		} expresion			{strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
							printf("menor OK \n\n");}
=======
		} expresion			{	strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
								printf("comparacion menor -> OK \n\n");}
>>>>>>> Stashed changes

		| expresion MAYOR_IGUAL {strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
								// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BLT");
								strcpy(terceto_cmp.posicion_a, "CMP");
<<<<<<< Updated upstream
		  }expresion {   strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			  			printf("mayor igual OK \n\n");}
=======
		  }expresion {   		strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			  					printf("comparacion mayor igual -> OK \n\n");}
>>>>>>> Stashed changes
		  
		| expresion MENOR_IGUAL {
								strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
								// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
								strcpy(terceto_operador_logico.posicion_a, "BGT");
								strcpy(terceto_cmp.posicion_a, "CMP");
<<<<<<< Updated upstream
<<<<<<< Updated upstream
								strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		} expresion { printf("menor igual OK \n\n");}
=======
								
		} expresion { 			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
								printf("comparacion menor igual OK \n\n");}
>>>>>>> Stashed changes

		| expresion IGUAL {
						strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
						// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
			            strcpy(terceto_operador_logico.posicion_a, "BNE");
			            strcpy(terceto_cmp.posicion_a, "CMP");
		}expresion { 	strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
<<<<<<< Updated upstream
						printf("igual OK \n\n");}
=======
						printf("comparacion igual -> OK \n\n");}
>>>>>>> Stashed changes

		|expresion DISTINTO {
							strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
							// guardamos el operador para insertarlo luego de crear el terceto del "CMP"
							strcpy(terceto_operador_logico.posicion_a, "BEQ");
							strcpy(terceto_cmp.posicion_a, "CMP");
<<<<<<< Updated upstream
		}expresion { 	strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
						printf("distinto OK \n\n");}
=======
		}expresion { 		strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
							printf("comparacion distinto -> OK \n\n");}
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
=======
		crear_assembler(&l_ts);
		printf("### COMPILACION EXITOSA ### \n");
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======


/* ###### ASSEMBLER ###### */


void crear_assembler(lista_t *l_ts){
	// ----------------------------------------------------------------
	// Lee el archivo intermedia en una lista
	// ----------------------------------------------------------------
	char numero[5];
	char numero_buscar[5];
	t_lista_intermedia listaintermedia;
	crear_lista_intermedia(&listaintermedia);
	int i = 0;
	char * pt;
	char linea[100];
	FILE *arch = fopen("intermedia.txt","r");
	if(!arch)
	{
		exit(1);
	}
	while(fgets(linea,sizeof(linea),arch)) {
		info_intermedia_t info_terceto;
		info_intermedia_t *terceto_encontrado;
		info_t aux_ts;
		char buffer[20];
		pt = strchr(linea,'\n');
		*pt = '\0';
		pt = strchr(linea,')');
		*pt = '\0';
		pt = strrchr(linea,',');
		strcpy(info_terceto.posicion_c,pt+1);
		*pt = '\0';
		pt = strrchr(linea,',');
		strcpy(info_terceto.posicion_b,pt+1);
		*pt = '\0';
		pt = strrchr(linea,'(');
		strcpy(info_terceto.posicion_a,pt+1);
		*pt = '\0';
		pt = strrchr(linea,']');
		*pt = '\0';
		pt = strrchr(linea,'[');
		strcpy(info_terceto.numero,pt+1);
		strcpy(info_terceto.posicion_aux,"\0");
		if(strcmp(info_terceto.posicion_a,"-")==0 ||strcmp(info_terceto.posicion_a,"*")==0 ||strcmp(info_terceto.posicion_a,"+")==0 ||strcmp(info_terceto.posicion_a,"/")==0)
		{
			strcat(info_terceto.posicion_aux,"_@aux");
			strcat(info_terceto.posicion_aux,itoa(i,buffer,10));
			i++;
			strcpy(aux_ts.clave,info_terceto.posicion_aux);
			strcpy(aux_ts.tipodato,"Float");
			strcpy(aux_ts.valor,"\0");
			strcpy(aux_ts.longitud,"\0");
			insertar_en_orden(l_ts,&aux_ts);
		} 

		pt = strrchr(info_terceto.posicion_b,']');
		if (pt)
		{
			strcpy(buffer,info_terceto.posicion_b);
			pt = strchr(buffer,']');
			*pt = '\0';
			pt = strrchr(buffer,'[');
			*pt = '\0';
			strcpy(numero_buscar,pt+1);
			terceto_encontrado=buscar_lista_intermedia(&listaintermedia,numero_buscar);
			if(terceto_encontrado)
			{
				if(strcmp(terceto_encontrado->posicion_a,"-")==0 ||strcmp(terceto_encontrado->posicion_a,"*")==0 ||strcmp(terceto_encontrado->posicion_a,"+")==0 ||strcmp(terceto_encontrado->posicion_a,"/")==0)
				{
					strcpy(info_terceto.posicion_b,terceto_encontrado->posicion_aux);
				} else 
				{
					strcpy(info_terceto.posicion_b,terceto_encontrado->posicion_a);
					strcpy(terceto_encontrado->posicion_aux,"BORRADO");
				}
			}
		}
		pt = strrchr(info_terceto.posicion_c,']');
		if (pt)
		{
			strcpy(buffer,info_terceto.posicion_c);
			pt = strrchr(buffer,']');
			*pt = '\0';
			pt = strrchr(buffer,'[');
			*pt = '\0';
			strcpy(numero_buscar,pt+1);
			terceto_encontrado=buscar_lista_intermedia(&listaintermedia,numero_buscar);
			if(terceto_encontrado)
			{
				if(strcmp(terceto_encontrado->posicion_a,"-")==0 ||strcmp(terceto_encontrado->posicion_a,"*")==0 ||strcmp(terceto_encontrado->posicion_a,"+")==0 ||strcmp(terceto_encontrado->posicion_a,"/")==0)
				{
					strcpy(info_terceto.posicion_c,terceto_encontrado->posicion_aux);
				} else 
				{
					strcpy(info_terceto.posicion_c,terceto_encontrado->posicion_a);
					strcpy(terceto_encontrado->posicion_aux,"BORRADO");
				}
			}
		}
		strcat(info_terceto.posicion_aux,"\0");
		
		if (strcmp(info_terceto.posicion_a,"IF")==0 )
		{
			strcpy(info_terceto.posicion_aux,"BORRADO");
		}
		insertar_en_orden_intermedia(&listaintermedia, &info_terceto);

	}

	FILE *asmFile = fopen("Final.asm", "wt");
	if (!asmFile) 
		exit(-1);
	
	generarHeaderAssembler(asmFile);
	generarDataAssembler(asmFile, l_ts);
	recorrer_intermedia(asmFile, &listaintermedia, l_ts);
	generarFooterAssembler(asmFile);

	FILE *arch2=fopen("tablaSimbolos.txt","w");
	guardar_lista(l_ts, arch2);
	fclose(arch2);
	fclose(arch);
	fclose(asmFile);
}

void generarHeaderAssembler(FILE* asmFile) {
	fprintf(asmFile,"include macros2.asm\n");
	fprintf(asmFile,"include number.asm\n\n");
	//fprintf(asmFile,"include numbers.asm\n\n");
	fprintf(asmFile,".MODEL LARGE\n.STACK 200h\n.386\n.387\n\n");
}

void generarDataAssembler(FILE* asmFile, lista_t *p) {
		fprintf(asmFile,"MAXTEXTSIZE equ 50\n\n.DATA\n\n");

		if ( strcmp((*p)->info.clave, "__CONTAR_CONTADOR") != 0)

	while(*p) {
		// Variables
		if (strcmp((*p)->info.tipodato, "Integer") == 0) {
			if (strcmp((*p)->info.clave, "__CONTAR_CONTADOR") != 0 ) {
				char aux[TAM+1];
				sprintf(aux, "_%s", (*p)->info.clave);
				strcpy((*p)->info.clave, aux);
			}
			//	fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
				fprintf(asmFile,"%-35s DD %-10s\n", (*p)->info.clave, (*p)->info.valor);
		}
		if (strcmp((*p)->info.tipodato, "Float") == 0) {
			if (strncmp("_@aux", (*p)->info.clave, 5) != 0) {
				char aux[TAM+1];
				sprintf(aux, "_%s", charReplace((*p)->info.clave,'.','_'));
				strcpy((*p)->info.clave, aux);
			}
				fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
		}
		if (strcmp((*p)->info.tipodato, "String") == 0) {

			char aux[TAM+1];
			sprintf(aux, "_%s_", (*p)->info.clave);
			strcpy((*p)->info.clave, aux);
			fprintf(asmFile,"%-35s DB MAXTEXTSIZE dup (?)\n", charReplace((*p)->info.clave,'.','_'));
		}
		if (strcmp((*p)->info.tipodato, "Undefined") == 0)
			fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
		
		// Constantes
		if (strcmp((*p)->info.tipodato, "const Integer") == 0)
			fprintf(asmFile,"%-35s DD %-10s\n", (*p)->info.clave, (*p)->info.valor);
		if (strcmp((*p)->info.tipodato, "const Real") == 0)
			fprintf(asmFile,"%-35s DD %-10s\n", charReplace((*p)->info.clave,'.','_'), (*p)->info.valor);
		if (strcmp((*p)->info.tipodato, "const String") == 0) {

			char aux[TAM];
			strncpy(aux, ((*p)->info.valor) + 1, strlen((*p)->info.valor) - 2);
			aux[strlen((*p)->info.valor)-2] = '\0';
			sprintf((*p)->info.clave, "_%s_", aux);
			fprintf(asmFile,"_%-35s DB %-10s, %s dup (?)\n", charReplace((*p)->info.clave,'.','_'), (*p)->info.valor, (*p)->info.longitud);
		}

		p=&(*p)->sig;
	}
	fprintf(asmFile,"\n");
}

void generarFooterAssembler(FILE* asmFile) {

	/*
	FINAL:
    mov ah, 1 ; pausa, espera que oprima una tecla
    int 21h ; AH=1 es el servicio de lectura
    MOV AX, 4C00h ; Sale del Dos
    INT 21h ; Enviamos la interripcion 21h
	END START ; final del archivo.
	*/
	fprintf(asmFile,"FINAL:\nmov ah, 1\nint 21h\nMOV AX, 4C00h\nINT 21h\nEND START");
}

info_intermedia_t* buscar_lista_intermedia(t_lista_intermedia *p ,char * numero_buscar)
{
	while(*p && strcmp((*p)->info.numero,numero_buscar)!=0) {
		p=&(*p)->sig;
	}
	if (p) {
		return &((*p)->info);
	}
	return NULL;
}
int buscar_en_ts(char * cad ,lista_t *l_ts)
{
	while(*l_ts && strcmp((*l_ts)->info.clave,cad)!=0) {
		l_ts=&(*l_ts)->sig;
	}
	if (*l_ts) {
		return 1;
	}
	return 0;
}

void recorrer_intermedia(FILE *arch, t_lista_intermedia *p, lista_t *l_ts){
	char * pt;
	info_intermedia_t *terceto_encontrado;
	char buffer[20];
	fprintf(arch,".CODE\n\nSTART:\nMOV AX, @DATA\nMOV DS,AX\nFINIT\nFFREE\n\n");

	while(*p) {
		if(strcmp((*p)->info.posicion_a,"PUT")==0 )
		{	
			charReplace((*p)->info.posicion_b,' ','_');
			charReplace((*p)->info.posicion_b,'.','_');
			charReplace((*p)->info.posicion_b,':','_');
			charReplace((*p)->info.posicion_b,'"','_');

			//fprintf(arch,"mov dx,OFFSET _%s\n mov ah,9\n int 21h\n",(*p)->info.posicion_b);
			fprintf(arch,"DisplayString _%s\n",charReplace((*p)->info.posicion_b,' ','_'));
		}

		if(strncmp((*p)->info.posicion_a,"__JUMP_CONTADOR",15)==0 || strncmp((*p)->info.posicion_a,"ELSE",4)==0 || strncmp((*p)->info.posicion_a,"ENDIF",5)==0)
		{
			fprintf(arch,"%s:\n",(*p)->info.posicion_a);
		}
		if ((strcmp((*p)->info.posicion_a,"BNE")==0)||(strcmp((*p)->info.posicion_a,"BLT")==0)||(strcmp((*p)->info.posicion_a,"BGE")==0)||(strcmp((*p)->info.posicion_a,"BEQ")==0)||(strcmp((*p)->info.posicion_a,"BGT")==0)||(strcmp((*p)->info.posicion_a,"BRA")==0)||(strcmp((*p)->info.posicion_a,"BLE")==0))
		{
			if ((strcmp((*p)->info.posicion_a,"BNE")==0))
			{
				strcpy((*p)->info.posicion_a,"JNE");
			}
			if ((strcmp((*p)->info.posicion_a,"BLT")==0))
			{
				strcpy((*p)->info.posicion_a,"JL");
			}
			if ((strcmp((*p)->info.posicion_a,"BGE")==0))
			{
				strcpy((*p)->info.posicion_a,"JGE");
			}
			if ((strcmp((*p)->info.posicion_a,"BEQ")==0))
			{
				strcpy((*p)->info.posicion_a,"JE");
			}
			if ((strcmp((*p)->info.posicion_a,"BGT")==0))
			{
				strcpy((*p)->info.posicion_a,"JG");
			}
			if ((strcmp((*p)->info.posicion_a,"BRA")==0))
			{
				strcpy((*p)->info.posicion_a,"JMP");
			}
			if ((strcmp((*p)->info.posicion_a,"BLE")==0))
			{
				strcpy((*p)->info.posicion_a,"JLE");
			}
			pt = strrchr((*p)->info.posicion_b,']');
			if(!pt)
			{
				fprintf(arch,"%s %s\n",(*p)->info.posicion_a,(*p)->info.posicion_b);
			} else 
			{
				*pt='\0';
				pt = strrchr((*p)->info.posicion_b,'[');
				*pt = '\0';
				terceto_encontrado=buscar_lista_intermedia(p,pt+1);
				fprintf(arch,"%s %s\n",(*p)->info.posicion_a,terceto_encontrado->posicion_a);
			}
		}
		if(buscar_en_ts((*p)->info.posicion_b,l_ts)==0)
		{
			buffer[0]='\0';
			strcat(buffer,"_");
			strcat(buffer,(*p)->info.posicion_b);
			strcpy((*p)->info.posicion_b,buffer);
		}
		if(buscar_en_ts((*p)->info.posicion_c,l_ts)==0)
		{
			buffer[0]='\0';
			strcat(buffer,"_");
			strcat(buffer,(*p)->info.posicion_c);
			strcpy((*p)->info.posicion_c,buffer);
		}
		if(strcmp((*p)->info.posicion_a,"GET")==0)
		{
			fprintf(arch,"GetInteger %s\n",(*p)->info.posicion_b);
		}
		if(strcmp((*p)->info.posicion_a,"=")==0 || strcmp((*p)->info.posicion_a,":")==0)
		{

		//	printf("resultado:%d\n",strchr((*p)->info.posicion_c,':'));		
			if(strchr((*p)->info.posicion_c,':')!=0){
			fprintf(arch,"fild %s\nfistp %s\n","__CONTAR_CONTADOR",(*p)->info.posicion_b);
			}else{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}

			fprintf(arch,"fild %s\nfistp %s\n",charReplace((*p)->info.posicion_c,'.','_'),(*p)->info.posicion_b);
			}
		}
		if(strcmp((*p)->info.posicion_a,"*")==0)
		{
			fprintf(arch,"fild %s\nfild %s\nfmul\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_aux);
		}
		if(strcmp((*p)->info.posicion_a,"+")==0)
		{
			fprintf(arch,"fild %s\nfild %s\nfadd\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_aux);
		}
		if(strcmp((*p)->info.posicion_a,"/")==0)
		{
			fprintf(arch,"fild %s\nfild %s\nfdiv\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_aux);
		}
		if(strcmp((*p)->info.posicion_a,"-")==0)
		{
			fprintf(arch,"fild %s\nfild %s\nfsub\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_aux);
		}
		if(strcmp((*p)->info.posicion_a,"CMP")==0)
		{
			fprintf(arch,"fild %s\nfild %s\nfxch\nfcom\nfstsw ax\nsahf\n",(*p)->info.posicion_b,charReplace((*p)->info.posicion_c,'.','_'));
		}
		p=&(*p)->sig;
	}

	fprintf(arch, "\n");
	return;
}

int insertar_en_orden_intermedia(t_lista_intermedia *p, info_intermedia_t *d) {
	nodo_intermedia_t* nue;
	while(*p)
			p=&(*p)->sig;
	*p=(nodo_intermedia_t*)malloc(sizeof(nodo_intermedia_t));
	if(*p==NULL)
			return SIN_MEMORIA;
	(*p)->info=*d;
	(*p)->sig=NULL;
	return TODO_BIEN;
}

void crear_lista_intermedia(t_lista_intermedia *p) {
    *p=NULL;
}
>>>>>>> Stashed changes
