#include <msp430.h> 

#define run     0xff

int main(void) {
    WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer

    volatile unsigned int i = 0, j = 0, sum = 0;
    volatile unsigned int ArrayFill [4][4];

    // Initialize ArrayFill with 0xFF
    for (i = 0; i <= 3; i++)
        for (j = 0; j <= 3; j++)
            ArrayFill[i][j] = 0xff;

    // Fill ArrayFill with the indices values and calculate the sum of the indices
    for (i = 0; i <= 3; i++) {
        for (j = 0; j <= 3; j++) {
            ArrayFill[i][j] = (4 * i) + j ;
            sum = sum + ((4 * i) + j) ;
        }
    }
    sum = sum;
	
    while (run);

	return 0;
}
