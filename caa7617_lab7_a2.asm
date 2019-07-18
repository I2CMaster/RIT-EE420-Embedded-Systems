            .cdecls C, LIST, "msp430.h"       		; Include device header file

SWdelay		.equ	0xFF	 						; Delay value used by the SW timer
OFF			.equ	0x01							; OFF value
ON			.equ	0x02							; ON value

DELAY		.equ	R4								; Delay register
BASE		.equ	R5								; Base value register
CURRENT		.equ	R6								; Current value register

            .text
            .global RESET
            .retain
            .retainrefs


;---------------------------------------------------------------------------------------------------
; Reset and setup code
;---------------------------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END, SP         		; Initialize stackpointer
StopWDT     mov.w   #WDTPW | WDTHOLD, &WDTCTL  		; Stop watchdog timer

			clr		DELAY							; Clear working registers
			clr 	BASE
			clr		CURRENT

			bis.b	#0xFF, &P1DIR					; Set up P1 as all outputs
			bic.b	#0xFF, &P1OUT					; Clear Port 1

			bic.b 	#BIT5, &P2DIR					; Set P2 Pin 5 as an input
			bic.b 	#BIT5, &P2SEL					; Set Pin 5 into osc. mode
			bis.b 	#BIT5, &P2SEL2

		 	mov 	#TASSEL_3, &TA0CTL 				; Clk. input for Timer A is Pin 5
			mov 	#CM_3 + CCIS_2 + CAP, &TA0CCTL1	; Capture value of TAR on any edge


;---------------------------------------------------------------------------------------------------
; Get the baseline reading
;---------------------------------------------------------------------------------------------------
Baseline	call	#Read							; Get capacitance value
			mov		CURRENT, BASE					; Save the baseline value
			sub		#40, BASE						; Adjust baseline value


;---------------------------------------------------------------------------------------------------
; Main loop
;---------------------------------------------------------------------------------------------------
Main		call	#Read							; Get reading for cap. button
			cmp		CURRENT, BASE					; Compare baseline to current readings
			jge		KeyPress						; If (baseline > current) then jump

NoPress		bic.b	#BIT0, P1OUT					; Turn off LED
			jmp		Main							; Return

KeyPress	bis.b	#BIT0, P1OUT					; Turn on LED
			jmp 	Main							; Return


;---------------------------------------------------------------------------------------------------
; Cap. Capture Function
;---------------------------------------------------------------------------------------------------
Read:		bis 	#MC_2 + TACLR, &TA0CTL 			; Continuous Mode
			call 	#SWtimer						; Call delay function
			xor 	#CCIS0, &TA0CCTL1				; Trigger a capture event
			mov 	TA0CCR1, CURRENT				; Move captured value into CURRENT
			bic 	#MC1 + MC0, &TA0CTL				; Stop the Timer
			ret										; Return from function call


;---------------------------------------------------------------------------------------------------
; Software Delay Function
;---------------------------------------------------------------------------------------------------
SWtimer:	mov		#SWdelay, DELAY 				; Load wait value into DELAY
More		dec		DELAY							; Decrement DELAY
			jnz		More							; Jump if DELAY = 0
			ret										; Return from this subroutine


;---------------------------------------------------------------------------------------------------
; Interrupt Vector List
;---------------------------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack
            .sect   ".reset"
            .short  RESET
