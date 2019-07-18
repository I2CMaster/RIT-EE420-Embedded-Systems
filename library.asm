;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;******************************************************************************
; MSP430G2553 Lab 11 Assignment Assembler Code
;
; Description: Library extension to wrap other classes together
;******************************************************************************
            .cdecls C, LIST, "msp430g2553.h"				; Import MSP430 header file
Constants:	.sect 	".const"

;-------------------------------------------------------------------------------
; Constant Definitions
;-------------------------------------------------------------------------------
XIN			.equ	BIT6
XOUT		.equ	BIT7

char_0		.equ	0x30
char_1		.equ	0x31
char_2		.equ	0x32
char_3		.equ	0x33
char_4		.equ	0x34
char_5		.equ	0x35
char_6		.equ	0x36
char_7		.equ	0x37
char_8		.equ	0x38
char_9		.equ	0x39
char_A		.equ	0x41
char_B		.equ	0x42
char_C		.equ	0x43
char_D		.equ	0x44
char_E		.equ	0x45
char_F		.equ	0x46
char_G		.equ	0x47
char_H		.equ	0x48
char_I		.equ	0x49
char_J		.equ	0x4A
char_K		.equ	0x4B
char_L		.equ	0x4C
char_M		.equ	0x4D
char_N		.equ	0x4E
char_O		.equ	0x4F
char_P		.equ	0x50
char_Q		.equ	0x51
char_R		.equ	0x52
char_S		.equ	0x53
char_T		.equ	0x54
char_U		.equ	0x55
char_V		.equ	0x56
char_W		.equ	0x57
char_X		.equ	0x58
char_Y		.equ	0x59
char_Z		.equ	0x5A

rate_500ms	.equ	0xFFFF
count_500ms	.equ	8

rate_10ms	.equ	1050

rate_5ms	.equ	525

sample_size	.equ	42

RUN         .equ  	BIT0	; Use with bis
SLOW        .equ    BIT1	; Use with bic
FAST        .equ    BIT1	; Use with bis
LIN         .equ    BIT2	; Use with bic
LOG         .equ    BIT2	; Use with bis

;PROX        .equ    BIT0  -- Not used for this project
LEFT      	.equ    BIT1
DOWN        .equ    BIT2
RIGHT       .equ    BIT3
UP       	.equ    BIT4
CENTER      .equ    BIT5

THRESHOLD	.equ	0x0030
SWdelay		.equ	0x00FF

LEDA		.equ 	11101000b	  							; Top Left LED
LEDB		.equ 	00100000b  								; Bottom Left LED
LEDC		.equ 	10111000b 								; Bottom Right LED
LEDD		.equ 	10000000b  								; Top Right LED
LEDE		.equ 	00000001b 								; Center LED

LED0 		.equ	00100000b
LED1        .equ	11011000b
LED2        .equ	00010000b
LED3        .equ	11101000b
LED4        .equ	10000000b
LED5        .equ	01111000b
LED6        .equ	01000000b
LED7        .equ	10111000b
LED8        .equ	00000001b

LED_PINS	.equ	11111001b

; ACLK
;BAUD0 		.equ	109
;BAUD1      .equ	0

; MCLK ~1 MHz
BAUD0 		.equ	109
BAUD1      	.equ	0

; MCLK ~8 MHz
;BAUD0 		.equ	104
;BAUD1      .equ	3

; MCLK ~12 MHz
;BAUD0 		.equ	28
;BAUD1      .equ	5

; MCLK ~16 MHz
;BAUD0 		.equ	208
;BAUD1      .equ	6

TX_PIN		.equ	BIT2
RX_PIN		.equ	BIT1

A0			.equ	BIT0
A1			.equ	BIT1
A2			.equ	BIT2
A3			.equ	BIT3
A4			.equ	BIT4
A5			.equ	BIT5
A6			.equ	BIT6
A7			.equ	BIT7


;-------------------------------------------------------------------------------
; Register Definitions
;-------------------------------------------------------------------------------
SW_FLAG		.equ 	R12										; Software flag
COUNT		.equ	R13										; Count for long wait times
TEMP		.equ	R14										; Temp. register for calculations
INDEX		.equ	R15										; Index for arrays

PINSEL		.equ	R11										; Value for current pin
DELAY		.equ	R12										; Count for long wiat times

LED			.equ	R4										; How many LEDs to count to
VAL			.equ	R5										; Holds current LED display-ed to

RETURN		.equ	R12										; Return value from c++
W_VAR		.equ	R12										; First (w) value from c++
X_VAR		.equ	R13										; Second (x) value from c++
Y_VAR		.equ	R14										; Third (y) value from c++
Z_VAR		.equ	R15										; Fourth (z) value from c++


;-------------------------------------------------------------------------------
; RAM Definitions
;-------------------------------------------------------------------------------
			.data
			.bss	adc_temp, 8								; Used to store ADC hex parts for print
			.bss	button, 2								; Stores button presses
			.bss	runtime, 2								; Stores what the program should do
			.bss	samples, 40								; The samples to be collected

			.bss	base, 10								; Baseline measurments
			.bss	latest, 10								; Current messurments
			.bss	button_temp, 2							; Stores how to interpret keypress
			.bss	STATUS, 2								; Stores how to interpret keypress


;-------------------------------------------------------------------------------
; Definitions & "Linked" Assembler functions
;-------------------------------------------------------------------------------
			.def 	board_reset
			.def 	clock_setup

			.def	delay
			.def 	delay_500ms
			.def 	delay_10ms
			.def 	delay_5ms

			.def 	byte_to_hex
			.def 	bit_to_num

			.def	adc_print
			.def	touch_print

			.def	print_hex
			.def	print_ready
			.def	print_done

			.def	waitForCenter
			.def	waitForUpDown
			.def	waitForLeftRight

			.def	getSamples
			.def	convertSamples
			.def	displaySamples

			.def	touch_setup
			.def	touch_read
			.def	touch_baseline
			.def	touch_report
			.def	touch_test

			.def	display
			.def	display_stop

			.def	uart_setup
			.def	uart_print
			.def	uart_newline

			.def	adc_setup
			.def	adc_read

            .text
            .retain
            .retainrefs


;-------------------------------------------------------------------------------
; Sets up board
;-------------------------------------------------------------------------------
board_reset:; Clear and Reset Port 1
			clr		P1OUT
    		clr		P1DIR
    		clr		P1SEL
    		clr		P1SEL2
    		clr		P1IE
    		clr		P1IES
			; Clear and Reset Port 2
    		clr		P2OUT
    		clr		P2DIR
    		clr		P2SEL
    		clr		P2SEL2
    		clr		P2IE
    		clr		P2IES
			; Clear and Reset Port 3
    		clr		P3OUT
    		clr		P3DIR
    		clr		P3SEL
    		clr		P3SEL2
			ret


;-------------------------------------------------------------------------------
; Setups and select which clock frequencies to use
;-------------------------------------------------------------------------------
clock_setup:
ACLK_CHK	bit		#BIT4, W_VAR
			jeq		ACLK_EN

CLK_CONT	and		#0x0F, W_VAR

			cmp		#0x00, W_VAR
			jeq		SET_1MHZ

			cmp		#0x01, W_VAR
			jeq		SET_8MHZ

			cmp		#0x02, W_VAR
			jeq		SET_12MHZ

			cmp		#0x03, W_VAR
			jeq		SET_16MHZ

			cmp		#0x04, W_VAR
			jeq		SET_ACLK

CLK_EXIT	ret

SET_1MHZ	cmp.b	#0xFF, CALBC1_1MHZ
			jeq		CLK_TRAP
			mov.b	CALDCO_1MHZ, DCOCTL
			mov.b	CALBC1_1MHZ, BCSCTL1
			ret

SET_8MHZ	cmp.b	#0xFF, CALBC1_8MHZ
			jeq		CLK_TRAP
			mov.b	CALDCO_8MHZ, DCOCTL
			mov.b	CALBC1_8MHZ, BCSCTL1
			ret

SET_12MHZ	cmp.b	#0xFF, CALBC1_12MHZ
			jeq		CLK_TRAP
			mov.b	CALDCO_12MHZ, DCOCTL
			mov.b	CALBC1_12MHZ, BCSCTL1
			ret

SET_16MHZ	cmp.b	#0xFF, CALBC1_16MHZ
			jeq		CLK_TRAP
			mov.b	CALDCO_16MHZ, DCOCTL
			mov.b	CALBC1_16MHZ, BCSCTL1
			ret

SET_ACLK	bic.b	#XTS, DCOCTL
			bic.b	#BIT4 + BIT5, BCSCTL1
			ret

ACLK_EN		bic.b	#XIN, P2DIR
			bis.b	#XOUT, P2DIR
			bis.b	#XIN + XOUT, P2SEL
			bic.b	#XIN + XOUT, P2SEL2
			jmp		CLK_CONT

CLK_TRAP	bis.b	#0xFF, P1DIR
			xor.b	#0xFF, P1OUT
			jmp		CLK_TRAP


;-------------------------------------------------------------------------------
; Uses Timer A to delay intput amount of time with an interrupt
;-------------------------------------------------------------------------------
delay:		mov		#CCIE, TACCTL0							; Enable CCR0 interrupt
			mov		W_VAR, TACCR0							; Set  rate
			mov		#TASSEL_2 + MC_2 + TACLR, TACTL			; Turn on Timer A
			clr		SW_FLAG									; Clear SW flag
			eint											; Enable global interrupts

wait_more	tst		SW_FLAG									; Check if SW flag has been triggered
			jz		wait_more								; Otherwise loop

			ret												; Return from function


;-------------------------------------------------------------------------------
; Uses Timer A to delay 500ms with an interrupt
;-------------------------------------------------------------------------------
delay_500ms:
			clr		COUNT									; Clear counting register

cont_500ms	mov		#CCIE, TACCTL0							; Enable CCR0 interrupt
			mov		#rate_500ms, TACCR0						; Set 500 ms rate
			mov		#TASSEL_2 + MC_2 + TACLR, TACTL			; Turn on Timer A
			clr		SW_FLAG									; Clear SW flag
			eint											; Enable global interrupts

wait_500ms	tst		SW_FLAG									; Check if SW flag has been triggered
			jz		wait_500ms								; Otherwise loop

			dint											; Disable global interrupts
			inc		COUNT									; Increment number ot times triggered
			cmp		#count_500ms, COUNT						; See if Timer A has triggered 16 times
			jne		cont_500ms								; Then re-loop

			ret												; Return from function


;-------------------------------------------------------------------------------
; Uses Timer A to delay 50ms with an interrupt
;-------------------------------------------------------------------------------
delay_10ms:
			mov		#CCIE, TACCTL0							; Enable CCR0 interrupt
			mov		#rate_10ms, TACCR0						; Set 10 ms rate
			mov		#TASSEL_2 + MC_2 + TACLR, TACTL			; Turn on Timer A
			clr		SW_FLAG									; Clear SW flag
			eint											; Enable global interrupts

wait_10ms	tst		SW_FLAG									; Check if SW flag has been triggered
			jz		wait_10ms								; Otherwise loop

			ret												; Return from function


;-------------------------------------------------------------------------------
; Uses Timer A to delay 50ms with an interrupt
;-------------------------------------------------------------------------------
delay_5ms:
			mov		#CCIE, TACCTL0							; Enable CCR0 interrupt
			mov		#rate_5ms, TACCR0						; Set 5 ms rate
			mov		#TASSEL_2 + MC_2 + TACLR, TACTL			; Turn on Timer A
			clr		SW_FLAG									; Clear SW flag
			eint											; Enable global interrupts

wait_5ms	tst		SW_FLAG									; Check if SW flag has been triggered
			jz		wait_5ms								; Otherwise loop

			ret												; Return from function

;-------------------------------------------------------------------------------
; Timer A Interrupt (TAR = TACCR0)
;-------------------------------------------------------------------------------
TIMERA0_ISR:
			bic		#CCIE, TACCTL0							; Clear interrupt flag
			mov		#MC_0 + TACLR, TACTL					; Stop counting and clear TAR
			mov		#BIT0, W_VAR							; Trigger software flag
			reti											; Return from interupt


;-------------------------------------------------------------------------------
; Turns a char value into redable hex
;-------------------------------------------------------------------------------
byte_to_hex:cmp.b	#10, W_VAR								; See if 0 <= input <= 9
			jl		hex_num
			cmp.b	#16, W_VAR								; See if A <= input <= F
			jl		hex_alp

hex_null	mov.b	#char_Z, W_VAR							; Otherwise return a 'z'
			ret

hex_num		add.b	#char_0, W_VAR							; Shift input into a number
			ret

hex_alp		add.b	#char_A, W_VAR							; Shift input into a letter
			sub.b	#10, W_VAR								; Shift result by 10
			ret

;-------------------------------------------------------------------------------
; Transforms the but place into a number 1 to 16 or 0 for other or no bits
;-------------------------------------------------------------------------------
bit_to_num:	cmp		#0x00, W_VAR
			jeq		NOBIT

BITF_NUM	bit		#BITF, W_VAR
			jne		BITE_NUM
			mov		#16, RETURN
			ret

BITE_NUM	bit		#BITE, W_VAR
			jne		BITD_NUM
			mov		#15, RETURN
			ret

BITD_NUM	bit		#BITD, W_VAR
			jne		BITC_NUM
			mov		#14, RETURN
			ret

BITC_NUM	bit		#BITC, W_VAR
			jne		BITB_NUM
			mov		#13, RETURN
			ret

BITB_NUM	bit		#BITB, W_VAR
			jne		BITA_NUM
			mov		#12, RETURN
			ret

BITA_NUM	bit		#BITA, W_VAR
			jne		BIT9_NUM
			mov		#11, RETURN
			ret

BIT9_NUM	bit		#BIT9, W_VAR
			jne		BIT8_NUM
			mov		#10, RETURN
			ret

BIT8_NUM	bit		#BIT8, W_VAR
			jne		BIT7_NUM
			mov		#9, RETURN
			ret

BIT7_NUM	bit		#BIT7, W_VAR
			jne		BIT6_NUM
			mov		#8, RETURN
			ret

BIT6_NUM	bit		#BIT6, W_VAR
			jne		BIT5_NUM
			mov		#7, RETURN
			ret

BIT5_NUM	bit		#BIT5, W_VAR
			jne		BIT4_NUM
			mov		#6, RETURN
			ret

BIT4_NUM	bit		#BIT4, W_VAR
			jne		BIT3_NUM
			mov		#5, RETURN
			ret

BIT3_NUM	bit		#BIT3, W_VAR
			jne		BIT2_NUM
			mov		#4, RETURN
			ret

BIT2_NUM	bit		#BIT2, W_VAR
			jne		BIT1_NUM
			mov		#3, RETURN
			ret

BIT1_NUM	bit		#BIT1, W_VAR
			jne		BIT0_NUM
			mov		#2, RETURN
			ret

BIT0_NUM	bit		#BIT0, W_VAR
			jne		NOBIT
			mov		#1, RETURN
			ret

NOBIT		clr		RETURN
			ret


;-------------------------------------------------------------------------------
; Prints the adc value over uart
;-------------------------------------------------------------------------------
adc_print:	clr 	TEMP
			mov		W_VAR, adc_temp(TEMP)
			incd	TEMP
			mov		W_VAR, adc_temp(TEMP)
			incd	TEMP
			mov		W_VAR, adc_temp(TEMP)

			and		#0x300, adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			decd	TEMP

			and		#0xF0, adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			decd	TEMP

			and		#0x0F, adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			call	#uart_newline
			ret

;-------------------------------------------------------------------------------
; Prints which button has been pressed
;-------------------------------------------------------------------------------
touch_print:cmp		#UP, W_VAR
			jeq		UP_P

			cmp		#LEFT, W_VAR
			jeq		LEFT_P

			cmp		#DOWN, W_VAR
			jeq		DOWN_P

			cmp		#RIGHT, W_VAR
			jeq		RIGHT_P

			cmp		#CENTER, W_VAR
			jeq		CENTER_P
			ret

UP_P		mov		#char_U, W_VAR
			jmp		TCH_PR_EXIT

LEFT_P		mov		#char_L, W_VAR
			jmp		TCH_PR_EXIT

DOWN_P		mov		#char_D, W_VAR
			jmp		TCH_PR_EXIT

RIGHT_P		mov		#char_R, W_VAR
			jmp		TCH_PR_EXIT

CENTER_P	mov		#char_C, W_VAR
			jmp		TCH_PR_EXIT

TCH_PR_EXIT	call	#uart_print
			call	#uart_newline
			ret


;-------------------------------------------------------------------------------
; Prints the char value as a hex
;-------------------------------------------------------------------------------
print_hex:	clr 	TEMP
			mov		W_VAR, adc_temp(TEMP)
			incd	TEMP
			mov		W_VAR, adc_temp(TEMP)
			incd	TEMP
			mov		W_VAR, adc_temp(TEMP)
			incd	TEMP
			mov		W_VAR, adc_temp(TEMP)

			and		#0xF000, adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			decd	TEMP


			and		#0xF00, adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			decd	TEMP

			and		#0xF0, adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			rra		adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			decd	TEMP

			and		#0x0F, adc_temp(TEMP)
			mov.b	adc_temp(TEMP), W_VAR
			call	#byte_to_hex
			call	#uart_print
			call	#uart_newline
			ret


;-------------------------------------------------------------------------------
; Prints "READY"
;-------------------------------------------------------------------------------
print_ready:
			mov		#char_R, W_VAR
			call	#uart_print

			mov		#char_E, W_VAR
			call	#uart_print

			mov		#char_A, W_VAR
			call	#uart_print

			mov		#char_D, W_VAR
			call	#uart_print

			mov		#char_Y, W_VAR
			call	#uart_print

			call	#uart_newline
			ret


;-------------------------------------------------------------------------------
; Prints "DONE"
;-------------------------------------------------------------------------------
print_done:	mov		#char_D, W_VAR
			call	#uart_print

			mov		#char_O, W_VAR
			call	#uart_print

			mov		#char_N, W_VAR
			call	#uart_print

			mov		#char_E, W_VAR
			call	#uart_print

			call	#uart_newline
			ret


;-------------------------------------------------------------------------------
; Wait for center button press
;-------------------------------------------------------------------------------
waitForCenter:
			dint
			clr		runtime
			call	#uart_newline
			call	#print_ready

wait_center	clr		RETURN
			call	#touch_read
			cmp		#CENTER, RETURN
			jne		wait_center

			bis		#RUN, runtime

			mov		#CENTER, W_VAR
			call	#display_stop
			call	#touch_print
			;call	#touch_test
			call	#delay_500ms

			eint
			ret


;-------------------------------------------------------------------------------
; Wait for up or down button press
;-------------------------------------------------------------------------------
waitForUpDown:
			dint


wait_ud		clr		RETURN
			call	#touch_read
			cmp		#UP, RETURN
			jeq		up_press

			cmp		#DOWN, RETURN
			jeq		down_press

			jmp		wait_ud

up_press	bic		#SLOW, runtime
			mov		#UP, W_VAR
			jmp		ud_cont

down_press	bis		#FAST, runtime
			mov		#DOWN, W_VAR

ud_cont		call	#touch_print
			call	#touch_test
			call	#delay_500ms

			eint
			ret


;-------------------------------------------------------------------------------
; Wait for left or right button press
;-------------------------------------------------------------------------------
waitForLeftRight:
			dint

wait_lr		clr		RETURN
			call	#touch_read
			cmp		#LEFT, RETURN
			jeq		left_press

			cmp		#RIGHT, RETURN
			jeq		right_press

			jmp		wait_lr

left_press	bic		#LIN, runtime
			mov		#LEFT, W_VAR
			jmp		lr_cont

right_press	bis		#LOG, runtime
			mov		#RIGHT, W_VAR

lr_cont		call	#touch_print
			call	#touch_test
			call	#delay_500ms

			eint
			ret


;-------------------------------------------------------------------------------
; Acquires samples
;-------------------------------------------------------------------------------
getSamples:
			dint
			clr		INDEX
			call	#uart_newline

get_more	call	#adc_read
			call 	#adc_print
			mov		RETURN, samples(INDEX)

			bit		#FAST, runtime
			jeq		dely_fast

dely_slow	call	#delay_10ms
			jmp		get_cont

dely_fast	call	#delay_5ms

get_cont	incd	INDEX
			cmp		#sample_size, INDEX
			jl		get_more

			eint
			ret

;-------------------------------------------------------------------------------
; Convert samples
;-------------------------------------------------------------------------------
convertSamples:
			dint
			clr		INDEX
			;jmp		conv_exit

conv_more	mov		samples(INDEX), TEMP
			bit		#LOG, runtime
			jeq		log_mode

lin_mode	rra		TEMP
			rra		TEMP
			rra		TEMP
			rra		TEMP
			rra		TEMP
			rra		TEMP
			rra		TEMP
			jmp		conv_cont

log_mode	rra		TEMP
			rra		TEMP
			mov		TEMP, W_VAR
			call	#bit_to_num
			mov		RETURN, TEMP

conv_cont	mov.b	TEMP, samples(INDEX)

			incd	INDEX
			cmp		#sample_size, INDEX
			jl		conv_more

conv_exit	eint
			ret

;-------------------------------------------------------------------------------
; Display samples
;-------------------------------------------------------------------------------
displaySamples:
			dint
			clr		INDEX
			call	#uart_newline

disp_more	mov		samples(INDEX), W_VAR
			and		#0x0F, W_VAR
			call	#display
			call	#byte_to_hex
			call	#uart_print
			call	#uart_newline

			call	#delay_500ms

			incd	INDEX
			cmp		#sample_size, INDEX
			jl		disp_more

			call	#print_done
			call	#display_stop
			eint
			ret


;-------------------------------------------------------------------------------
; Measure base line values
;-------------------------------------------------------------------------------
touch_baseline:
			dint											; Disable global interrupts
			mov.b	#LEFT, PINSEL							; Set PINSEL to P2.1
			clr		INDEX									; Clear the index value

meas_base_again
			call 	#touch_setup							; Setup selected pin
			bis 	#MC_2 + TACLR, &TA0CTL					; Start timer

;			mov		#SWdelay, W_VAR
			call 	#SWtimer								; Wait

			xor		#CCIS0, &TA0CCTL1						; Trigger a capture event
			mov		TA0CCR1, base(INDEX)					; Save cap. value in array at INDEX
			bic 	#MC_3, &TA0CTL							; Stop timer

			sub 	#THRESHOLD, base(INDEX)					; Adjust this baseline
			bic.b 	PINSEL, &P2SEL2							; Stop the oscillation on the latest. pin
			rla.b	PINSEL									; Select next pin

			incd	INDEX									; Increment INDEX
			cmp.b	#0xA, INDEX								; Check if done with all five sensors
			jne		meas_base_again

			eint											; Enable global interrupts
			ret


;-------------------------------------------------------------------------------
; Measure latest values routine
;-------------------------------------------------------------------------------
touch_read:
			dint											; Disable global interrupts
			mov.b	#LEFT, PINSEL							; Set PISEL to P2.1
			clr		INDEX									; Clear the index value

meas_latest_again
			call 	#touch_setup							; Setup selected pin
			bis 	#MC_2 + TACLR, &TA0CTL	 				; Start timer

;			mov		#SWdelay, W_VAR
			call 	#SWtimer								; Wait

			xor 	#CCIS0, &TA0CCTL1						; Trigger a capture event
			mov 	TA0CCR1, latest(INDEX)					; Save cap. value in array at INDEX
			bic 	#MC_3, &TA0CTL 							; Stop timer

			bic.b 	PINSEL, &P2SEL2							; Stop the oscillation on the latest. pin
			rla.b	PINSEL									; Prepare next x

			incd	INDEX									; Increment INDEX
			cmp.b	#0x0A, INDEX							; Check if done with all five sensors
			jne		meas_latest_again

			call	#touch_report							; Check which buttons are pressed
			mov		STATUS, RETURN							; Return value
			eint											; Enable global interrupts
			ret


;-------------------------------------------------------------------------------
; Setup for measuring cap. buttons
;-------------------------------------------------------------------------------
touch_setup:
			bic.b 	PINSEL, &P2DIR							; Select pin to be an input
			bic.b 	PINSEL, &P2SEL							; Selct pin to osc. mode
			bis.b 	PINSEL, &P2SEL2

		 	mov 	#TASSEL_3, &TA0CTL						; Select INCLK
			mov 	#CM_3 + CCIS_2 + CAP, &TA0CCTL1			; Setup Timer A capture register

			ret


;-------------------------------------------------------------------------------
; Determine which sensor was pressed routine
;-------------------------------------------------------------------------------
touch_report:
			clr		STATUS									; Clear STATUS value
			clr		INDEX									; Clear INDEX value
			mov 	#LEFT, button_temp						; Move 0x01 into TEMP register

CheckNextSensor
			cmp		latest(INDEX), base(INDEX)				; Check if key is pressed
			jl		NotThisSensor							; Jump if no key pressed
			bis 	button_temp, STATUS						; Update sensor status
			ret

NotThisSensor
			incd	INDEX									; Increment INDEX value
			rla	 	button_temp								; Shift TEMP value left by 1
			cmp		#0x0A, INDEX							; If INDEX has reached the end of the array
			jne		CheckNextSensor							; Continue until all of the array is checked
			ret


;-------------------------------------------------------------------------------
; Test routine
;-------------------------------------------------------------------------------
touch_test:	bis.b	#0xF9, P1DIR
			clr.b	P1OUT

LED0_tst	cmp		#UP, STATUS						; Check if this is the LED to turn on
			jne		LED1_tst						; Check next LED
			mov.b	#LEDA, P1OUT					; Turn on LED
			ret

LED1_tst	cmp		#LEFT, STATUS					; Check if this is the LED to turn on
			jne		LED2_tst						; Check next LED
			mov.b	#LEDB, P1OUT					; Turn on LED
			ret

LED2_tst	cmp		#DOWN, STATUS					; Check if this is the LED to turn on
			jne		LED3_tst						; Check next LED
			mov.b	#LEDC, P1OUT					; Turn on LED
			ret

LED3_tst	cmp		#RIGHT, STATUS					; Check if this is the LED to turn on
			jne		LED4_tst						; Check next LED
			mov.b	#LEDD, P1OUT					; Turn on LED
			ret

LED4_tst	cmp		#CENTER, STATUS					; Check if this is the LED to turn on
			jne		NOLED_tst						; Check next LED
			mov.b	#LEDE, P1OUT					; Turn on LED
			ret

NOLED_tst	ret


;-------------------------------------------------------------------------------
; Software timer --> used as a last resort
;-------------------------------------------------------------------------------
SWtimer:	mov		#SWdelay, DELAY
more		dec		DELAY
			tst		DELAY
			jnz		more
			ret


;-------------------------------------------------------------------------------
; Setup timer to display all selected LEDs
;-------------------------------------------------------------------------------
display:	mov		#1, LED									; Clear led value
			mov		W_VAR, VAL								; Move led value to count up to

		    mov	   	#WDT_MDLY_0_5, &WDTCTL		    		; WDT interval timer
            bis.b   #WDTIE, &IE1             				; Enable WDT interrupt

			eint											; Enable global interrupts
			ret												; Return from function call


;-------------------------------------------------------------------------------
; Stop display
;-------------------------------------------------------------------------------
display_stop:
			mov	   	#WDTPW + WDTHOLD, &WDTCTL	    		; Stop watchdog timer
            bic.b   #WDTIE, &IE1             				; Disable WDT interrupt

            bis.b	#LED_PINS, P1DIR						; Turn LED pins into outputs
			bic.b	#LED_PINS, P1OUT						; Turn off all LEDs
			ret												; Return from function call


;-------------------------------------------------------------------------------
; Selects which LED to turn on
;-------------------------------------------------------------------------------
select:		bis.b	#LED_PINS, P1DIR						; Turn LED pins into outputs
			bic.b	#LED_PINS, P1OUT						; Turn off all LEDs

			cmp		#0, LED									; If != 0
			jne		sel_cont								; Then continue
			ret												; Otherwise return

sel_cont	cmp		#1, LED									; If LED 0 is selcted
			jeq		LED0_SEL								; Then jump to turn it on

			cmp		#2, LED									; If LED 1 is selcted
			jeq		LED1_SEL								; Then jump to turn it on

			cmp		#3, LED									; If LED 2 is selcted
			jeq		LED2_SEL								; Then jump to turn it on

			cmp		#4, LED									; If LED 3 is selcted
			jeq		LED3_SEL								; Then jump to turn it on

			cmp		#5, LED									; If LED 4 is selcted
			jeq		LED4_SEL								; Then jump to turn it on

			cmp		#6, LED									; If LED 5 is selcted
			jeq		LED5_SEL								; Then jump to turn it on

			cmp		#7, LED									; If LED 6 is selcted
			jeq		LED6_SEL								; Then jump to turn it on

			cmp		#8, LED									; If LED 7 is selcted
			jeq		LED7_SEL								; Then jump to turn it on

			cmp		#9, LED									; If LED 8 is selcted
			jeq		LED8_SEL								; Then jump to turn it on
			ret												; Else return from function

LED0_SEL	bis.b	#LED0, P1OUT							; Turn on LED 0
			ret												; Return from function

LED1_SEL	bis.b	#LED1, P1OUT							; Turn on LED 1
			ret												; Return from function

LED2_SEL	bis.b	#LED2, P1OUT							; Turn on LED 2
			ret												; Return from function

LED3_SEL	bis.b	#LED3, P1OUT							; Turn on LED 3
			ret												; Return from function

LED4_SEL	bis.b	#LED4, P1OUT							; Turn on LED 4
			ret												; Return from function

LED5_SEL	bis.b	#LED5, P1OUT							; Turn on LED 5
			ret												; Return from function

LED6_SEL	bis.b	#LED6, P1OUT							; Turn on LED 6
			ret												; Return from function

LED7_SEL	bis.b	#LED7, P1OUT							; Turn on LED 7
			ret												; Return from function

LED8_SEL	bis.b	#LED8, P1OUT							; Turn on LED 8
			ret												; Return from function


;-------------------------------------------------------------------------------
; Watchdog Interrupt
;-------------------------------------------------------------------------------
WDT_ISR:	dint											; Disable interupts

			call	#select									; Turn on selected LED

			cmp		VAL, LED								; If current LED >= value
			jge		ClrLED									; Then led register
			inc		LED										; Increment to next state

			eint											; Re-Enable interrupt
			reti											; Return from interupt

ClrLED		clr		LED										; Clear led register
			eint											; Re-Enable interrupt
			reti											; Return from interupt


;-------------------------------------------------------------------------------
; Sets up UART connection for 9600 Baud / 8 Bits / No-parity / 1 Stop-Bit
;-------------------------------------------------------------------------------
uart_setup:	dint										; Disable global interrupts

			bis.b	#TX_PIN + RX_PIN, P1SEL				; Sets up UART Tx & Rx pins
			bis.b	#TX_PIN + RX_PIN, P1SEL2

			clr.b 	&UCA0CTL0
			clr.b 	&UCA0CTL1
			mov.b 	#UCSSEL1 + UCSSEL0, &UCA0CTL1 		; UCLK = SMCLK ~1.05 MHz
			clr.b 	&UCA0STAT
			mov.b 	#BAUD0, &UCA0BR0 					; Set Baud Rate of UART interface
			mov.b 	#BAUD1, &UCA0BR1
			mov.b 	#02h, &UCA0MCTL 					; UCBRFx = 0, UCBRSx = 1, UCOS16 = 0
			bic.b  	#UCSWRST, &UCA0CTL1					; **Initialize USI state machine**
			bis.b  	#UCA0RXIE, &IE2 					; Enable USART0 RX interrupt

			call	#TXempty							; Make sure Tx buffer is empty before starting

			eint										; Enable global interrupts
			ret											; Return from function call


;-------------------------------------------------------------------------------
; Prints a single character over the UART connection
;-------------------------------------------------------------------------------
uart_print:	call	#TXempty							; Wait for char to send
            mov.b   W_VAR, &UCA0TXBUF       			; Load char into Tx register
			ret											; Return from function call


;-------------------------------------------------------------------------------
; Creates a newline in the UART connection
;-------------------------------------------------------------------------------
uart_newline:
			call	#TXempty							; Wait for char to send
            mov.b   #0x0A, &UCA0TXBUF    	   			; Load newline into Tx register

            call	#TXempty							; Wait for char to send
            mov.b   #0x0D, &UCA0TXBUF	       			; Load carriage return into Tx register
			ret											; Return from function call


;-------------------------------------------------------------------------------
; Wait for Tx Empty Function
;-------------------------------------------------------------------------------
TXempty:    dint										; Disable global interrupts

			bit.b 	#UCA0TXIFG, &IFG2 					; USCI_A0 Transmit Interrupt?
			jz		TXempty								; Wait until Tx is empty

			eint										; Enable global interrupts
			ret            								; Return from function call


;-------------------------------------------------------------------------------
; Sets up ADC10 to read from Pin 0 / 1.5V / x64 S&H / ADC Osc. Clock
;-------------------------------------------------------------------------------
adc_setup:	bis.b 	#A0, &ADC10AE0						; Set P1.0 as an analog input
			mov	 	#SREF_1 + ADC10SHT_3 + REFON + ADC10ON, &ADC10CTL0
			mov	 	#INCH_0 + ADC10DIV_0, &ADC10CTL1
			ret											; Return from function call


;-------------------------------------------------------------------------------
; Starts and ADC conversion and waits for result
;-------------------------------------------------------------------------------
adc_read:	dint										; Disable global interrupts
			bis.b 	#A0, &ADC10AE0						; Set P1.0 as an analog input
			call	#adc_setup							; Setup ADC10 registers
			bis 	#(ENC + ADC10SC), &ADC10CTL0 		; Start a conversion

adc_busy	bit		#BUSY, ADC10CTL1					; Wait for ADC to finish
			jnz		adc_busy

			mov		ADC10MEM, RETURN					; Return ADC10 value
			bic.b 	#A0, &ADC10AE0						; CLear P1.0 from an analog input
			eint										; Enable global interrupts
			ret											; Return from function call


;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
			.sect  	".int09"
            .short  TIMERA0_ISR

			.sect  	".int10"
            .short  WDT_ISR

			.end
