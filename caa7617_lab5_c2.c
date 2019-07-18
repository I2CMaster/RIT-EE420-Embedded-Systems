#include <msp430.h> 

#define STOP        0x00
#define RUN         0x01

#define FAST        0x00FF
#define MEDIUM      0x0FFF
#define SLOW        0x7FFF

#define LED_DIR     P1DIR
#define LED         P1OUT


void delay(void) {
    volatile unsigned int j  = SLOW;
    while(j > 0) j--;
}


int main(void) {
    // Stop watchdog timer, setup P1 direction, and turn off LEDs
	WDTCTL = WDTPW | WDTHOLD;
	LED_DIR = 0b11111000;
	LED = 0b00000000;
	unsigned int i = 0;

	// Continuously cycle through LEDs counterclockwise
	while(RUN) {
	    LED &= ~0xF8;
	    for (i = 4; i < 8; i++) {
	        LED &= ~(1 << i);
	        LED |= ~(1 << i);
	        delay();

	        LED |= (1 << i);
	        LED &= (1 << i);
	        delay();
	    }
	}

	return 0;
}

