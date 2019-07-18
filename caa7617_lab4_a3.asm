            ; Include device header file, set into flash, and assign RESET label
            .cdecls C, LIST, "msp430.h"
			.text
            .global	RESET


			; Stop watchdog timer and entry-point
RESET       mov	   #WDTPW | WDTHOLD, &WDTCTL

			; Clear the all registers
			clr		R4	; A - Multiplicand
			clr		R5	; B - Multiplier
			clr		R6	; Sum
			clr		R7	; Count
			clr		R8	; Temp.

			; Initilize A/B with two numbers and set up for loop
			mov		#0x34, R4
			mov		#0xAA, R5


			; Entry into multiply function with 8-bit operands
MULT		inc 	R7
			mov		R5, R8
			and		#1, R8
			cmp		#1, R8
			jeq		B0EQ1

			; Preform rotation and if count = 9 then end program
MULTCONT	rla 	R4
			rrc		R5
			cmp 	#9, R7
			jlo		MULT
			jmp		END

			; If the LSB of B equals 1 then add A to Sum
B0EQ1		add 	R4, R6
			jmp		MULTCONT


			; End of the program
END			nop
			jmp END

			; MSP430 RESET Vector
            .sect   ".reset"
            .short  RESET
            
