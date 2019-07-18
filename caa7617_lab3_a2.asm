NUMROWS 	.equ	0x04
NUMCOLS 	.equ	0x04
FULL		.equ	0x10

            .cdecls	C, LIST, "msp430g2553.h"

Array:		.bss 	ROW0, 4
			.bss 	ROW1, 4
			.bss 	ROW2, 4
			.bss 	ROW3, 4
			.bss 	SUM, 2

Constants:	.sect 	".const"

Zeroes:		.byte 	0x00
Ones:		.byte 	0xff
Odds:		.byte 	0x55
Evens:		.byte 	0xaa

            .text
            .global RESET
            .retain
            .retainrefs

RESET       mov.w   #__STACK_END, SP
StopWDT     mov.w   #WDTPW | WDTHOLD, &WDTCTL

Mainloop:
			clr		R4					; Row Counter
			clr		R5					; Column Counter
			clr		R6					; Array Index
			clr		&SUM				; Clear the accumulator location

InitLoop:
			cmp.b	#FULL, R6			; Passed end of array?
			jeq		DoubleLoop			; Done initializing
			mov.b	&Ones, Array(R6)	; Initialize an element of the array
			add.b	#1, R6				; Point to the next location
			jmp		InitLoop			; go again

DoubleLoop:
			clr		R6					; Clear the array index

ROWLOOP:								; Outer loop, process a row at a time
			cmp.b	#NUMROWS, R4		; Finished last row?
			jeq		FINI				; Jump to end if equal

COLLOOP:								; Inner loop,
			cmp.b	#NUMCOLS, R5		; Finished last column?
			jeq		NEXTROW				; Done if equal, get the nextrow
			mov.b	R6,	ROW0(R6)		; Store the array index in the array
			add		R6,	SUM				; Update the summation of the array index
			add.b	#1,	R5				; Move to the next element in the row
			add.b	#1,	R6				; Update the array index
			jmp		COLLOOP				; Try another column

NEXTROW:
			clr.b	R5					; Clear the column counter
			add.b	#1,	R4				; Update the row counter
			jmp		ROWLOOP				; Try another row

FINI:
			jmp Mainloop				; Start over


            .global __STACK_END
            .sect 	.stack

            .sect   ".reset"            ; MSP430 RESET Vector
            .short  RESET
