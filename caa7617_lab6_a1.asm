            .cdecls C, LIST, "msp430.h"			       		; Include device header file
            
PWMPeriod	.equ	1000									; PWM Period
PWMDC1		.equ	800										; PWM1 = 80% DC
PWMDC2		.equ	200										; PWM2 = 20% DC
SWdelay		.equ	0x00FF									; Delay value used by the SW timer

            .text
            .retain
            .retainrefs
            .global	RESET


RESET       mov.w   #__STACK_END,SP         				; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  				; Stop watchdog timer


Setup		clr		R5										; Clear registers
			clr		R6
			bis.b 	#BIT6, P1DIR 							; Set P1.6 as an output
			bis.b 	#BIT6, P1SEL 							; P1.6 peripheral function
SetupTA 	mov 	#TASSEL1 + ID1 + ID0 + TACLR, &TACTL 	; SMCLK, Clear TA, TACTL = uuuu uu11 0000 u100
			mov 	#OUTMOD1, &TACCTL1
			mov 	#PWMPeriod, &TACCR0 					; ~100ms


StartPWM	bic 	#MC1 + MC0, &TACTL 						; Stop TA to change the value
			mov 	#PWMDC1, &TACCR1						; Load first PW value in TACCR1
			bis 	#MC1 + MC0, &TACTL 						; Start TA in up/down mode
			call 	#SWtimer								; Call the SW delay routine to keep this PW for a while

			bic 	#MC1 + MC0, &TACTL 						; Stop TA to change the value
			mov 	#PWMDC2, &TACCR1						; Now switch the PW
			bis 	#MC1 + MC0, &TACTL 						; Start TA in up/down mode
			call 	#SWtimer								; Call the SW delay routine to keep this PW for a while
			jmp		StartPWM


SWtimer:	mov		#SWdelay, R6							; Load delay value in r5
ReloadR5	mov		#SWdelay, R5							; Load delay value in r6
ISr50		dec		R5										; Keep this PW for some time
			jnz		ISr50									; The total SW delay count is
			dec		R6										;  = SWdelay * SWdelay
			jnz		ReloadR5
			ret


            .global __STACK_END
            .sect   .stack
            .sect   ".reset"
            .short  RESET
            
