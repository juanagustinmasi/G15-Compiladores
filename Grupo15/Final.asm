include macros2.asm
include number.asm

.MODEL LARGE
.STACK 200h
.386
.387

MAXTEXTSIZE equ 50

.DATA

_seges                              DD (?)
_heahae                             DD (?)
_actual                             DD (?)
_6                                  DD 6         
_4                                  DD 4         
_1                                  DD 1         
_no_es_mayor_que_2                  DB "no_es_mayor_que_2", 17 dup (?)
_actual_es_>_que_2_y_<>_de_0        DB "actual_es_>_que_2_y_<>_de_0", 27 dup (?)

.CODE

START:
MOV AX, @DATA
MOV DS,AX
FINIT
FFREE

fild _4
fistp _actual
fild _actual
fild _1
fxch
fcom
fstsw ax
sahf
JGE 
DisplayString "actual_es_>_que_2_y_<>_de_0"
DisplayString "no_es_mayor_que_2"
fild _6
fistp _actual

FINAL:
mov ah, 1
int 21h
MOV AX, 4C00h
INT 21h
END START