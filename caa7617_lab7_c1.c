#include <msp430.h> 

#define STOP        0
#define RUN         1
#define OFF         0
#define ON          1
#define DELAY       0x0F


void setup(void) {
    WDTCTL = WDTPW | WDTHOLD;

    P1DIR |= BIT0;
    P1SEL &= ~BIT0;
    P1SEL2 &= ~BIT0;

    P2DIR &= ~BIT5;
    P1SEL &= ~BIT5;
    P2SEL2 |= BIT5;

    TA0CTL = TASSEL_3;
    TA0CCTL1 = CM_3 + CCIS_2 + CAP;
}

void delay(void) {
    volatile unsigned int i = DELAY;
    while(i > 0) i--;
}

unsigned int check(void) {
    TA0CTL |= MC_2 + TACLR;
    delay();

    TA0CCTL1 ^= CCIS0;
    unsigned int val = TA0CCR1;
    TA0CTL &= ~(MC1 + MC0);

    return val;
}


int main(void) {
    setup();

    volatile unsigned int state = OFF;
    volatile unsigned int baseline = check();
    volatile unsigned int high_thres = baseline - 2;
    volatile unsigned int low_thres = baseline - 10;

    while(RUN) {
        volatile unsigned int value = check();

        if((state == OFF) && (value < low_thres)) {
            state = ON;
            P1OUT ^= BIT0;
        } else if((state == ON) && (value > high_thres)) {
            state = OFF;
        }
    }

    return 0;
}
