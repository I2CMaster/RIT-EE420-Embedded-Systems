
            .cdecls C,LIST,"msp430.h"       	; Include device header file

            .text                           	; Assemble into program memory
            .global RESET						; Define entery point
            .retain                         	; Override ELF conditional linking
                                            	; and retain current section
            .retainrefs                     	; Additionally retain any sections
                                            	; that have references to current
                                            	; section

RESET       mov.w   #__STACK_END, SP         	; Initialize stackpointer

StopWDT     mov.w   #WDTPW | WDTHOLD, &WDTCTL  	; Stop watchdog timer

SetupP4     bis.b 	#001h, &P1DIR            	; P1.0 output
            mov.w 	#0x12EF, r12
			clr.w 	r13
			clr.w 	r14
			clr.w 	r15
			mov.b 	r12, r13
			mov.w 	r12, r14
			mov.w 	r12, r15

Mainloop    xor.b   #001h, &P1OUT            	; Toggle P1.0

Wait        mov.w   #050000, R15             	; Delay to R15

L1          dec.w   R15                     	; Decrement R15
            jnz     L1                      	; Delay over?
            jmp     Mainloop                	; Again

            .global __STACK_END
            .sect 	.stack

            .sect   ".reset"                	; MSP430 RESET Vector
            .short  RESET

