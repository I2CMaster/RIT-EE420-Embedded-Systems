#include <msp430.h>

#define stop    0x01
#define run     0x01


void main(void) {
    // Stop watchdog timer and set P1.0 as an output
    WDTCTL = WDTPW | WDTHOLD;
    P1DIR |= 0x01;

    while(run) {
        // Initialize i and toggle P1.0
        volatile unsigned int i;
        P1OUT ^= 0x01;

        // SW delay
        i = 10000;
        do i--;
        while(i != 0);
    }
}

