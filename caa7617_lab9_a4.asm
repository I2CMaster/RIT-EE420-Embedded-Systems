            .cdecls C, LIST, "msp430g2553.h"

ADC_SW_FLAG .equ	R4	 								; ADC Software Flag
INDEX		.equ	R5									; Register to hold index value

			.bss	SAMPLES, 64							; An array of 32 samples for the ADC

            .text
            .global	RESET
            .retain
            .retainrefs


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------
RESET       mov		#__STACK_END, SP         			; Initialize stackpointer
StopWDT     mov	   	#WDTPW | WDTHOLD, &WDTCTL			; Stop watchdog timer

			clr 	ADC_SW_FLAG 						; Clear ADC SW flag
			clr 	INDEX 								; Clear the INDEX register

			bic.b	#BIT6, &P1OUT
			bis.b	#BIT6, &P1DIR

			bis.b 	#BIT0, &ADC10AE0					; Set P1.0 as an analog input
			mov		#(TASSEL_2 + MC_1 + TACLR + TAIE), &TA0CTL
			mov		#13125, &TA0CCR0					; Setup Timer A and set to interupt every 105ms
			eint										; Enable Global Interrupts

;-------------------------------------------------------------------------------
; Main loop
;-------------------------------------------------------------------------------
Mainloop	nop
			jmp		Mainloop


;-------------------------------------------------------------------------------
; Aquire ADC Value
;-------------------------------------------------------------------------------
ACQUIRE:	clr		&ADC10CTL0							; Clear configuration registers just in case
			clr		&ADC10CTL1							; some values were left on by a prior routine
			mov	 	#(SREF_1 + ADC10SHT_3 + REFON + ADC10ON + ADC10IE), &ADC10CTL0
			mov	 	#(INCH_0 + ADC10DIV_0 + ADC10SSEL_2), &ADC10CTL1
			clrz 										; Clear Z in Status Register
			clr 	ADC_SW_FLAG 						; Clear ADC SW FLAG
			bis 	#(ENC + ADC10SC), &ADC10CTL0 		; Start a conversion
			eint 										; Enable interrupts

CheckFlag	tst 	ADC_SW_FLAG 						; Check to see if ADC10_ISR was set
			jz 		CheckFlag

			dint										; Disable general interrupts
			clr		&ADC10CTL0							; Clear ADC configuration registers
			clr		&ADC10CTL1
			ret


;-------------------------------------------------------------------------------
; ADC10 Interrupt
;-------------------------------------------------------------------------------
ADC10_ISR:	dint										; Disable interupts
			bic		#ADC10IFG, &ADC10CTL0				; Clear ADC conversion flag
			mov		&ADC10MEM, SAMPLES(INDEX)			; Move value from ADC into sample register
			incd	INDEX								; Increment INDEX value to next
			cmp		#64, INDEX							; Check if 32 samples have been collected
			jge		ClrIndex

ContADC		mov.b	#BIT0, ADC_SW_FLAG 					; Set the ADC Software Flag
			eint										; Re-Enable interrupt
			reti										; Return from interupt

ClrIndex	clr		INDEX								; Clear INDEX register
			jmp		ContADC								; Continue on


;-------------------------------------------------------------------------------
; Timer A Interrupt (TAR = TACCR0)
;-------------------------------------------------------------------------------
TIMER0_ISR:	dint										; Disable interupts
			bic		#CCIE, &TA0CCTL0					; Clear Timer A Interrupt Flag
			xor.b	#BIT6, &P1OUT
			call	#ACQUIRE							; Setup to catupre ADC
			eint										; Re-Enable interrupt
			reti										; Return from interupt


;-------------------------------------------------------------------------------
; Interrupt Vectors & Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

			.sect 	".int05"
isr_adc10: 	.short	ADC10_ISR

			.sect 	".int09"
isr_timer0:	.short	TIMER0_ISR

            .sect   ".reset"
            .short  RESET
