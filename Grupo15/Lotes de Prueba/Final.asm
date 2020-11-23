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
_contador2                          DD           
_contador                           DD           
_cad_                               DB MAXTEXTSIZE dup (?)
_actual                             DD (?)
_@aux2                              DD (?)
_@aux1                              DD (?)
_@aux0                              DD (?)
_2                                  DD 2         
_1                                  DD 1         
__SUMA_ES_MENOR_A_2_                 DB "SUMA_ES_MENOR_A_2", 17 dup (?)
__SUMA_ES_MAYOR_A_2_                 DB "SUMA_ES_MAYOR_A_2", 17 dup (?)

.CODE

START:
MOV AX, @DATA
MOV DS,AX
FINIT
FFREE

fild _2
fild _contador
fadd
fistp _@aux0
fild _@aux0
fistp _suma
fild _contador
fild _1
fadd
fistp _@aux1
fild _@aux1
fistp _contador
fild _suma
fild _contador
fadd
fistp _@aux2
fild _@aux2
fistp _suma
fild _suma
fild _2
fxch
fcom
fstsw ax
sahf
JLE ELSE_28
DisplayString __SUMA_ES_MAYOR_A_2_
JMP ENDIF_30
ELSE_28:
DisplayString __SUMA_ES_MENOR_A_2_
ENDIF_30:

FINAL:
mov ah, 1
int 21h
MOV AX, 4C00h
INT 21h
END START