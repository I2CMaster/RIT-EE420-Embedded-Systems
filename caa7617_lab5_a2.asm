            .cdecls C, LIST, "msp430.h"

            .sect	".const"
TIME:		.word	0xAFFF						; Display Speed

            .text
            .retain
            .retainrefs
            .global	RESET


RESET:      mov.w   #__STACK_END, SP         	; Initialize stackpointer
			mov.w   #WDTPW | WDTHOLD, &WDTCTL 	; Stop watchdog timer


SETUP:		clr		R10							; Clear working registers
			clr		R11
			clr		R12

			mov.b	#0xF8, &P1DIR				; Set up P1[7:3] as outputs
			clr.b	&P1SEL						; Make sure P1 are GPIO's
			clr.b	&P1SEL2
			clr.b	&P1OUT						; Turn off all LEDs
			call	#DISPLAY


DISPLAY:	bic.b	#0xF8, &P1OUT				; Turn off all LEDs
			mov.b	#0x10, R11					; Prepare R11 for the loop

DISP_LOOP	mov.b   R11, R12
            inv.b   R12							; R12 = ~R11

            bic.b	R11, &P1OUT					; P1OUT &= R11
			bis.b	R12, &P1OUT					; P1OUT |= R12
			call	#DELAY						; Software delay

			bis.b	R11, &P1OUT					; P1OUT |= R11
            bic.b   R12, &P1OUT					; P1OUT &= R12
			call	#DELAY						; Software delay

            clrc								; Clear carry bit
            rlc.b	R11							; Rotate R11 left

			jc		DISPLAY						; If carry = 1 then start over
			jmp		DISP_LOOP					; Otherwise repeat


DELAY:		mov		&TIME, R10					; Move the delay time into R10
DELAY_MORE	dec		R10							; Decrement r10
			jnz		DELAY_MORE					; If R10 != 0 then repeat
			ret									; Return when delay is over


            .global __STACK_END
            .sect   .stack
            .sect   ".reset"
            .short  RESET
            
