%{
	#include <stdio.h>
	#include <stdbool.h>
	#include <string.h>
	#include <stdarg.h>
	#include <math.h>
	#include <stdlib.h>
	#include <errno.h>
	#include "y.tab.h"

	#define SIN_MEMORIA 0
	#define DATO_DUPLICADO 0
	#define TODO_BIEN 1
	#define PILA_VACIA 0
	#define COLA_VACIA 0
	#define TAM 35
	#define NUMERO_INICIAL_TERCETO 10
	#define __FILTER_INDEX "__FILTER_INDEX"
	#define __FILTER_OPERANDO "__FILTER_OPERANDO"
	#define __INLIST_RETURN "__INLIST_RETURN"
	#define __IGUALES_RETURN "__IGUALES_RETURN"

	// funciones de Flex y Bison
	// --------------------------------------------------------
	extern void yyerror(const char *mensaje);
	extern char error_mensaje[1000];
	extern int yylex(void);
	extern char * yytext;
	extern long int yylineno;
	FILE *yyin;

	typedef struct
	{
			char clave[TAM];
			char tipodato[TAM];
			char valor[TAM];
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
		int numero_terceto;
	} info_pila_t;

	typedef struct sNodoPila
	{
		info_pila_t info;
		struct sNodoPila *sig;
	} nodo_pila_t;
	
	typedef nodo_pila_t *pila_t;

	typedef struct
	{
		char descripcion[TAM];
		char posicion_a[TAM];
		char posicion_b[TAM];
		char posicion_c[TAM];
	} info_cola_t;

	typedef struct
	{
		char numero[TAM];
		char posicion_a[TAM];
		char posicion_b[TAM];
		char posicion_c[TAM];
		char posicion_aux[TAM];
	} info_intermedia_t;

	typedef struct sNodointermedia
	{
		info_intermedia_t info;
		struct sNodointermedia *sig;
	} nodo_intermedia_t;

	typedef nodo_intermedia_t* t_lista_intermedia;

	typedef struct sNodoCola
	{
		info_cola_t info;
		struct sNodoCola *sig;
	} nodo_cola_t;

	typedef struct
	{
		nodo_cola_t *pri, *ult;
	} cola_t;

	int buscar_en_ts(char * cad ,lista_t *l_ts);
	void crear_assembler(lista_t *l_ts);
	void crear_cola(cola_t *c);
	int poner_en_cola(cola_t *c, info_cola_t *d);
	int sacar_de_cola(cola_t *c, info_cola_t *d);
	void crear_pila(pila_t *p);
	int poner_en_pila(pila_t *p, info_pila_t *d);
	int sacar_de_pila(pila_t*p, info_pila_t *d);
	info_intermedia_t* buscar_lista_intermedia(t_lista_intermedia *p ,char * numero_buscar);
	void recorrer_intermedia(FILE *arch, t_lista_intermedia *p, lista_t *l_ts);
	void crear_lista(lista_t *p);
	void crear_lista_intermedia(t_lista_intermedia *p) ;
	int insertar_en_orden(lista_t *p, info_t *d);
	int insertar_en_orden_intermedia(t_lista_intermedia *p, info_intermedia_t *d);
	int sacar_repetidos(lista_t *p, info_t *d, int (*cmp)(info_t*d1, info_t*d2), int elimtodos);
	void guardar_lista(lista_t *p, FILE *arch);
	int comparar(info_t*d1, info_t*d2);
	void clear_ts();
	void crear_ts(lista_t *l_ts);
	int insertar_en_ts(lista_t *l_ts, info_t *d);
	void validar_id(char *id);
	char *guion_cadena(char cad[TAM]);
	int crearTerceto(info_cola_t *info_terceto);
	void leerTerceto(int numero_terceto, info_cola_t *info_terceto_output);
	void modificarTerceto(int numero_terceto, info_cola_t *info_terceto_input);
	char *invertirOperadorLogico(char *operador_logico);
	// le agrega los corchetes al número de terceto, osea entra 10 y sale [10]
	char *normalizarPunteroTerceto(int terceto_puntero);
	void clear_intermedia();
	void crear_intermedia(cola_t *cola_intermedia);
	void guardar_intermedia(cola_t *p, FILE *arch);
	void generarHeaderAssembler(FILE* asmFile);
	void generarDataAssembler(FILE* asmFile, lista_t *l_ts);
	void generarFooterAssembler(FILE* asmFile);
	char * charReplace(char * str, char caracter, char nuevo_caracter);

	lista_t l_ts;
	info_t d;
	cola_t cola_tipo_id;
	info_cola_t info_tipo_id;
	char cadena[TAM+1];
 	extern const int MAX_STRING_LENGTH;

	// forma del terceto
	// [numero_terceto] = crearTerceto(terceto_a, terceto_b, terceto_c)
	char char_puntero_terceto[TAM];
	int numero_terceto = NUMERO_INICIAL_TERCETO;
	int cant_total_tercetos=0;
	cola_t cola_terceto;
	info_cola_t terceto_asignacion;
	info_cola_t terceto_asignacion_especial;
	info_cola_t terceto_expresion;
	info_cola_t terceto_termino;
	info_cola_t terceto_factor;
	info_cola_t terceto_if;
	info_cola_t terceto_cmp;
	info_cola_t	terceto_operador_logico;
	info_cola_t	terceto_repeat;
	info_cola_t	terceto_filter;
	info_cola_t	terceto_inlist;
	info_cola_t	terceto_print;
	info_cola_t	terceto_read;
	int p_terceto_expresion;
	int p_terceto_expresion_pibot;
	int p_terceto_termino;
	int p_terceto_factor;
	int p_terceto_fin_then;
	int p_terceto_if_then;
	int p_terceto_endif;
	int p_terceto_repeat;
	int p_terceto_repeat_then;
	int p_terceto_endrepeat;
	int p_terceto_filter_salto_lista;
	int p_terceto_filter_index;
	int p_terceto_filter_operando;
	int p_terceto_filter_then;
	int p_terceto_filter_lista;
	int p_terceto_filter_cmp;
	int p_terceto_filter_salto_id_siguiente;
	int p_terceto_filter_fin;
	int p_terceto_inlist_id;
	int p_terceto_inlist_salto_a_fin;
	int p_terceto_inlist_fin;
	int p_terceto_inlist_iguales;
	pila_t comparaciones;
	info_pila_t comparador;
	pila_t comparaciones_or;
	info_pila_t comparacion_or;
	pila_t comparaciones_and;
	info_pila_t comparacion_and;
	pila_t saltos_incondicionales;
	info_pila_t salto_incondicional;
	pila_t repeats;
	info_pila_t inicio_repeat;
	pila_t inlist_comparaciones;
	info_pila_t inlist_comparacion;
	int _filter_index; 
%}

%locations
%start start
%token INLIST
%token IGUALES
%token HASHTAG
%token FILTER
%token OPERANDO_FILTER
%token REPEAT
%token ENDREPEAT
%token IF
%token ELSE
%token ENDIF
%token AND
%token OR
%token NOT
%token PRINT
%token READ
%token VAR
%token ENDVAR
%token INTEGER
%token FLOAT
%token STRING
%token ID
%token CONSTANTE_ENTERA
%token CONSTANTE_REAL
%token CONSTANTE_STRING
%token COMA
%token OP_ASIGNACION
%token DOS_PUNTOS
%token PUNTO_Y_COMA
%token PARENTESIS_ABRE
%token PARENTESIS_CIERRA
%token CORCHETE_ABRE
%token CORCHETE_CIERRA
%token SUMA
%token MULTIPLICACION
%token RESTA
%token DIVISION
%token IGUAL_A
%token MENOR_A
%token MENOR_IGUAL_A
%token MAYOR_A
%token MAYOR_IGUAL_A
%token DISTINTA_A
%token MAS_I
%token MENOS_I
%token MUL_I
%token DIV_I
%token SIM_MAS_I
%token SIM_MENOS_I
%token SIM_MUL_I
%token SIM_DIV_I

%%

	start:
		declaraciones programa
		;

	declaraciones:	
		VAR setencias_de_declaraciones ENDVAR
		;

	declaraciones:
		VAR ENDVAR
		;

	declaraciones:
		;

	setencias_de_declaraciones:
		setencia_declaracion
		;

	setencias_de_declaraciones:
		setencias_de_declaraciones setencia_declaracion
		;

	setencia_declaracion:
		CORCHETE_ABRE declaracion CORCHETE_CIERRA
		;

	declaracion:
		tipo_id CORCHETE_CIERRA DOS_PUNTOS CORCHETE_ABRE ID	{
			validar_id(yytext);
			sacar_de_cola(&cola_tipo_id, &info_tipo_id);
			strcpy(d.clave, yytext);
			strcpy(d.tipodato, info_tipo_id.descripcion);
			insertar_en_ts(&l_ts, &d);
		} 	
		;

	declaracion:
		tipo_id COMA declaracion COMA ID {
			validar_id(yytext);
			sacar_de_cola(&cola_tipo_id, &info_tipo_id);
			strcpy(d.clave, yytext);
			strcpy(d.tipodato, info_tipo_id.descripcion);
			insertar_en_ts(&l_ts, &d);
		}
		;

	tipo_id:
		INTEGER {
			strcpy(info_tipo_id.descripcion, yytext);
			poner_en_cola(&cola_tipo_id, &info_tipo_id);
		} 
		;

	tipo_id:
		FLOAT {
			strcpy(info_tipo_id.descripcion, yytext);
			poner_en_cola(&cola_tipo_id, &info_tipo_id);
		} 
		;

	tipo_id:
		STRING {
			strcpy(info_tipo_id.descripcion, yytext);
			poner_en_cola(&cola_tipo_id, &info_tipo_id);
		} 
		;

	programa:
		sentencia
		;

	programa:
		programa sentencia
		;

	programa:
		;

	sentencia:
		SIM_MAS_I asignacion_especial_mas
		;

	sentencia:
		SIM_MENOS_I asignacion_especial_menos
		;
		
	sentencia:
		SIM_MUL_I asignacion_especial_mul
		;
		
	sentencia:
		SIM_DIV_I asignacion_especial_div
		;

	sentencia:
	    DOS_PUNTOS asignacion
	    ;
		
	sentencia:
		seleccion
		;

	sentencia:
		entrada
		;

	sentencia:
		salida
		;

	sentencia:
		ciclo
		;

	sentencia:
		filtro
		;

	sentencia:
		en_lista
		;

	sentencia:
		iguales
		;
	sentencia:
		ID OP_ASIGNACION iguales
		;

	iguales:
		HASHTAG IGUALES {
			strcpy(terceto_inlist.posicion_a, yytext);
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);
			// si el ID está en las lista "__IGUALES_RETURN" suma 1, si no suma 0
			strcpy(d.clave, __IGUALES_RETURN);
			strcpy(d.tipodato, "Integer");
			strcpy(d.valor, "0");
			insertar_en_ts(&l_ts, &d);
			// inicializar __IGUALES_RETURN en cero
			crearTerceto(&terceto_cmp);
			strcpy(terceto_inlist.posicion_a, ":=");
			strcpy(terceto_inlist.posicion_b, __IGUALES_RETURN);
			strcpy(terceto_inlist.posicion_c, "0");
			crearTerceto(&terceto_inlist);
		} PARENTESIS_ABRE expresion {
			p_terceto_expresion_pibot = p_terceto_expresion;
		} COMA CORCHETE_ABRE lista_expresiones_iguales CORCHETE_CIERRA PARENTESIS_CIERRA 
		;

		lista_expresiones_iguales:
		expresion {
			strcpy(terceto_inlist.posicion_a, "CMP");
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(p_terceto_expresion_pibot));
			
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(crearTerceto(&terceto_inlist)+4));
			strcpy(terceto_inlist.posicion_a, "BEQ");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);
			
			strcpy(terceto_inlist.posicion_a, "+");
			strcpy(terceto_inlist.posicion_b, __IGUALES_RETURN);
			strcpy(terceto_inlist.posicion_c, "1");

			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(crearTerceto(&terceto_inlist)));
			strcpy(terceto_inlist.posicion_a, ":=");
			strcpy(terceto_inlist.posicion_b, __IGUALES_RETURN);
			crearTerceto(&terceto_inlist);

			strcpy(terceto_inlist.posicion_a, "COMPARACION");
			strcpy(terceto_inlist.posicion_c, "_");
			strcpy(terceto_inlist.posicion_b, "_");
			crearTerceto(&terceto_inlist);
		};

		lista_expresiones_iguales:
		lista_expresiones_iguales COMA expresion {
			strcpy(terceto_inlist.posicion_a, "CMP");
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(p_terceto_expresion_pibot));
			
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(crearTerceto(&terceto_inlist)+4));
			strcpy(terceto_inlist.posicion_a, "BEQ");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);
			
			strcpy(terceto_inlist.posicion_a, "+");
			strcpy(terceto_inlist.posicion_b, __IGUALES_RETURN);
			strcpy(terceto_inlist.posicion_c, "1");

			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(crearTerceto(&terceto_inlist)));
			strcpy(terceto_inlist.posicion_a, ":=");
			strcpy(terceto_inlist.posicion_b, __IGUALES_RETURN);
			crearTerceto(&terceto_inlist);

			strcpy(terceto_inlist.posicion_a, "COMPARACION");
			strcpy(terceto_inlist.posicion_c, "_");
			strcpy(terceto_inlist.posicion_b, "_");
			crearTerceto(&terceto_inlist);
		}
		;

	en_lista:
		INLIST {
			strcpy(terceto_inlist.posicion_a, yytext);
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);
			// si el ID está en las lista "__INLIST_RETURN" vale 1, si no vale 0
			strcpy(d.clave, __INLIST_RETURN);
			strcpy(d.tipodato, "Integer");
			strcpy(d.valor, "0");
			insertar_en_ts(&l_ts, &d);
			// inicializar __INLIST_RETURN en cero
			crearTerceto(&terceto_cmp);
			strcpy(terceto_inlist.posicion_a, ":=");
			strcpy(terceto_inlist.posicion_b, __INLIST_RETURN);
			strcpy(terceto_inlist.posicion_c, "0");
			crearTerceto(&terceto_inlist);
		} PARENTESIS_ABRE ID {
			strcpy(terceto_inlist.posicion_a, yytext);
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			p_terceto_inlist_id = crearTerceto(&terceto_inlist);
		} PUNTO_Y_COMA CORCHETE_ABRE lista_expresiones_inlist CORCHETE_CIERRA PARENTESIS_CIERRA {
			info_cola_t terceto;
			// terminó todas las comparaciones, salta al fin del INLIST
			strcpy(terceto_inlist.posicion_a, "BRA");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			p_terceto_inlist_salto_a_fin = crearTerceto(&terceto_inlist);
			strcpy(terceto_cmp.posicion_a,"RETURN_TRUE");
			strcpy(terceto_cmp.posicion_b,"_");
			strcpy(terceto_cmp.posicion_c,"_");
			p_terceto_inlist_iguales = crearTerceto(&terceto_cmp);
			// acá salta si una comparación dió que son iguales
			strcpy(terceto_inlist.posicion_a, ":=");
			strcpy(terceto_inlist.posicion_b, __INLIST_RETURN);
			strcpy(terceto_inlist.posicion_c, "1");
			crearTerceto(&terceto_inlist);
			while(sacar_de_pila(&inlist_comparaciones, &inlist_comparacion) != PILA_VACIA) {
				leerTerceto(inlist_comparacion.numero_terceto, &terceto);
				//strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_inlist_iguales));
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_inlist_iguales));
				modificarTerceto(inlist_comparacion.numero_terceto, &terceto);
			}
			strcpy(terceto_inlist.posicion_a, "ENDINLIST");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			p_terceto_inlist_fin = crearTerceto(&terceto_inlist);
			leerTerceto(p_terceto_inlist_salto_a_fin, &terceto);
			strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_inlist_fin));
			modificarTerceto(p_terceto_inlist_salto_a_fin, &terceto);
		}
		;

	filtro:
		FILTER {
			strcpy(terceto_filter.posicion_a, yytext);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			crearTerceto(&terceto_filter);
			
			// variable de compilador __FILTER_INDEX
			// la agregamos a la ts y al código intermedio
			strcpy(d.clave, __FILTER_INDEX);
			strcpy(d.tipodato, "Integer");
			strcpy(d.valor, "0");
			insertar_en_ts(&l_ts, &d);
			// inicializar __FILTER_INDEX en cero
			strcpy(terceto_filter.posicion_a, ":=");
			strcpy(terceto_filter.posicion_b, __FILTER_INDEX);
			strcpy(terceto_filter.posicion_c, "0");
			crearTerceto(&terceto_filter);
			// este branch salta a la primer variable del listado (apilamos la posición del terceto)
			// y luego seteamos al terceto la posición a la que debe saltar
			strcpy(terceto_filter.posicion_a, "BRA");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_salto_lista = crearTerceto(&terceto_filter);

			strcpy(terceto_filter.posicion_a, "THEN");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_then = crearTerceto(&terceto_filter);

			// cada vez que entra al THEN, aumentamos el indice en uno
			strcpy(terceto_filter.posicion_a, "+");
			strcpy(terceto_filter.posicion_b, __FILTER_INDEX);
			strcpy(terceto_filter.posicion_c, "1");
			p_terceto_filter_index = crearTerceto(&terceto_filter);
			strcpy(terceto_filter.posicion_a, ":=");
			strcpy(terceto_filter.posicion_b, __FILTER_INDEX);
			strcpy(terceto_filter.posicion_c, normalizarPunteroTerceto(p_terceto_filter_index));
			crearTerceto(&terceto_filter);

		} PARENTESIS_ABRE condicion_filter COMA CORCHETE_ABRE {
			info_cola_t terceto;

			// agregar terceto inicio de lista de variables
			strcpy(terceto_filter.posicion_a, "LISTA");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_lista = crearTerceto(&terceto_filter);	

			// la primera condición de un AND, salta directo a la LISTA del FILTER, si es falsa
			// leer terceto con el salto de la comparacion del AND
			if(sacar_de_pila(&comparaciones_and, &comparacion_and) != PILA_VACIA) {
				leerTerceto(comparacion_and.numero_terceto, &terceto);
				// asignar al operador lógico el terceto al que debe saltar
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_filter_lista));
				modificarTerceto(comparacion_and.numero_terceto, &terceto);
			}

			// modificar el terceto que salta a la lista de variables
			// ya que ahora sabemos la posición que empieza la lista
			leerTerceto(p_terceto_filter_salto_lista, &terceto);
			strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_filter_lista));
			modificarTerceto(p_terceto_filter_salto_lista, &terceto);

			// empezamos a agregar ID al código intermedio
			// desde el listado de variables de la sentencia filter 
			_filter_index = 0;
			// inicializar puntero a comparación de variables
			p_terceto_filter_salto_id_siguiente = -1;
		} lista_variables_filter CORCHETE_CIERRA PARENTESIS_CIERRA {
			info_cola_t terceto;

			strcpy(terceto_filter.posicion_a, "ENDFILTER");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_fin = crearTerceto(&terceto_filter);

			// acá salta si ya evaluamos todas las variables y ninguna cumple la condición
			leerTerceto(p_terceto_filter_salto_id_siguiente, &terceto);
			strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_filter_fin));
			modificarTerceto(p_terceto_filter_salto_id_siguiente, &terceto);

			// acá se salta si evaluamos una variable y cumple la condición
			// por cada comparación que se haga en la condición
			int compraciones_condicion = 1;
			while(compraciones_condicion) {
				compraciones_condicion--;
				// desapilar y escribir la posición a la que se debe saltar 
				// si no se cumple la condición del if
				sacar_de_pila(&comparaciones, &comparador);
				leerTerceto(comparador.numero_terceto, &terceto);
				if (strcmp(terceto.posicion_b, "OR") == 0) {
					// si es una condición OR tiene más comparaciones para desapilar
					compraciones_condicion++;
				}
				// asignar al operador (por ejemplo un "BNE") el terceto al que debe saltar
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_filter_fin));
				modificarTerceto(comparador.numero_terceto, &terceto);				
			}
		}
		;

	ciclo:
		REPEAT {
			// apilar el inicio repeat para poder saltar a esta posición
			// cuando termina el bucle
			// se apila porque pueden haber REPEAT anidados
			strcpy(terceto_repeat.posicion_a, yytext);
			strcpy(terceto_repeat.posicion_b, "_");
			strcpy(terceto_repeat.posicion_c, "_");
			inicio_repeat.numero_terceto = crearTerceto(&terceto_repeat);
			poner_en_pila(&repeats, &inicio_repeat);
		} PARENTESIS_ABRE condicion PARENTESIS_CIERRA {
			// acá salta si se cumple la primer condición de un OR
			info_cola_t terceto;

			// inicio del programa del IF
			strcpy(terceto_repeat.posicion_a, "THEN");
			strcpy(terceto_repeat.posicion_b, "_");
			strcpy(terceto_repeat.posicion_c, "_");
			p_terceto_repeat_then = crearTerceto(&terceto_repeat);
			// la primera condición de un OR, salta directo al THEN del IF, si es verdadera
			// leer terceto con el salto de la comparacion del OR
			if(sacar_de_pila(&comparaciones_or, &comparacion_or) != PILA_VACIA) {
				leerTerceto(comparacion_or.numero_terceto, &terceto);
				// asignar al operador lógico el terceto al que debe saltar
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_repeat_then));
				modificarTerceto(comparacion_or.numero_terceto, &terceto);
			}
		} programa ENDREPEAT {
			info_cola_t terceto;

			// el ciclo vuelve a chekear la condición siempre que termina el programa del REPEAT
			strcpy(terceto_repeat.posicion_a, "BRA");
			sacar_de_pila(&repeats, &inicio_repeat);
			strcpy(terceto_repeat.posicion_b, normalizarPunteroTerceto(inicio_repeat.numero_terceto));
			strcpy(terceto_repeat.posicion_c, "_");
			crearTerceto(&terceto_repeat);

			// acá salta si no se cumple cualquier condición de un AND
			// o si no se cumple la segunda condición de un OR
			// o si no se cumple una comparación simple (con o sin NOT)
			strcpy(terceto_repeat.posicion_a, yytext);
			strcpy(terceto_repeat.posicion_b, "_");
			strcpy(terceto_repeat.posicion_c, "_");
			p_terceto_endrepeat = crearTerceto(&terceto_repeat);

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
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_endrepeat));
				modificarTerceto(comparador.numero_terceto, &terceto);				
			}
		}
		;

	salida:
		PRINT ID {
			strcpy(terceto_print.posicion_a, "PRINT");
			strcpy(terceto_print.posicion_b, yytext);
			strcpy(terceto_print.posicion_c, "_");
			crearTerceto(&terceto_print);
		}
		;

	salida:
		PRINT CONSTANTE_STRING {
			strcpy(terceto_print.posicion_a, "PRINT");
			strcpy(terceto_print.posicion_b, yytext);
			strcpy(terceto_print.posicion_c, "_");
			crearTerceto(&terceto_print);
		}
		;

	entrada:
		READ ID {
			strcpy(terceto_print.posicion_a, "READ");
			strcpy(terceto_print.posicion_b, yytext);
			strcpy(terceto_print.posicion_c, "_");
			crearTerceto(&terceto_print);
		}
		;

	seleccion:
		IF {
			strcpy(terceto_if.posicion_a, yytext);
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
			crearTerceto(&terceto_if);
		} PARENTESIS_ABRE condicion PARENTESIS_CIERRA {
			info_cola_t terceto;

			// inicio del programa del IF
			strcpy(terceto_if.posicion_a, "THEN");
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
			p_terceto_if_then = crearTerceto(&terceto_if);
			// la primera condición de un OR, salta directo al THEN del IF, si es verdadera
			// leer terceto con el salto de la comparacion del OR
			if(sacar_de_pila(&comparaciones_or, &comparacion_or) != PILA_VACIA) {
				leerTerceto(comparacion_or.numero_terceto, &terceto);
				// asignar al operador lógico el terceto al que debe saltar
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_if_then));
				modificarTerceto(comparacion_or.numero_terceto, &terceto);
			}
		} programa seleccion_fin_then
		;

	seleccion_fin_then:
		ENDIF {
			info_cola_t terceto;

			strcpy(terceto_if.posicion_a, yytext);
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
			p_terceto_fin_then = crearTerceto(&terceto_if);

			// por cada comparación que se haga en la condición
			int compraciones_condicion = 1;
			while(compraciones_condicion) {
				compraciones_condicion--;
				// desapilar y escribir la posición a la que se debe saltar 
				// si no se cumple la condición del if
				if(sacar_de_pila(&comparaciones, &comparador) != PILA_VACIA) {
					leerTerceto(comparador.numero_terceto, &terceto);
					if (strcmp(terceto.posicion_b, "AND") == 0) {
						// si es una condición AND tiene más comparaciones para desapilar
						compraciones_condicion++;
					}
					// asignar al operador (por ejemplo un "BNE") el terceto al que debe saltar
					strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_fin_then));
					modificarTerceto(comparador.numero_terceto, &terceto);
				}				
			}
		}
		;

	seleccion_fin_then:
		ELSE {
			info_cola_t terceto;

			// al finalizar el "THEN" se salta incondicionalmente al ENDIF
			strcpy(terceto_if.posicion_a, "BRA");
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
			salto_incondicional.numero_terceto = crearTerceto(&terceto_if);
			poner_en_pila(&saltos_incondicionales, &salto_incondicional);

			// agregar terceto con el "ELSE"
			strcpy(terceto_if.posicion_a, yytext);
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
			p_terceto_fin_then = crearTerceto(&terceto_if);

			char aux[5];
			itoa(p_terceto_fin_then, aux, 10);
			strcat(terceto_if.posicion_a, aux);

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
			}
		} programa ENDIF {
			info_cola_t terceto;

			strcpy(terceto_if.posicion_a, yytext);
			strcpy(terceto_if.posicion_b, "_");
			strcpy(terceto_if.posicion_c, "_");
		  p_terceto_endif =	crearTerceto(&terceto_if);

			sacar_de_pila(&saltos_incondicionales, &salto_incondicional);
			leerTerceto(salto_incondicional.numero_terceto, &terceto);
			strcpy(terceto.posicion_b, normalizarPunteroTerceto(p_terceto_endif));
			modificarTerceto(salto_incondicional.numero_terceto, &terceto);
		}
		;

	condicion:
		comparacion {			
			// crear terceto con el "CMP"			
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar el terceto por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion:
		comparacion {			
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		} AND comparacion {
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			// si es un AND lo indicamos para saber que la condición tiene doble comparación
			strcpy(terceto_operador_logico.posicion_b, "AND"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion: 
		comparacion {			
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			// como es un OR debemos invertir el operador ya que por true, va directo al "THEN" del "IF"
			// sin evaluar la segunda condición
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparacion_or.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones_or, &comparacion_or);
		} OR comparacion {			
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion:
		NOT comparacion {
			// es igual que la comparación sin el NOT
			// pero llamando a "invertirOperadorLogico"

			// crear terceto con el "CMP"			
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar el terceto por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	comparacion: 
		en_lista {
			strcpy(terceto_cmp.posicion_a,"RETURN_TRUE");
			strcpy(terceto_cmp.posicion_b,"_");
			strcpy(terceto_cmp.posicion_c,"_");
			crearTerceto(&terceto_cmp);			
			// al finalizar la lista, tiene que comprar la variable de compilador con el 
			// return del INLIST osea __INLIST_RETURN con 1, si son distintos sale del IF
			strcpy(terceto_cmp.posicion_a, "CMP");
			strcpy(terceto_cmp.posicion_b, __INLIST_RETURN);
			strcpy(terceto_cmp.posicion_c, "1");
			strcpy(terceto_operador_logico.posicion_a, "BNE");
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BNE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} MENOR_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BGE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} MENOR_IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BGT");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} MAYOR_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BLE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} MAYOR_IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BLT");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion:
		expresion {
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} DISTINTA_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BEQ");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	condicion_filter:
		comparacion_filter {			
			// agregar el operador filter a la ts
			strcpy(d.clave, __FILTER_OPERANDO);
			strcpy(d.tipodato, "Undefined");
			insertar_en_ts(&l_ts, &d);					
			// crear terceto con el "CMP"			
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar el terceto por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion_filter:
		comparacion_filter {
			// agregar el operador filter a la ts
			strcpy(d.clave, __FILTER_OPERANDO);
			strcpy(d.tipodato, "Undefined");
			insertar_en_ts(&l_ts, &d);
			
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparacion_and.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones_and, &comparacion_and);
		} AND comparacion_filter {
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			// si es un AND lo indicamos para saber que la condición tiene doble comparación
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "AND"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion_filter:
		comparacion_filter {			
			// agregar el operador filter a la ts
			strcpy(d.clave, __FILTER_OPERANDO);
			strcpy(d.tipodato, "Undefined");
			insertar_en_ts(&l_ts, &d);

			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		} OR comparacion_filter {
			// crear terceto con el "CMP"
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_a, invertirOperadorLogico(terceto_operador_logico.posicion_a));
			strcpy(terceto_operador_logico.posicion_b, "OR"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	condicion_filter:
		NOT comparacion_filter {
			// es igual que la comparación sin el NOT
			// pero sin llamar a "invertirOperadorLogico"

			// agregar el operador filter a la ts
			strcpy(d.clave, __FILTER_OPERANDO);
			strcpy(d.tipodato, "Undefined");
			insertar_en_ts(&l_ts, &d);					
			// crear terceto con el "CMP"			
			crearTerceto(&terceto_cmp);
			// crear terceto del operador de la comparación
			strcpy(terceto_operador_logico.posicion_a, terceto_operador_logico.posicion_a);
			strcpy(terceto_operador_logico.posicion_b, "_"); 
			strcpy(terceto_operador_logico.posicion_c, "_");
			// apilamos la posición del operador, para luego escribir a donde debe saltar el terceto por false
			comparador.numero_terceto = crearTerceto(&terceto_operador_logico);
			poner_en_pila(&comparaciones, &comparador);
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BNE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} MENOR_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BGE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} MENOR_IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BGT");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} MAYOR_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BLE");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} MAYOR_IGUAL_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BLT");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	comparacion_filter:
		OPERANDO_FILTER {
			// reemplazar el "_" de la sentencia filter, por una variable del compilador
			strcpy(terceto_filter.posicion_a, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_operando = crearTerceto(&terceto_filter);
			// agregar operando al código intermedio
			strcpy(terceto_cmp.posicion_b, normalizarPunteroTerceto(p_terceto_filter_operando));
		} DISTINTA_A {
			// guardamos el operador para incertarlo luego de crear el terceto del "CMP"
			strcpy(terceto_operador_logico.posicion_a, "BEQ");
			strcpy(terceto_cmp.posicion_a, "CMP");
		} expresion {
			// terceto del "CMP"
			strcpy(terceto_cmp.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
		}
		;

	lista_variables_filter:
		variable_filter {
			info_cola_t terceto;
			char str_filter_index[12];
			sprintf(str_filter_index, "%d", 	_filter_index++);

			strcpy(terceto_inlist.posicion_a, "COMPARACION");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);

			// la última variable salta al FIN del FILTER por falso
			strcpy(terceto_filter.posicion_a, "CMP");
			strcpy(terceto_filter.posicion_b, __FILTER_INDEX);
			strcpy(terceto_filter.posicion_c, str_filter_index);
			p_terceto_filter_cmp = crearTerceto(&terceto_filter);
			if(p_terceto_filter_salto_id_siguiente != -1) {
				leerTerceto(p_terceto_filter_salto_id_siguiente, &terceto);
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(--p_terceto_filter_cmp));
				modificarTerceto(p_terceto_filter_salto_id_siguiente, &terceto);
			}
			strcpy(terceto_filter.posicion_a, "BNE");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_salto_id_siguiente = crearTerceto(&terceto_filter);
			// asignamos al operando del filter (osea el "_") el valor de 
			// la variable que vamos a evalular con la condición del filter
			strcpy(terceto_filter.posicion_a, ":=");
			strcpy(terceto_filter.posicion_b, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_c, yytext);
			crearTerceto(&terceto_filter);
			// vamos a la sentencia de la condición para evaluarla
			strcpy(terceto_filter.posicion_a, "BRA");
			strcpy(terceto_filter.posicion_b, normalizarPunteroTerceto(p_terceto_filter_then));
			strcpy(terceto_filter.posicion_c, "_");
			crearTerceto(&terceto_filter);
		}
		;

	lista_variables_filter:
		lista_variables_filter COMA	variable_filter {
			info_cola_t terceto;
			char str_filter_index[12];
			sprintf(str_filter_index, "%d", 	_filter_index++);

			strcpy(terceto_inlist.posicion_a, "COMPARACION");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			crearTerceto(&terceto_inlist);

			// preguntamos si hay que evaluar esta variable en la condición del filter
			// para esto nos valemos del valor que tiene el "_filter_index"
			strcpy(terceto_filter.posicion_a, "CMP");
			strcpy(terceto_filter.posicion_b, __FILTER_INDEX);
			strcpy(terceto_filter.posicion_c, str_filter_index);
			p_terceto_filter_cmp = crearTerceto(&terceto_filter);
			if(p_terceto_filter_salto_id_siguiente != -1) {
				// si la comparación falsa, quiere decir que tengo que analizar el siguiente ID
				leerTerceto(p_terceto_filter_salto_id_siguiente, &terceto);
				strcpy(terceto.posicion_b, normalizarPunteroTerceto(--p_terceto_filter_cmp));
				modificarTerceto(p_terceto_filter_salto_id_siguiente, &terceto);
			}
			strcpy(terceto_filter.posicion_a, "BNE");
			strcpy(terceto_filter.posicion_b, "_");
			strcpy(terceto_filter.posicion_c, "_");
			p_terceto_filter_salto_id_siguiente = crearTerceto(&terceto_filter);
			// asignamos al operando del filter (osea el "_") el valor de 
			// la variable que vamos a evalular con la condición del filter
			strcpy(terceto_filter.posicion_a, ":=");
			strcpy(terceto_filter.posicion_b, __FILTER_OPERANDO);
			strcpy(terceto_filter.posicion_c, yytext);
			crearTerceto(&terceto_filter);
			// vamos a la sentencia de la condición para evaluarla
			strcpy(terceto_filter.posicion_a, "BRA");
			strcpy(terceto_filter.posicion_b, normalizarPunteroTerceto(p_terceto_filter_then));
			strcpy(terceto_filter.posicion_c, "_");
			crearTerceto(&terceto_filter);
		}
		;

	variable_filter:
		ID
		;

	lista_expresiones_inlist:
		expresion {
			// comprar el puntero a expresión con el del ID
			strcpy(terceto_inlist.posicion_a, "CMP");
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(p_terceto_inlist_id));
			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			crearTerceto(&terceto_inlist);
			strcpy(terceto_inlist.posicion_a, "BEQ");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			// apilar posición, cuando se a donde salta por iguales, desapilo todas
			inlist_comparacion.numero_terceto = crearTerceto(&terceto_inlist);
			poner_en_pila(&inlist_comparaciones, &inlist_comparacion);
		}
		;

	lista_expresiones_inlist:
		lista_expresiones_inlist PUNTO_Y_COMA expresion {
			// comprar el puntero a expresión con el del ID
			strcpy(terceto_inlist.posicion_a, "CMP");
			strcpy(terceto_inlist.posicion_b, normalizarPunteroTerceto(p_terceto_inlist_id));
			strcpy(terceto_inlist.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			crearTerceto(&terceto_inlist);
			strcpy(terceto_inlist.posicion_a, "BEQ");
			strcpy(terceto_inlist.posicion_b, "_");
			strcpy(terceto_inlist.posicion_c, "_");
			// apilar posición, cuando se a donde salta por iguales, desapilo todas
			inlist_comparacion.numero_terceto = crearTerceto(&terceto_inlist);
			poner_en_pila(&inlist_comparaciones, &inlist_comparacion);
		}
		;

	asignacion:
		ID {
			strcpy(terceto_asignacion.posicion_b, yytext);
		} OP_ASIGNACION {
			strcpy(terceto_asignacion.posicion_a, yytext);
		} expresion {
			strcpy(terceto_asignacion.posicion_c, normalizarPunteroTerceto(p_terceto_expresion));
			// crea un terceto con la forma (":=", ID, [10])
			// donde [10] es un ejemplo de p_terceto_expresion
			crearTerceto(&terceto_asignacion);
		}
		;
	
	expresion:
		expresion {
			strcpy(terceto_expresion.posicion_b, normalizarPunteroTerceto(p_terceto_expresion));
		} SUMA {			
			strcpy(terceto_expresion.posicion_a, yytext);
		} termino {
			strcpy(terceto_expresion.posicion_c, normalizarPunteroTerceto(p_terceto_termino));
			p_terceto_expresion = crearTerceto(&terceto_expresion);
		}
		;

	expresion:
		termino {
			p_terceto_expresion = p_terceto_termino;
		}
		;
	
	asignacion_especial_mas:
		 ID {
			strcpy(terceto_asignacion_especial.posicion_b, yytext);
		} MAS_I {
			strcpy(terceto_asignacion_especial.posicion_a, yytext);
		} factor {
			printf("%s",yytext);
			 printf("%s",normalizarPunteroTerceto(p_terceto_factor));
			strcpy(terceto_asignacion_especial.posicion_c, yytext);
			// crea un terceto con la forma (":=", ID, [10])
			// donde [10] es un ejemplo de p_terceto_expresion
			crearTerceto(&terceto_asignacion_especial);
		}
		;
	
	asignacion_especial_menos:
		 ID {
			strcpy(terceto_asignacion_especial.posicion_b, yytext);
		} MENOS_I {
			strcpy(terceto_asignacion_especial.posicion_a, yytext);
		} factor {
			 printf("%s",normalizarPunteroTerceto(p_terceto_factor));
			strcpy(terceto_asignacion_especial.posicion_c, yytext);
			// crea un terceto con la forma (":=", ID, [10])
			// donde [10] es un ejemplo de p_terceto_expresion
			crearTerceto(&terceto_asignacion_especial);
		}
		;
	
	asignacion_especial_mul:
		 ID {
			printf("%s",normalizarPunteroTerceto(p_terceto_factor));
				strcpy(terceto_asignacion_especial.posicion_b, yytext);
		} MUL_I {
			 printf("%s",yytext);
			strcpy(terceto_asignacion_especial.posicion_a, yytext);
		} factor {
			 printf("%s",normalizarPunteroTerceto(p_terceto_factor));
			strcpy(terceto_asignacion_especial.posicion_c, yytext);
			// crea un terceto con la forma (":=", ID, [10])
			// donde [10] es un ejemplo de p_terceto_expresion
			crearTerceto(&terceto_asignacion_especial);
		}
		;

	asignacion_especial_div:
		 ID {
			printf("%s",normalizarPunteroTerceto(p_terceto_factor));
				strcpy(terceto_asignacion_especial.posicion_b, yytext);
		} DIV_I {
			 printf("%s",yytext);
			strcpy(terceto_asignacion_especial.posicion_a, yytext);
		} factor {
			 printf("%s",normalizarPunteroTerceto(p_terceto_factor));
			strcpy(terceto_asignacion_especial.posicion_c, yytext);
			// crea un terceto con la forma (":=", ID, [10])
			// donde [10] es un ejemplo de p_terceto_expresion
			crearTerceto(&terceto_asignacion_especial);
		}
		;
	
	termino:
		termino {
			strcpy(terceto_termino.posicion_b, normalizarPunteroTerceto(p_terceto_termino));
		} MULTIPLICACION {
			strcpy(terceto_termino.posicion_a, yytext);
		} factor {
			strcpy(terceto_termino.posicion_c, normalizarPunteroTerceto(p_terceto_factor));
			p_terceto_termino = crearTerceto(&terceto_termino); 
		}
		;
	
	termino:
		factor {
			p_terceto_termino = p_terceto_factor;
		}
		;

	factor:
		PARENTESIS_ABRE expresion PARENTESIS_CIERRA {
			p_terceto_factor = p_terceto_expresion;
		}
		;

	factor:
		ID {
			strcpy(terceto_factor.posicion_a, yytext);
			strcpy(terceto_factor.posicion_b, "_");
			strcpy(terceto_factor.posicion_c, "_");
			p_terceto_factor = crearTerceto(&terceto_factor);
		}
		;

	factor:
		CONSTANTE_STRING {
			strcpy(terceto_factor.posicion_a, yytext);
			strcpy(terceto_factor.posicion_b, "_");
			strcpy(terceto_factor.posicion_c, "_");
			p_terceto_factor = crearTerceto(&terceto_factor);

			//strcpy(cadena, yytext);
			strcpy(d.clave, guion_cadena(charReplace(yytext, ' ', '_')));
			strcpy(d.valor, yytext);
			strcpy(d.tipodato, "const String");
			sprintf(d.longitud, "%d", strlen(yytext)-2);
			insertar_en_ts(&l_ts, &d);
		}
		;

	factor:
		CONSTANTE_REAL {
			strcpy(terceto_factor.posicion_a, yytext);
			strcpy(terceto_factor.posicion_b, "_");
			strcpy(terceto_factor.posicion_c, "_");
			p_terceto_factor = crearTerceto(&terceto_factor);

			strcpy(d.valor, yytext);
			strcpy(d.clave, guion_cadena(charReplace(yytext, '.', '_')));
			strcpy(d.tipodato, "const Float");
			insertar_en_ts(&l_ts, &d);
		}
		;

	factor:
		CONSTANTE_ENTERA {
			strcpy(terceto_factor.posicion_a, yytext);
			strcpy(terceto_factor.posicion_b, "_");
			strcpy(terceto_factor.posicion_c, "_");
			p_terceto_factor = crearTerceto(&terceto_factor);

			strcpy(d.clave, guion_cadena(yytext));
			strcpy(d.valor, yytext);
			strcpy(d.tipodato, "const Integer");
			insertar_en_ts(&l_ts, &d);
		}
		;
	
%%

int main(int argc, char *argv[]) {
	printf("\n");
	printf("==============================================================\n");
	printf("analisis-comienza\n");
	printf("==============================================================\n");
	if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("ERROR: abriendo archivo [%s]\n", argv[1]);
	} else {
		clear_ts();
		clear_intermedia();
		crear_lista(&l_ts);
		crear_cola(&cola_tipo_id);
		crear_cola(&cola_terceto);
		crear_pila(&comparaciones);
		crear_pila(&comparaciones_or);
		crear_pila(&comparaciones_and);
		crear_pila(&saltos_incondicionales);
		crear_pila(&repeats);
		crear_pila(&inlist_comparaciones);
		yyparse();
		fclose(yyin);
		crear_ts(&l_ts);
		crear_intermedia(&cola_terceto);
		crear_assembler(&l_ts);
	}
	printf("==============================================================\n");
	printf("analisis-finaliza\n");
	printf("==============================================================\n");
	return 0;
}

void validar_id(char *id) {
	int length = 0;
	while(id[length] != '\0') {			
		length++;
	}
	// mayor a 32 se pone porque las comillas de la constante no cuentan para su tamaño
	if(length > MAX_STRING_LENGTH) {
		sprintf(error_mensaje, "el identificador %s supera los [%d] caracteres permitidos\n", id, MAX_STRING_LENGTH);
		yyerror(error_mensaje);
	}
}

void crear_lista(lista_t *p) {
    *p=NULL;
}
void crear_lista_intermedia(t_lista_intermedia *p) {
    *p=NULL;
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

int comparar(info_t *d1, info_t *d2) {
	return strcmp(d1->clave,d2->clave);
}

char *guion_cadena(char cad[TAM]) {
	char guion[TAM+1]="_" ;
	strcat(guion,cad);
	strcpy(cadena,guion);
	return cadena;
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

void guardar_lista(lista_t *p, FILE *arch) {
	// titulos
	fprintf(arch,"%-35s %-16s %-35s %-35s", "NOMBRE", "TIPO DE DATO", "VALOR", "LONGITUD");
	// datos
	while(*p) {
		fprintf(arch,"\n%-35s %-16s %-35s %-35s", (*p)->info.clave, (*p)->info.tipodato, (*p)->info.valor, (*p)->info.longitud);
		p=&(*p)->sig;
	}
}

// limpiar una ts de una ejecución anterior
void clear_ts() {
	FILE *arch=fopen("ts.txt","w");
	fclose(arch);
}

void crear_ts(lista_t *l_ts) {
	info_t aux;
	//FILE *arch=fopen("ts.txt","w");
	printf("\n");
	printf("creando tabla de simbolos...\n");
	//guardar_lista(l_ts, arch);
	//fclose(arch);
	printf("tabla de simbolos creada\n");
}

int insertar_en_ts(lista_t *l_ts, info_t *d) {
	insertar_en_orden(l_ts,d);
	sacar_repetidos(l_ts,d,comparar,0);
	strcpy(d->clave,"\0");
	strcpy(d->tipodato,"\0");
	strcpy(d->valor,"\0");
	strcpy(d->longitud,"\0");
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
		if(strcmp(info_terceto.posicion_a, "THEN") == 0 || strcmp(info_terceto.posicion_a, "ELSE") == 0 ||
		 strcmp(info_terceto.posicion_a, "ENDIF") == 0 || strcmp(info_terceto.posicion_a, "REPEAT") == 0 ||
		  strcmp(info_terceto.posicion_a, "ENDREPEAT") == 0 || strcmp(info_terceto.posicion_a, "LISTA") == 0 ||
		   strcmp(info_terceto.posicion_a, "ENDINLIST") == 0 || strcmp(info_terceto.posicion_a, "ENDFILTER") == 0
		   || strcmp(info_terceto.posicion_a, "COMPARACION") == 0 || strcmp(info_terceto.posicion_a, "RETURN_TRUE") == 0) {

			printf("[%d](%s_%d,%s,%s)\n", numero,info_terceto.posicion_a, numero, info_terceto.posicion_b ,info_terceto.posicion_c);
			fprintf(arch,"[%d](%s_%d,%s,%s)\n", numero, info_terceto.posicion_a, numero, info_terceto.posicion_b ,info_terceto.posicion_c);
			numero++;
		}
		else {
			printf("[%d](%s,%s,%s)\n", numero,info_terceto.posicion_a ,info_terceto.posicion_b ,info_terceto.posicion_c);
			fprintf(arch,"[%d](%s,%s,%s)\n", numero++, info_terceto.posicion_a ,info_terceto.posicion_b ,info_terceto.posicion_c);
		}
	}
	cant_total_tercetos=numero;
}

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
		
		if (strcmp(info_terceto.posicion_a,"IF")==0 || strcmp(info_terceto.posicion_a,"FILTER")==0 || strcmp(info_terceto.posicion_a,"INLIST")==0)
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

	FILE *arch2=fopen("ts.txt","w");
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

	if (strcmp((*p)->info.clave, "__INLIST_RETURN") != 0 && strcmp((*p)->info.clave, "__FILTER_INDEX") != 0 )

	while(*p) {
		// Variables
		if (strcmp((*p)->info.tipodato, "Integer") == 0) {
			if (strcmp((*p)->info.clave, "__INLIST_RETURN") != 0 && strcmp((*p)->info.clave, "__FILTER_INDEX") != 0 ) {
				char aux[TAM+1];
				sprintf(aux, "_%s", (*p)->info.clave);
				strcpy((*p)->info.clave, aux);
			}
				fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
		}
		if (strcmp((*p)->info.tipodato, "Float") == 0) {
			if (strncmp("_@aux", (*p)->info.clave, 5) != 0) {
				char aux[TAM+1];
				sprintf(aux, "_%s", (*p)->info.clave);
				strcpy((*p)->info.clave, aux);
			}
				fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
		}
		if (strcmp((*p)->info.tipodato, "String") == 0) {
			char aux[TAM+1];
			sprintf(aux, "_%s", (*p)->info.clave);
			strcpy((*p)->info.clave, aux);
			fprintf(asmFile,"%-35s DB MAXTEXTSIZE dup (?)\n", (*p)->info.clave);
		}
		if (strcmp((*p)->info.tipodato, "Undefined") == 0)
			fprintf(asmFile,"%-35s DD (?)\n", (*p)->info.clave);
		
		// Constantes
		if (strcmp((*p)->info.tipodato, "const Integer") == 0)
			fprintf(asmFile,"%-35s DD %-10s\n", (*p)->info.clave, (*p)->info.valor);
		if (strcmp((*p)->info.tipodato, "const Float") == 0)
			fprintf(asmFile,"%-35s DD %-10s\n", (*p)->info.clave, (*p)->info.valor);
		if (strcmp((*p)->info.tipodato, "const String") == 0) {
			char aux[TAM];
			strncpy(aux, ((*p)->info.valor) + 1, strlen((*p)->info.valor) - 2);
			aux[strlen((*p)->info.valor)-2] = '\0';
			sprintf((*p)->info.clave, "_%s", aux);
			fprintf(asmFile,"%-35s DB %-10s, %s dup (?)\n", (*p)->info.clave, (*p)->info.valor, (*p)->info.longitud);
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

// recibe un número de terceto y devuelve la info
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
		if(strcmp((*p)->info.posicion_a,"PRINT")==0 )
		{
			fprintf(arch,"DisplayString _%s\n",charReplace((*p)->info.posicion_b,' ','_'));
		}
		if(strncmp((*p)->info.posicion_a,"REPEAT",6)==0 || strncmp((*p)->info.posicion_a,"RETURN_FALSE",12)==0 || strncmp((*p)->info.posicion_a,"RETURN_TRUE",11)==0 || strncmp((*p)->info.posicion_a,"COMPARACION",11)==0)
		{
			fprintf(arch,"%s:\n",(*p)->info.posicion_a);
		}
		if(strncmp((*p)->info.posicion_a,"THEN",4)==0 || strncmp((*p)->info.posicion_a,"ELSE",4)==0 || strncmp((*p)->info.posicion_a,"ENDIF",5)==0 || strncmp((*p)->info.posicion_a,"LISTA",5)==0 || strncmp((*p)->info.posicion_a,"ENDFILTER",9)==0 || strncmp((*p)->info.posicion_a,"ENDREPEAT",9)==0 || strncmp((*p)->info.posicion_a,"ENDINLIST",9)==0)
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
		if(strcmp((*p)->info.posicion_a,"READ")==0)
		{
			fprintf(arch,"GetInteger %s\n",(*p)->info.posicion_b);
		}
		if(strcmp((*p)->info.posicion_a,"+=")==0)
		{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}
			fprintf(arch,"fld %s\nfld %s\nfadd\nfstp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_b);
		}
			if(strcmp((*p)->info.posicion_a,"*=")==0)
		{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}
			fprintf(arch,"fild %s\nfild %s\nfmul\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_b);
		}
			if(strcmp((*p)->info.posicion_a,"-=")==0)
		{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}
			fprintf(arch,"fild %s\nfild %s\nfsub\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_b);
		}
			if(strcmp((*p)->info.posicion_a,"/=")==0)
		{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}
			fprintf(arch,"fild %s\nfild %s\nfdiv\nfistp %s\n",(*p)->info.posicion_b,(*p)->info.posicion_c,(*p)->info.posicion_b);
		}
		if(strcmp((*p)->info.posicion_a,":=")==0)
		{
			char * pt = strrchr((*p)->info.posicion_c,'"');
			if(pt){*pt='\0';}
			fprintf(arch,"fild %s\nfistp %s\n",charReplace((*p)->info.posicion_c,' ','_'),(*p)->info.posicion_b);
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