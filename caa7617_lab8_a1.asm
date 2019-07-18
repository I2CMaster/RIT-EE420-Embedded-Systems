            .cdecls C, LIST, "msp430.h"     		; Include device header file

SWdelay		.equ	0xFF							; Delay value used by the SW timer
THRESHOLD	.equ	0x20							; Theshold adjustment
SET			.equ	0x00							; Sets the LED for keypress
HOLD		.equ	0x01							; Hold key for LED

LEDA		.equ 	11101000b	  					; Top Left LED
LEDB		.equ 	00100000b  						; Bottom Left LED
LEDC		.equ 	10111000b 						; Bottom Right LED
LEDD		.equ 	10000000b  						; Top Right LED
LEDE		.equ 	00000001b 						; Center LED

DELAY		.equ	R4								; Used for the SW delay
PINSEL		.equ	R5								; Used to select which pin
INDEX		.equ	R6								; Used to index an array
STATUS		.equ	R7								; Stores which button are pressed
TEMP		.equ	R8								; Temp. storage

			.data
			.bss	base, 10						; Baseline measurments
			.bss	latest, 10						; Current messurments
			.bss	func, 2							; Stores how to interpret keypress

            .text
            .global	RESET
            .retain
            .retainrefs


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------
RESET       mov	   	#__STACK_END, SP         		; Initialize stackpointer
StopWDT     mov	   	#WDTPW | WDTHOLD, &WDTCTL		; Stop watchdog timer
			bis.b	#0xFF, &P1DIR					; Set up P1 as outputs
			bic.b	#0xFF, &P1OUT					; Turn off P1
			mov		#SET, &func						; Set how to handle "keypress"
			call	#Baseline						; Get baseline values


;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------
Main		tst		&func							; Check how to handle "keypress"
			jz		Keep							; If func = set then don't clear LED's
ClearLED	bic.b	#0xFF, &P1OUT					; Otherwise clear LED's
Keep		call 	#Latest							; Gets current cap. measurments
			call 	#Sensor							; Check which cap. buttons are pressed
			call 	#Display						; Display results on LED's
			jmp		Main							; Repeat


;-------------------------------------------------------------------------------
; Measure base line values
;-------------------------------------------------------------------------------
Baseline:
			mov.b	#BIT1, PINSEL					; Set PINSEL to P2.1
			clr		INDEX							; Clear the index value

meas_base_again
			call 	#Meas_setup						; Setup selected pin
			bis 	#MC_2 + TACLR, &TA0CTL			; Start timer
			call 	#SWtimer						; Wait
			xor		#CCIS0, &TA0CCTL1				; Trigger a capture event
			mov		TA0CCR1, base(INDEX)			; Save cap. value in array at INDEX
			bic 	#MC_3, &TA0CTL					; Stop timer

			sub 	#THRESHOLD, base(INDEX)			; Adjust this baseline
			bic.b 	PINSEL, &P2SEL2					; Stop the oscillation on the latest. pin
			rla.b	PINSEL							; Select next pin

			incd	INDEX							; Increment INDEX
			cmp.b	#0x0A, INDEX					; Check if done with all five sensors
			jne		meas_base_again
			ret


;-------------------------------------------------------------------------------
; Measure latest values routine
;-------------------------------------------------------------------------------
Latest:
			mov.b	#BIT1, PINSEL					; Set PISEL to P2.1
			clr		INDEX							; Clear the index value

meas_latest_again
			call 	#Meas_setup						; Setup selected pin
			bis 	#MC_2 + TACLR, &TA0CTL	 		; Start timer
			call 	#SWtimer						; Wait
			xor 	#CCIS0, &TA0CCTL1				; Trigger a capture event
			mov 	TA0CCR1, latest(INDEX)			; Save cap. value in array at INDEX
			bic 	#MC_3, &TA0CTL 					; Stop timer

			bic.b 	PINSEL, &P2SEL2					; Stop the oscillation on the latest. pin
			rla.b	PINSEL							; Prepare next x

			incd	INDEX							; Increment INDEX
			cmp.b	#0x0A, INDEX					; Check if done with all five sensors
			jne		meas_latest_again
			ret


;-------------------------------------------------------------------------------
; Setup for measuring cap. buttons
;-------------------------------------------------------------------------------
Meas_setup:	bic.b 	PINSEL, &P2DIR					; Select pin to be an input
			bic.b 	PINSEL, &P2SEL					; Selct pin to osc. mode
			bis.b 	PINSEL, &P2SEL2
		 	mov 	#TASSEL_3, &TA0CTL				; Select INCLK
			mov 	#CM_3 + CCIS_2 + CAP, &TA0CCTL1	; Setup Timer A capture register
			ret


;-------------------------------------------------------------------------------
; Determine which sensor was pressed routine
;-------------------------------------------------------------------------------
Sensor:		clr		STATUS							; Clear STATUS value
			clr		INDEX							; Clear INDEX value
			mov 	#BIT0, TEMP						; Move 0x01 into TEMP register

CheckNextSensor
			cmp		latest(INDEX), base(INDEX)		; Check if key is pressed
			jl		NotThisSensor					; Jump if no key pressed
			bis.b	TEMP, STATUS					; Update sensor status
			ret

NotThisSensor
			incd	INDEX							; Increment INDEX value
			rla.b	TEMP							; Shift TEMP value left by 1
			cmp.b	#0x0A, INDEX					; If INDEX has reached the end of the array
			jne		CheckNextSensor					; Continue until all of the array is checked
			ret


;-------------------------------------------------------------------------------
; Display routine
;-------------------------------------------------------------------------------
Display:
LED0		cmp		#BIT0, STATUS					; Check if this is the LED to turn on
			jne		LED1							; Check next LED
			mov.b	#LEDA, P1OUT					; Turn on LED
			ret

LED1		cmp		#BIT1, STATUS					; Check if this is the LED to turn on
			jne		LED2							; Check next LED
			mov.b	#LEDB, P1OUT					; Turn on LED
			ret

LED2		cmp		#BIT2, STATUS					; Check if this is the LED to turn on
			jne		LED3							; Check next LED
			mov.b	#LEDC, P1OUT					; Turn on LED
			ret

LED3		cmp		#BIT3, STATUS					; Check if this is the LED to turn on
			jne		LED4							; Check next LED
			mov.b	#LEDD, P1OUT					; Turn on LED
			ret

LED4		cmp		#BIT4, STATUS					; Check if this is the LED to turn on
			jne		NOLED							; Check next LED
			mov.b	#LEDE, P1OUT					; Turn on LED
			ret

NOLED		ret

;-------------------------------------------------------------------------------
; Software Delay
;-------------------------------------------------------------------------------
SWtimer:	mov		#SWdelay, DELAY					; Load delay value into DELAY
SWmore		dec		DELAY							; Decrement DELAY value
			jnz		SWmore							; If DELAY != 0 then continue
			ret


;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .global	__STACK_END
            .sect 	.stack
            .sect   ".reset"
            .short  RESET
