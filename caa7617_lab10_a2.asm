;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;******************************************************************************
; MSP430G2553 UART Demonstration
;
; Description: When the phrase PRINT is recieved send "hello world, from the MSP430   "
; Default SMCLK = DCOCLK ~= 1.05 MHz
; Baud Rate ~= 9600 = (UCAxBR0 + UCAxBR1 × 256)
;******************************************************************************
            .cdecls C, LIST, "msp430g2553.h"

BUFFER   	.equ	R10										; Tx Buffer
INDEX		.equ	R11										; Counts char. in string
SOURCE		.equ	R12										; Holds address of string
STATE		.equ	R13										; Holds the state

SourceStr:  .string	"hello world, from MSP430" 		        ; String constant, stored between 0xC000 and 0xFFFF

            .text
            .global	RESET
            .retain
            .retainrefs


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END, SP         				; Initialize stackpointer
StopWDT     mov.w   #WDTPW | WDTHOLD, &WDTCTL  				; Stop watchdog timer

ClrReg		clr		BUFFER									; Clear Tx buffer
			clr		INDEX									; Clear string index
			clr		SOURCE									; Clear string addres
			clr		STATE									; Clear state machine variable

SetupP1 	clr.b	&P1OUT
			mov.b	#BIT6 + BIT0, &P1DIR					; P1.6 / P1.0 = TxLED / RxLED
			mov.b 	#BIT2 + BIT1, &P1SEL 					; P1.2 / P1.1 = TXD / RXD
			mov.b 	#BIT2 + BIT1, &P1SEL2					; P1.2 / P1.1 = TXD / RXD

SetupUART0 	clr.b 	&UCA0CTL0
			clr.b 	&UCA0CTL1
			mov.b 	#UCSSEL1 + UCSSEL0, &UCA0CTL1 			; UCLK = SMCLK ~1.05 MHz
			clr.b 	&UCA0STAT
;			bis.b 	#UCLISTEN, &UCA0STAT					; loopback - used for debugging only

			mov.b 	#110, &UCA0BR0 							; Set Baud Rate of UART interface
			mov.b 	#00h, &UCA0BR1
			mov.b 	#02h, &UCA0MCTL 						; UCBRFx = 0, UCBRSx = 1, UCOS16 = 0

			bic.b  	#UCSWRST, &UCA0CTL1						; **Initialize USI state machine**
			bis.b  	#UCA0RXIE, &IE2 						; Enable USART0 RX interrupt

			call	#TXempty								; Make sure Tx buffer is empty before starting

			eint 											; Enable global interrupts


;-------------------------------------------------------------------------------
; Main loop
;-------------------------------------------------------------------------------
Mainloop	jmp		Mainloop								; Wastes time


;------------------------------------------------------------------------------
; UART Rx Interrupt Service Routine
;------------------------------------------------------------------------------
UARTRX_ISR: dint 											; Disable global interrupts
			xor.b	#BIT0, &P1OUT							; Toggle Rx LED (Green)
			mov.b 	&UCA0RXBUF, BUFFER 						; Move received byte into buffer
			add.b 	#0x20, BUFFER 							; Change from upper to lower case

TX1 		bit.b 	#UCA0TXIFG, &IFG2						; USI TX buffer ready?
			jz 		TX1 									; Wait until Tx buffer is ready

			mov.b 	BUFFER, &UCA0TXBUF 						; Transmit converted character
			call	#Update									; Check to see if "PRINT" is recieved
			reti 											; Return from interrupt


;------------------------------------------------------------------------------
; "PRINT" State Machine - Detects if the char's p, r, i, n, t have been recieved
;------------------------------------------------------------------------------
Update:		cmp		#0, STATE								; Check which char's have been recieved
			jeq		P_SS									; Check if char is 'p'
			cmp		#1, STATE								; Check which char's have been recieved
			jeq		R_SS									; Check if char is 'r'
			cmp		#2, STATE								; Check which char's have been recieved
			jeq		I_SS									; Check if char is 'i'
			cmp		#3, STATE								; Check which char's have been recieved
			jeq		N_SS									; Check if char is 'n'
			cmp		#4, STATE								; Check which char's have been recieved
			jeq		T_SS									; Check if char is 't'
			jmp		Reset									; Otherwise reset STATE machine


P_SS		cmp		#0x70, BUFFER							; Check if 'p' is recieved
			jne		Reset									; If not then reset STATE
			mov		#1, STATE								; Otherwise advance to "next" STATE
			ret												; Return from function

R_SS		cmp		#0x72, BUFFER							; Check if 'r' is recieved
			jne		P_SS									; If not then reset STATE
			mov		#2, STATE								; Otherwise advance to "next" STATE
			ret												; Return from function

I_SS		cmp		#0x69, BUFFER							; Check if 'i' is recieved
			jne		P_SS									; If not then reset STATE
			mov		#3, STATE								; Otherwise advance to "next" STATE
			ret												; Return from function

N_SS		cmp		#0x6E, BUFFER							; Check if 'n' is recieved
			jne		P_SS									; If not then reset STATE
			mov		#4, STATE								; Otherwise advance to "next" STATE
			ret												; Return from function

T_SS		cmp		#0x74, BUFFER							; Check if 't' is recieved
			jne		P_SS									; If not then reset STATE

Print		call	#PrintStr								; Print stored string

Reset		clr		STATE									; Reset State machine
			ret												; Return from function


;-------------------------------------------------------------------------------
; Print "Hello World" Function
;-------------------------------------------------------------------------------
PrintStr:	mov		#SourceStr, SOURCE         				; Load address of string

			call	#TXempty								; Wait for char to send
			xor.b	#BIT6, &P1OUT							; Toggle Tx LED (Red)
            mov.b   #0x0A, &UCA0TXBUF       				; Make a newline (Line feed)

            call	#TXempty								; Wait for char to send
			xor.b	#BIT6, &P1OUT							; Toggle Tx LED (Red)
            mov.b   #0x0D, &UCA0TXBUF       				; Start at beggining of next line (Carriage Return)

Continue	call	#TXempty								; Wait for char to send
			xor.b	#BIT6, &P1OUT							; Toggle Tx LED (Red)
            mov.b   @SOURCE+, &UCA0TXBUF       				; Load char. into Tx and increment pointer
            cmp.b  	#0x18, SOURCE 				            ; Test if char. is endline / end of string
            jne     Continue                 				; Continue printing if not done

            call	#TXempty								; Wait for char to send
			xor.b	#BIT6, &P1OUT							; Toggle Tx LED (Red)
            mov.b   #0x0A, &UCA0TXBUF       				; Make a newline (Line feed)

            call	#TXempty								; Wait for char to send
			xor.b	#BIT6, &P1OUT							; Toggle Tx LED (Red)
            mov.b   #0x0D, &UCA0TXBUF       				; Start at beggining of next line (Carriage Return)

            ret                                				; Return from function call


;-------------------------------------------------------------------------------
; Wait for Tx Empty Function
;-------------------------------------------------------------------------------
TXempty:    bit.b 	#UCA0TXIFG, &IFG2 						; USCI_A0 Transmit Interrupt?
			jz		TXempty									; Wait until Tx is empty
			ret            									; Return from function call


;-------------------------------------------------------------------------------
; Interrupt Vectors and Stack Pointer definition
;-------------------------------------------------------------------------------
			.global __STACK_END
            .sect 	.stack

            .sect   ".reset"
            .short  RESET

			.sect 	".int07"
isr_USART:	.short 	UARTRX_ISR

			.end
