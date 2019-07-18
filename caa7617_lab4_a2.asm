			.cdecls	C, LIST, "msp430g2553.h"

Constants:	.sect 	".const"

NUMROWS 	.equ	0x04
NUMCOLS 	.equ	0x04
SIZE		.equ	0x22

Array:		.bss 	ROW0, 4
			.bss 	ROW1, 4
			.bss 	ROW2, 4
			.bss 	ROW3, 4
			.bss	SUM, 2

Zeros:		.byte 	0x00
Ones:		.byte 	0xFF
Odds:		.byte 	0x55
Evens:		.byte 	0xAA

            .text
            .global RESET
            .retain
            .retainrefs


RESET:
		    mov		#__STACK_END, SP			; Intialize the stack pointer
		    mov	 	#WDTPW | WDTHOLD, &WDTCTL	; Stop the watchdog timer
			clr		R4							; Clear the row counter
			clr		R5							; Clear the column counter
			clr		R6							; Clear the array index


ClearArray:
			cmp		#SIZE, R6					; Check if the index is >= 18
			jge		SetRow0						; Jump to fill Row 0

			mov.b	&Zeros, Array(R6)			; Initialize an element of the array
			inc		R6							; Increment index of the array
			jmp		ClearArray					; Repeat


SetRow0:
			clr		R5							; Clear column counter
			clr		R6							; Clear index value
NextCol0:
			cmp		#NUMCOLS, R5				; Check if the column count >= 4
			jge		SetRow1						; Jump to fill Row 1

			mov.b	&Zeros, Array(R6)			; Set the element to zero
			add		Array(R6), &SUM				; Add the value of the element to the sum
			inc		R5							; Increment the column counter
			inc		R6							; Increment the index
			jmp		NextCol0					; Repeat


SetRow1:
			inc		R4							; Increment row counter
			clr		R5							; Clear column counter
NextCol1:
			cmp		#NUMCOLS, R5				; Check if the column count >= 4
			jge		SetRow2						; Jump to fill Row 2

			mov.b	&Ones, Array(R6)			; Set the element to zero
			add		Array(R6), &SUM				; Add the value of the element to the sum
			inc		R5							; Increment the column counter
			inc		R6							; Increment the index
			jmp		NextCol1					; Repeat


SetRow2:
			inc		R4							; Increment row counter
			clr		R5							; Clear column counter
NextCol2:
			cmp		#NUMCOLS, R5				; Check if the column count >= 4
			jge		SetRow3						; Jump to fill Row 2

			mov.b	&Odds, Array(R6)			; Set the element to zero
			add		Array(R6), &SUM				; Add the value of the element to the sum
			inc		R5							; Increment the column counter
			inc		R6							; Increment the index
			jmp		NextCol2					; Repeat


SetRow3:
			inc		R4							; Increment row counter
			clr		R5							; Clear column counter
NextCol3:
			cmp		#NUMCOLS, R5				; Check if the column count >= 4
			jge		End							; End program

			mov.b	&Evens, Array(R6)			; Set the element to zero
			add		Array(R6), &SUM				; Add the value of the element to the sum
			inc		R5							; Increment the column counter
			inc		R6							; Increment the index
			jmp		NextCol3					; Repeat


End:
			nop									; A wait instruction of one clock cycle
			jmp 	End							; Halt uC to debug and view registers


            .global __STACK_END
            .sect 	.stack
            .sect   ".reset"            ; MSP430 RESET Vector
            .short  RESET
