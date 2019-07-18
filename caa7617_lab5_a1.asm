;*******************************************************************************
;	MSP430 Assembler Code Template for use with TI Code Composer Studio
;   dxp_Lab5_a1_C55AUDIO1.asm
;	Displays a clockwise circle
;	dbp 0301_365_20053
;   Built with CCE for MSP430 Version: 1.00
;	Updated for version 4.x.x by Dorin Patru April 2011
;	Re-coded completely for CCS v5.4, Launch Pad and Capacitive Booster Pack
;		by Dorin Patru October 2013
;	Re-coded for CCS v7 and v8, Launch Pad and 430BOOST-C55AUDIO Audio Capacitive Booster Pack
;		by Carlos Barrios August 2018
;*******************************************************************************

;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430g2553.h"       ; Include device header file
;-------------------------------------------------------------------------------

;			.data			; presume .data begins at 0x0200
SPEED:		.word	0x7fff	; display half speed
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
            .global RESET
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
			clr		r10				; delay counter
			clr		r11				; LED select
			bic.b	#0xff,&P1DIR	; set up P1 as input
			bis.b	#0xf8,&P1DIR	; set up P1[7:3] as outputs
;-------------------------------------------------------------------------------
;	LEDs 1,2,5,6 not elegant display - clockwise
;-------------------------------------------------------------------------------
CIRCLE:		bic.b	#0xf8,&P1OUT	; prepare to display LEDs 1,2,5,6
			bis.b	#0x20, &P1OUT	; turn on LED2
			call	#DELAY			; wait around

			bic.b	#0x20, &P1OUT	; turn off LED2
			bis.b	#0xD8, &P1OUT	; turn on LED6
			call	#DELAY			; wait around

			bic.b	#0xD8, &P1OUT	; turn off LED6
			bis.b	#0x10, &P1OUT	; turn on LED1
			call	#DELAY			; wait around

			bic.b	#0x10, &P1OUT	; turn off LED1
			bis.b	#0xE8, &P1OUT	; turn on LED5
			call	#DELAY			; wait around

			bic.b	#0xE8, &P1OUT	; turn off LED5
;-------------------------------------------------------------------------------
;	LEDs 3,4,7,8 display loop - clockwise
;-------------------------------------------------------------------------------
			bic.b	#0xf8,&P1OUT	; turn off all LEDs
			mov.b	#0x80, r11		; prepare r11 for the loop
DISP_LOOP
            mov.b   r11, r12
            inv.b   r12
			bis.b	r11, &P1OUT		;
            bic.b   r12, &P1OUT     ;
			call	#DELAY			; wait around

			bic.b	r11, &P1OUT		;
			bis.b	r12, &P1OUT		;
			call	#DELAY			; wait around

            clrc
            rrc.b	r11				;
            cmp     #0x20, r11
			jeq		CIRCLE			; check if you are done on this side
			jmp		DISP_LOOP		; jump to display the next LED
;-------------------------------------------------------------------------------
;	Delay Subroutine
;-------------------------------------------------------------------------------
DELAY:
            mov.w	&SPEED,R10
MORE_DELAY:	dec.w   R10             ; Decrement R10
            jnz     MORE_DELAY   	; Delay over?
           	ret				    	; return
;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack
;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
