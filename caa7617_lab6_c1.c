#include <msp430.h> 

// Constants to run the program
#define STOP    0
#define RUN     1

// Constants for use of the port and timer
#define PERIOD  1000 - 1
#define PWM1    800
#define PWM2    200
#define DELAY   0xFFFF
#define LED     BIT6


// Setup Timer A for PWM and Port1.0 as an output
void setup(void) {
    WDTCTL = WDTPW | WDTHOLD;

    P1DIR |= LED;
    P1SEL |= LED;

    TA0CTL = TASSEL_2 + MC_1;
    TA0CCR0 = PERIOD;

    TA0CCR1 = PWM1;
    TA0CCTL1 = OUTMOD_7;

    _BIS_SR(GIE);
}


// Wait 'DELAY' amount of time
void wait(void) {
    volatile unsigned int i = DELAY;
    while (i > 0) i--;
}


// Toggle the PWM Duty Cycle
void switchPWM(void) {
    if (TA0CCR1 == PWM1) TA0CCR1 = PWM2;
    else TA0CCR1 = PWM1;
}


int main(void) {
    setup();

    while(RUN) {
        wait();
        switchPWM();
    }

	return 0;
}
