;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;******************************************************************************
; MSP430G2553 UART Demonstration
;
; Description: When an upper case char. is recieved, send its lower case version
; Default SMCLK = DCOCLK ~= 1.05 MHz
; Baud Rate ~= 9600 = (UCAxBR0 + UCAxBR1 × 256)
;******************************************************************************
            .cdecls C, LIST, "msp430g2553.h"

BUFFER   	.equ	R10										; Tx Buffer

            .text
            .global	RESET
            .retain
            .retainrefs


;-------------------------------------------------------------------------------
; Setup
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END, SP         				; Initialize stackpointer
StopWDT     mov.w   #WDTPW | WDTHOLD, &WDTCTL  				; Stop watchdog timer

SetupP1 	clr.b	&P1OUT
			mov.b	#BIT6 + BIT0, &P1DIR					; P1.6 / P1.0 = TxLED / RxLED
			mov.b 	#BIT2 + BIT1, &P1SEL 					; P1.2 / P1.1 = TXD / RXD
			mov.b 	#BIT2 + BIT1, &P1SEL2					; P1.2 / P1.1 = TXD / RXD

SetupUART0 	clr.b 	&UCA0CTL0
			clr.b 	&UCA0CTL1
			mov.b 	#UCSSEL1 + UCSSEL0, &UCA0CTL1 			; UCLK = SMCLK ~1.05 MHz
			clr.b 	&UCA0STAT
;			bis.b 	#UCLISTEN, &UCA0STAT					; loopback - used for debugging only

			mov.b 	#109, &UCA0BR0 							; Set Baud Rate of UART interface
			mov.b 	#00h, &UCA0BR1
			mov.b 	#02h, &UCA0MCTL 						; UCBRFx = 0, UCBRSx = 1, UCOS16 = 0

			bic.b  	#UCSWRST, &UCA0CTL1						; **Initialize USI state machine**
			bis.b  	#UCA0RXIE, &IE2 						; Enable USART0 RX interrupt

TX2			bit.b 	#UCA0TXIFG, &IFG2 						; USI TX buffer ready?
			jz 		TX2 									; Jump if TX buffer not ready

			eint											; Enable global interrupts


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
			xor		#BIT6, &P1OUT							; Toggle Tx LED (Red)
			eint											; Enable global interrupts
			reti 											; Return from interrupt


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
