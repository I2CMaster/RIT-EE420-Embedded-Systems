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
		    mov	   	#WDTPW | WDTHOLD, &WDTCTL	; Stop the watchdog timer


ClearArray:
			cmp		#SIZE, R6					; Check if the index is past the array (R6 >= 18)
			jge		Setup						; Jump to fill the array

			mov.b	&Zeros, Array(R6)			; Initialize an element of the array
			inc.b	R6							; Increment index of the array
			jmp		ClearArray					; Repeat


Setup:
			clr		R4							; Clear the row count register
			clr		R5							; Clear the column count register
			clr		R6							; Clear the index register
			mov.b 	#0x0F, R7					; Set the value to 0x000F
			clr		&SUM						; Clear the sum value
			jmp		RowLoop						; Start on the last loop


RowLoop:
			cmp		#NUMROWS, R4				; Check if the row counter is equal to 3
			jge		End							; Jump to End if equal to zero


ColLoop:
			cmp		#NUMCOLS, R5				; Check if the column counter is equal to 3
			jge		NextRow						; Jump to NextRow if equal to zero

			mov.b	R7,	Array(R6)				; Store the array index in the array
			inc.b	R5							; Move to the next element in the row
			inc.b	R6							; Update the array index
			dec.b	R7							; Decrement value register
			inc.b	&SUM						; Update the summation of the array index
			jmp		ColLoop						; Try another column


NextRow:
			clr		R5							; Clear the column counter
			inc.b	R4							; Update the row counter
			jmp		RowLoop						; Go to next row


End:
			nop									; A wait instruction of one clock cycle
			jmp 	End							; Halt uC to debug and view registers


            .global __STACK_END
            .sect 	.stack
            .sect   ".reset"		            ; MSP430 RESET Vector
            .short  RESET


