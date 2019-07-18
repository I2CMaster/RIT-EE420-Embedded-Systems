//******************************************************************************
// dxp_Lab5_c1_C55AUDIO1.c
//
// Re-coded completely for CCS v5.4, Launch Pad and Capacitive Booster Pack
//      by Dorin Patru October 2013
//  Re-coded for CCS v7 and v8, Launch Pad and 430BOOST-C55AUDIO Audio Capacitive Booster Pack
//      by Carlos Barrios August 2018
//******************************************************************************

#include <msp430g2553.h>

unsigned int speed = 0x7FFF; // NOTE: Same delay count as ASM version
                             //       Why does it operate slower?

void delay(void); // Function prototype for delay subroutine

int main(void){
    unsigned int i;

    WDTCTL = WDTPW + WDTHOLD; // Stop watchdog timer

    P1DIR &= ~0xFF; // Equivalent to BIC.B #0xFF,&P1DIR
    P1DIR |= 0xF8;  // Equivalent to BIS.B #0xF8,&P1DIR

    while(1){
        P1OUT &= ~0xF8;     // Display LEDs 2, 6, 1, 5 clockwise
        P1OUT |= 0x20;      //
        delay();            //
        P1OUT &= ~0x20;     //
        P1OUT |= 0xD8;      //
        delay();            //
        P1OUT &= ~0xD8;     //
        P1OUT |= 0x10;      //
        delay();            //
        P1OUT &= ~0x10;     //
        P1OUT |= 0xE8;      //
        delay();            //
        P1OUT &= ~0xE8;     //

        P1OUT &= ~0xF8;     // Display loop for LEDs 4, 8, 3, 7 clockwise
        for (i=7; i>5; i--)
        {
            P1OUT |= (1 << i);
            P1OUT &= (1 << i);
            delay();
            P1OUT &= ~(1 << i);
            P1OUT |= ~(1 << i);
            delay();
        }
    }
}

void delay(void){
    unsigned int j;
    j = speed;
    j--;
    while(j > 0){   // software delay
        j--;
        j--;
        }
}
