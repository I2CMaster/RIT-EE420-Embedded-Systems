            .cdecls C, LIST, "msp430g2553.h"

ADC_SW_FLAG .equ	R4	 								; ADC Software Flag
SAMPLE		.equ	R5									; Register to hold ADC sample value

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
			clr 	SAMPLE 								; Clear the sample register
			bis.b 	#BIT0, &ADC10AE0					; Set P1.0 as an analog input


;-------------------------------------------------------------------------------
; Main loop
;-------------------------------------------------------------------------------
Mainloop	call 	#ACQUIRE 							; Capture ADC Value
			jmp		Mainloop							; Repeat


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
CheckFlag	tst 	ADC_SW_FLAG 						; Check to see if ADC10_ISR was
			jz 		CheckFlag
			dint										; Disable general interrupts
			clr		&ADC10CTL0							; Clear ADC configuration registers
			clr		&ADC10CTL1
			ret


;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
ADC10_ISR:	dint										; Disable interupts
			bic		#ADC10IFG, &ADC10CTL0				; Clear ADC conversion flag
			mov		&ADC10MEM, SAMPLE					; Move value from ADC into sample register
			mov.b	#BIT0, ADC_SW_FLAG 					; Set the ADC Software Flag
			eint										; Re-Enable interrupt
			reti										; Return from interupt


;-------------------------------------------------------------------------------
; Interrupt Vectors & Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

			.sect 	".int05"
isr_adc10: 	.short	ADC10_ISR

            .sect   ".reset"
            .short  RESET
