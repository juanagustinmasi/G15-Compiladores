%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
#include <string.h>
#include <ctype.h>

	int yystopparser=0;
	FILE  *yyin;
	char *yyltext;
	char *yytext;
  char mensajeDeError[200];
  FILE *archivoTablaDeSimbolos;


/* CONSTANTES*/
#define TAM_NOMBRE 32	/* Limite tamaño nombre (sumar 1 para _ ) */
#define CteString "CTE_STRING"
#define CteInt "CTE_INT"
#define CteReal "CTE_REAL"
#define VAR_FILTER "@Filter"
#define TIPO_FILTER "REAL"
#define T_REAL 1
#define T_ENTERO 2
#define T_CADENA 3



/*  TABLA DE SIMBOLOS  */
  	typedef struct{
		char nombre[100];
		char tipo[11];
		char valor[100];
		int longitud;
	} struct_tabla_de_simbolos;

	struct_tabla_de_simbolos tablaDeSimbolos[200];
   
    typedef struct
    {
    char tipo[11];
    char valor[100]; 
    } struct_almacenar_id;

    struct_tabla_de_simbolos tablaDeSimbolos[200];
    struct_almacenar_id vectorAlmacenamiento[10];


    int yylex();
    int yyerror();

void error(char *mensaje);
void guardarTabla(void);
void agregarConstante(char*,char*);
int buscarCte(char* , char*);
void validarVariableDeclarada(char* nombre);
void guardarTipo(char * tipoVariable);
void guardarEnVectorTablaSimbolos(int opc, char * cad);
void acomodarPunterosTS();
void quitarDuplicados();
void copiarCharEn(char **, char*);

	int cantidadTokens = 0;
	int i=0; 
	int j=0;
	int cant_elementos=0;
	int min=0;
	int pos_td=0;
	int pos_cv=0;
	int cant_variables=0;
	int cant_tipo_dato=0; 
	int diferencia=0;
	int cant_ctes=0;
	int finBloqueDeclaraciones=0;

	char tipoVariableActual[20];

	char* operadorAux;
	char idAux[20];


%}

%union {
	int int_val;
	double float_val;
	char *str_val;
}


%start start_programa


%token WHILE
OP_IF
ELSE
ENDIF
OP_AND
OP_OR
OP_NOT
TIPO_REAL
TIPO_CADENA
TIPO_ENTERO
CONST
PRINT
SCAN
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
ESPACIO
GUION_BAJO
AS
REAL
ENTERO
ID
CADENA
 



%%

start_programa : programa
                    { 
                        printf("\n Compilacion exitosa\n");
                    };



programa : bloque_declaracion  bloque_programa
                    { 
                        printf("Programa OK\n\n");
                     };

bloque_declaracion: DIM lista_definiciones AS lista_tipo_dato 
                     {
                       finBloqueDeclaraciones=1;
                        quitarDuplicados(); 
                        printf("bloque_definiciones OK\n");
                        cant_ctes=cantidadTokens;	
                     };


lista_definiciones: lista_definiciones definicion 
                    {
                        printf("lista_definiciones definicion OK\n");
                    } 
                    | definicion 
                                {
                                    printf("lista_definiciones->definicion OK\n");
                                }


definicion: MENOR  lista_ids MAYOR AS  MENOR lista_tipo_dato MAYOR
                    {
                        printf("definicion OK\n");
                    };




tipo_dato: 
  TIPO_ENTERO       
    {
      guardarTipo("ENTERO");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_ENTERO en tipo_variable OK\n");
    }
  | TIPO_REAL 
    {
      guardarTipo("REAL");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_REAL en tipo_variable OK\n");
    }
  | TIPO_CADENA
    {
      guardarTipo("CADENA");
      guardarEnVectorTablaSimbolos(1,tipoVariableActual);
      printf("TIPO_CADENA en tipo_variable OK\n");
    }

lista_tipo_dato: lista_tipo_dato COMA tipo_dato | tipo_dato

lista_ids: 
  lista_ids COMA ID 
    {
      printf("%s\n", yylval.str_val);
      guardarEnVectorTablaSimbolos(2,yylval.str_val);
      printf("ID en lista_ids OK\n");
    }
  | ID
    {
      printf("%s\n", yylval.str_val);
      guardarEnVectorTablaSimbolos(2,yylval.str_val);
      printf("ID en lista_ids OK\n");
    }
  | lista_ids COMA CADENA
    {
      guardarEnVectorTablaSimbolos(2,yylval.str_val);
      printf("lista_ids -> lista_ids COMA UNA CADENA\n , cadena: %s\n", yylval.str_val);
    }
	
  | TIPO_CADENA
    {
        guardarEnVectorTablaSimbolos(2,yylval.str_val);
        printf("reconoci una cadena: %s\n", yylval.str_val);
    }
	


bloque_programa : bloque_programa sentencia 
        {
          printf("bloque_programa -> bloque_programa sentencia OK \n\n");
        }
        | sentencia 
            {
              printf("bloque_programa -> sentencia OK \n\n");
            }

sentencia : asignacion 	{printf("sentencia -> asignacion OK \n\n");}
| bloque_condicional	{printf("sentencia -> bloque_condicional OK \n\n");} 
| bloque_iteracion 		{printf("sentencia -> bloque_iteracion OK \n\n");}
//| entrada_datos			{printf("sentencia -> entrada_datos OK \n\n");}
//| salida_datos			{printf("sentencia -> salida_datos OK \n\n");}


asignacion: ID ASIG expresion PUNTO_COMA

expresion:  expresion MAS termino | expresion MENOS termino | termino

termino: termino POR factor | termino DIVIDIDO factor | factor

factor: ID
		|TIPO_ENTERO
		|TIPO_REAL
		|TIPO_CADENA
		|PA expresion PC
		
bloque_iteracion: WHILE condicion bloque_programa  {printf("bloque WHILE OK\n\n");}


bloque_condicional: bloque_if {printf("bloque_condicional\n");}

bloque_if: OP_IF condicion bloque_programa ENDIF | OP_IF condicion  bloque_programa ELSE bloque_programa ENDIF 

condicion: PA comparacion OP_AND comparacion PC 

			| PA comparacion OP_OR comparacion PC
			
			| PA OP_NOT condicion PC 

			| PA comparacion PC 		// condicion simple
			
comparacion : expresion MAYOR expresion
				
			| expresion MENOR expresion
			
			| expresion MAYOR_IGUAL expresion
			
			| expresion MENOR_IGUAL expresion
			
			|expresion IGUAL expresion
			
			|expresion DISTINTO expresion
			





%%



int main(int argc,char *argv[]){

	if ((yyin = fopen(argv[1], "rt")) == NULL){
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
	}else {
		
		yyparse();
    guardarTabla();
		
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


void guardarEnVectorTablaSimbolos(int opc, char * cad){
	if(finBloqueDeclaraciones==0){
		if(opc==1){
			strcpy(tablaDeSimbolos[pos_td].tipo,cad);
			cant_tipo_dato++;
			pos_td++;
		}else{
			strcpy(tablaDeSimbolos[pos_cv].nombre,cad);
			pos_cv++;
			cant_variables++;
		}
	}
}

void guardarTipo(char * tipoVariable) {
	strcpy(tipoVariableActual, tipoVariable);
}

void acomodarPunterosTS(){
	int indice=0;
	if(cant_tipo_dato!=cant_variables){
		if(pos_td<pos_cv){	
			min=pos_td;
			cant_elementos=min;
			pos_td=pos_cv=min;
			diferencia=(cant_variables-cant_tipo_dato);
			indice=min;
			while(diferencia>0){
				strcpy(tablaDeSimbolos[indice].tipo, "");
				strcpy(tablaDeSimbolos[indice].nombre, "");
				diferencia--;
				indice++;
			}
		}else{
			min=pos_cv;
			cant_elementos=min;
			pos_td=pos_cv=min;
			diferencia=(cant_tipo_dato-cant_variables);
			indice=min;
			while(diferencia>0){
				strcpy(tablaDeSimbolos[indice].tipo, "");
				strcpy(tablaDeSimbolos[indice].nombre, "");
				diferencia--;
				indice++;
			}
		}
	}else{
		cant_elementos=pos_cv;
		cant_tipo_dato=cant_variables=0;
	}
}
void quitarDuplicados(){
	for(i=0;i<cant_elementos;i++){
		if(strcmp(tablaDeSimbolos[i].nombre,"@")!=0){
			cantidadTokens++;
			for(j=i+1;j<cant_elementos;j++){
				if(strcmp(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo)==0 && strcmp(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre)==0){		// si los dos son iguales
					strcpy(tablaDeSimbolos[j].tipo, "@");
					strcpy(tablaDeSimbolos[j].nombre, "@");				// doy de baja a todos los proximos que son iguales
				}
			}
		}else{
			j=i+1;
			while(j<cant_elementos && strcmp(tablaDeSimbolos[j].tipo,"@")==0)
			j++;
			if(j<cant_elementos){
				strcpy(tablaDeSimbolos[i].nombre,tablaDeSimbolos[j].nombre);
				strcpy(tablaDeSimbolos[i].tipo,tablaDeSimbolos[j].tipo);
				i--;
			}else{
				i=cant_elementos;
			}
			
		}
	}
}

/* Guarda la tabla generada en un txt */
void guardarTabla(){

	// Verifico si se cargo algo en la tabla
	if(cantidadTokens == -1)
	yyerror();

	FILE* arch = fopen("ts.txt", "w+");
	if(!arch){
		printf("No pude crear el archivo ts.txt\n");
		return;
	}

	fprintf(arch,"%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	fprintf(arch, "======================================================================================================\n");
	//lo mismo que guarda en archivo lo imprimo en pantalla
	//printf("%-30s%-20s%-30s%-5s\n","NOMBRE","TIPO","VALOR", "LONGITUD");
	//printf("======================================================================================================\n");
	// Recorro la tabla
	int i = 0;
	while (i < cant_ctes) {

		fprintf(arch, "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		//printf( "%-30s%-20s%-30s%-5d\n", &(tablaDeSimbolos[i].nombre), &(tablaDeSimbolos[i].tipo) , &(tablaDeSimbolos[i].valor), tablaDeSimbolos[i].longitud);
		i++;
	}

	fclose(arch);
}

void agregarConstante(char* nombre,char* tipo) {
	printf("Agregar cte %s: %s .\n\n",nombre, tipo);

	// Formateo la cadena
	int length = strlen(nombre);

	char nombre_nuevo[length];
	
	strcpy(nombre_nuevo, "_");
	strcat(nombre_nuevo, nombre);
	
	strcpy(nombre_nuevo + strlen(nombre_nuevo), "\0");
	
	// Verificamos si ya esta cargada
	if (buscarCte(nombre_nuevo, tipo) == 0) {

		// Agrego nombre a la tabla
		strcpy(tablaDeSimbolos[cant_ctes].nombre, nombre_nuevo);

		// Agrego el tipo (Se utiliza para imprimir tabla)
		strcpy(tablaDeSimbolos[cant_ctes].tipo, tipo);	

		// Agrego valor
		strcpy(tablaDeSimbolos[cant_ctes].valor, nombre_nuevo+1);		// Omito el _

		// Agrego la longitud
		if(strcmp(tipo, CteString)==0){
			tablaDeSimbolos[cant_ctes].longitud = length;
		}
		cant_ctes++;
		printf("AGREGO A LA TABLA: %s\n", nombre_nuevo);
	}
}

int buscarCte(char* nombre, char* tipo){			//return 1 = ya esta, return 0 = no esta , cad1 es nombre a buscar cad2 es el tipo 
	int i = cantidadTokens;
	for( i ; i < cant_ctes ; i++){
		if(strcmp(tablaDeSimbolos[i].nombre, nombre)==0 
				&& strcmp(tablaDeSimbolos[i].tipo,tipo)==0){
			printf("%s DUPLICADA\n\n", tipo);
			return 1;
		}
	}
	return 0;
}

void validarVariableDeclarada(char* nombre){
	int i;
	for(i=0 ; i< cantidadTokens; i++){
		if(strcmp(tablaDeSimbolos[i].nombre,nombre)==0)
		return;
		
	}
	sprintf(mensajeDeError, "La Variable: %s - No esta declarada.\n", nombre);
	error(mensajeDeError);	
}
