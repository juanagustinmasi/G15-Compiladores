include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h
.386
.387

MAXTEXTSIZE equ 50

.DATA

_suma                               DD (?)
_promedio                           DD (?)
_contador                           DD           
_cad_                               DB MAXTEXTSIZE dup (?)
_actual                             DD (?)
__CONTAR_CONTADOR                   DD           
_@aux9                              DD (?)
_@aux8                              DD (?)
_@aux7                              DD (?)
_@aux6                              DD (?)
_@aux5                              DD (?)
_@aux4                              DD (?)
_@aux3                              DD (?)
_@aux2                              DD (?)
_@aux10                             DD (?)
_@aux1                              DD (?)
_@aux0                              DD (?)
_92                                 DD 92        
_52                                 DD 52        
_4                                  DD 4         
_256                                DD 256       
_2                                  DD 2         
_1                                  DD 1         
_02_5                               DD 02.5      
_0_342                              DD 0.342     
_0                                  DD 0         
__no_es_mayor_que_2_                 DB "no_es_mayor_que_2", 17 dup (?)
__compiladores_                      DB "compiladores", 12 dup (?)
__actual_es_>_2_y_<>_0_              DB "actual_es_>_2_y_<>_0", 20 dup (?)
__Prueba_txt_LyC_Tema_4_             DB "Prueba.txt_LyC_Tema_4", 21 dup (?)
__La_suma_es:__                      DB "La_suma_es:_", 12 dup (?)
__Ingrese_entero_para_actual:__      DB "Ingrese_entero_para_actual:_", 28 dup (?)
_1                                  DD 1         
_0                                  DD 0         

.CODE

START:
MOV AX, @DATA
MOV DS,AX
FINIT
FFREE

fild _"compiladores
fistp _cad
DisplayString _cad
fild _80
fistp _nombre
DisplayString __Prueba_txt_LyC_Tema_4_
DisplayString __Ingrese_entero_para_actual___
GetInteger _actual
fild _0
fistp _contador
fild _02.5
fild _nombre
fadd
fistp _@aux0
fild _@aux0
fistp _suma
fild _contador
fild _92
fxch
fcom
fstsw ax
sahf
JG ENDIF_83
fild _contador
fild _1
fadd
fistp _@aux1
fild _@aux1
fistp _contador
fild _contador
fild _0.342
fdiv
fistp _@aux2
fild _0
fistp __CONTAR_CONTADOR
fild _actual
fild _contador
fmul
fistp _@aux3
fild _256
fild _@aux3
fxch
fcom
fstsw ax
sahf
JNE __JUMP_CONTADOR_42
fild __CONTAR_CONTADOR
fild _1
fadd
fistp _@aux4
fild _@aux4
fistp __CONTAR_CONTADOR
__JUMP_CONTADOR_42:
fild _nombre
fild _suma
fmul
fistp _@aux5
fild _@aux5
fild _@aux3
fxch
fcom
fstsw ax
sahf
JNE __JUMP_CONTADOR_50
fild __CONTAR_CONTADOR
fild _1
fadd
fistp _@aux6
fild _@aux6
fistp __CONTAR_CONTADOR
__JUMP_CONTADOR_50:
fild _52
fild _@aux3
fxch
fcom
fstsw ax
sahf
JNE __JUMP_CONTADOR_56
fild __CONTAR_CONTADOR
fild _1
fadd
fistp _@aux7
fild _@aux7
fistp __CONTAR_CONTADOR
__JUMP_CONTADOR_56:
fild _4
fild _@aux3
fxch
fcom
fstsw ax
sahf
JNE __JUMP_CONTADOR_62
fild __CONTAR_CONTADOR
fild _1
fadd
fistp _@aux8
fild _@aux8
fistp __CONTAR_CONTADOR
__JUMP_CONTADOR_62:
fild _:
fild _:
fadd
fistp _@aux9
fild _@aux9
fistp _actual
fild _suma
fild _actual
fadd
fistp _@aux10
fild _@aux10
fistp _suma
DisplayString __La_suma_es___
DisplayString _suma
DisplayString __actual_es_>_2_y_<>_0_
JMP ENDIF_84
ELSE_77:
fild _actual
fild _nombre
fxch
fcom
fstsw ax
sahf
JGE ENDIF_83
DisplayString __no_es_mayor_que_2_
ENDIF_83:
ENDIF_84:

FINAL:
mov ah, 1
int 21h
MOV AX, 4C00h
INT 21h
END START