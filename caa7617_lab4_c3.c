#include <msp430.h> 


int main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// Stop watchdog timer
	
	volatile unsigned int A = 0x34, B = 0xAA, sum = 0, count = 0, temp = 0;

	for (count = 1; count <= 8; count++) {
	    temp = B & 1;
	    if (temp == 1) {
	        sum += A;
	    }

	    B >>= 1;
	    A <<= 1;
	}

	while(1);

	return 0;
}

