#include <msp430.h> 

#define stop    0x00
#define run     0x01
#define wait    20000

unsigned int i = 0;


void main(void) {
    // Stop watchdog timer and set Port 1, Pin 0 as an output
	WDTCTL = WDTPW | WDTHOLD;
	P1DIR |= 0x01;

	while(run) {
	    // Toggle Pin 0 (Green LED) and use SW wait
	    P1OUT ^= 0x01 | 0x07;
	    for(i = 0; i < wait; i++);
	}
}

