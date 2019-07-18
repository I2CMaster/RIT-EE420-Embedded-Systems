#include <msp430.h> 
#include <library.h>


void main(void) {
	__wdt_stop();

	board_reset();
	clock_setup(MCLK_1MHz);
	uart_setup();

	touch_baseline();

	while(1) {
	    waitForCenter();
	    waitForUpDown();
	    waitForLeftRight();

	    getSamples();
	    //convertSamples();
	    displaySamples();
	}
}

