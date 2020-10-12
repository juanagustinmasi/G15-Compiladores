
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     WHILE = 258,
     OP_IF = 259,
     ELSE = 260,
     OP_AND = 261,
     OP_OR = 262,
     OP_NOT = 263,
     TIPO_REAL = 264,
     TIPO_ENTERO = 265,
     TIPO_STRING = 266,
     CONST = 267,
     PUT = 268,
     GET = 269,
     ASIG = 270,
     MAS = 271,
     MENOS = 272,
     POR = 273,
     DIVIDIDO = 274,
     MENOR = 275,
     MAYOR = 276,
     MENOR_IGUAL = 277,
     MAYOR_IGUAL = 278,
     IGUAL = 279,
     DISTINTO = 280,
     PA = 281,
     PC = 282,
     CA = 283,
     CC = 284,
     COMA = 285,
     PUNTO_COMA = 286,
     DOS_PUNTOS = 287,
     CTE_STRING = 288,
     CTE_FLOAT = 289,
     CTE_INT = 290,
     DIM = 291,
     AS = 292,
     ESPACIO = 293,
     GUION_BAJO = 294,
     LLAVE_ABIERTA = 295,
     LLAVE_CERRADA = 296,
     REAL = 297,
     ENTERO = 298,
     ID = 299,
     STRING = 300,
     OP_ASIG_IGUAL = 301
   };
#endif
/* Tokens.  */
#define WHILE 258
#define OP_IF 259
#define ELSE 260
#define OP_AND 261
#define OP_OR 262
#define OP_NOT 263
#define TIPO_REAL 264
#define TIPO_ENTERO 265
#define TIPO_STRING 266
#define CONST 267
#define PUT 268
#define GET 269
#define ASIG 270
#define MAS 271
#define MENOS 272
#define POR 273
#define DIVIDIDO 274
#define MENOR 275
#define MAYOR 276
#define MENOR_IGUAL 277
#define MAYOR_IGUAL 278
#define IGUAL 279
#define DISTINTO 280
#define PA 281
#define PC 282
#define CA 283
#define CC 284
#define COMA 285
#define PUNTO_COMA 286
#define DOS_PUNTOS 287
#define CTE_STRING 288
#define CTE_FLOAT 289
#define CTE_INT 290
#define DIM 291
#define AS 292
#define ESPACIO 293
#define GUION_BAJO 294
#define LLAVE_ABIERTA 295
#define LLAVE_CERRADA 296
#define REAL 297
#define ENTERO 298
#define ID 299
#define STRING 300
#define OP_ASIG_IGUAL 301




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 20 "sintactico.y"

	int int_val;
	double float_val;
	char *str_val;



/* Line 1676 of yacc.c  */
#line 152 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


