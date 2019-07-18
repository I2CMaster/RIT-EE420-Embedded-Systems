#include <msp430.h> 

#define STOP            0
#define RUN             1

#define SET             0
#define HOLD            1

#define DELAY           0xFF
#define THRESHOLD       0x80

#define CENTER          0b00000001              // Center LED
#define TOP_LEFT        0b11101000              // Top Left LED
#define BOTTOM_LEFT     0b00100000              // Bottom Left LED
#define BOTTOM_RIGHT    0b10111000              // Bottom Right LED
#define TOP_RIGHT       0b10000000              // Top Right LED


void setup(void) {
    WDTCTL = WDTPW | WDTHOLD;

    P1DIR |= 0xFF;
    P1SEL &= ~0xFF;
    P1SEL2 &= ~0xFF;
    P1OUT &= ~0xFF;

    P2DIR |= 0xFF;
    P2SEL &= ~0xFF;
    P2SEL2 &= ~0xFF;

    TA0CTL = TASSEL_3;
    TA0CCTL1 = CM_3 + CCIS_2 + CAP;
}

void delay(void) {
    volatile unsigned int i = DELAY;
    while(i > 0) i--;
}

unsigned int check(unsigned int pin) {
    P2DIR |= 0xFF;
    P2SEL &= ~0xFF;
    P2SEL2 &= ~0xFF;

    switch(pin) {
        case 0:     // Center Button
            P2DIR &= ~BIT5;
            P2SEL &= ~BIT5;
            P2SEL2 |= BIT5;
            break;

        case 1:     // Top-Left Button
            P2DIR &= ~BIT1;
            P2SEL &= ~BIT1;
            P2SEL2 |= BIT1;
            break;

        case 2:     // Bottom-Left Button
            P2DIR &= ~BIT2;
            P2SEL &= ~BIT2;
            P2SEL2 |= BIT2;
            break;

        case 3:     // Bottom-Right Button
            P2DIR &= ~BIT3;
            P2SEL &= ~BIT3;
            P2SEL2 |= BIT3;
            break;

        case 4:     // Top-Right Button
            P2DIR &= ~BIT4;
            P2SEL &= ~BIT4;
            P2SEL2 |= BIT4;
            break;

        default:
            break;
    }

    TA0CTL |= MC_2 + TACLR;
    delay();

    TA0CCTL1 ^= CCIS0;
    unsigned int val = TA0CCR1;
    TA0CTL &= ~(MC1 + MC0);

    return val;
}

void display(unsigned int pin) {
    switch(pin) {
        case 0:     // Center LED
            P1OUT = CENTER;
            break;

        case 1:     // Top-Left LED
            P1OUT = TOP_LEFT;
            break;

        case 2:     // Bottom-Left LED
            P1OUT = BOTTOM_LEFT;
            break;

        case 3:     // Bottom-Right LED
            P1OUT = BOTTOM_RIGHT;
            break;

        case 4:     // Top-Right LED
            P1OUT = TOP_RIGHT;
            break;

        default:
            break;
    }
}


int main(void) {
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	unsigned int i = 0;
	unsigned int baseline[5] = {0, 0, 0, 0, 0};
	unsigned int current[5] = {0, 0, 0, 0, 0};

	setup();

	for(i = 0; i < 5; i++) {
	    baseline[i] = check(i) - THRESHOLD;
	}

	while(RUN) {
	    if(SET) P1OUT &= ~0xFF;

	    for(i = 0; i < 5; i++) {
	        current[i] = check(i);
	        if(current[i] < baseline[i]) display(i);
	    }
	}

	return 0;
}
