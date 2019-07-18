            .cdecls C, LIST, "msp430.h"       		; Include device header file

SWdelay		.equ	0xFF	 						; Delay value used by the SW timer
OFF			.equ	0x01							; OFF value
ON			.equ	0x02							; ON value

DELAY		.equ	R4								; Delay register
BASE		.equ	R5								; Base value register
CURRENT		.equ	R6								; Current value register
LOW			.equ	R7								; Low threshold value register
HIGH		.equ	R8								; High threshold value register
STATE		.equ	R9								; High threshold value register

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
			clr		LOW
			clr		HIGH

			mov		#OFF, STATE						; Set the STATE to OFF

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
			mov		BASE, HIGH						; Copy baseline into high threshold
			mov		BASE, LOW						; Copy baseline into low threshold
			sub		#30, HIGH						; Adjust high threshold
			sub		#40, LOW						; Adjust low threshold


;---------------------------------------------------------------------------------------------------
; Main loop
;---------------------------------------------------------------------------------------------------
Main		call	#SWtimer						; Wait for a certain amount of time
			call	#Read							; Get center button cap. value

Yes_Chk1	cmp		#OFF, STATE						; If STATE is OFF continue
			jeq		Yes_Chk2
			jmp 	No_Chk1

Yes_Chk2	cmp		CURRENT, LOW					; If current < low_threshold continue
			jl		YesKey
			jmp		No_Chk1

YesKey		mov		#ON, STATE						; Set the STATE to ON
			xor 	#BIT0, P1OUT					; Toggle center LED if key "pressed"
			jmp 	Main

No_Chk1		cmp		#ON, STATE						; If STATE is ON continue
			jeq		No_Chk2
			jmp		Main

No_Chk2		cmp		CURRENT, HIGH					; If current >= high_threshold continue
			jge		NoKey
			jmp 	Main

NoKey		mov 	#OFF, STATE						; Set the STATE to OFF
			jmp		Main							; Repeat


;---------------------------------------------------------------------------------------------------
; Cap. Capture  Function
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
