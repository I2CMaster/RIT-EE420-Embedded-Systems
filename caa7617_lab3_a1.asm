
            .cdecls C, LIST, "msp430.h"

            .text
            .global RESET
            .retain
            .retainrefs

RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer

StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

SetupP4		bis.b	#001h, &P1DIR			; Setup Green Led as an output

			; Clear Registers 12, 13, 14, and 15
			bic		#0xFFFF, R12
			bic		#0xFFFF, R13
			bic		#0xFFFF, R14
			bic		#0xFFFF, R15

			; Set Registers 12 - 15 with 0x12EF
			bis		#0x12EF, R12
			bis.b	R12, R13
			bis		R12, R14
			bis		R12, R15

Mainloop    xor.b   #001h, &P1OUT            	; Toggle P1.0

Wait        mov.w   #050000, R15             	; Delay to R15

L1          dec.w   R15                     	; Decrement R15
            jnz     L1                      	; Delay over?
            jmp     Mainloop                	; Again

            .global __STACK_END
            .sect   .stack

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
