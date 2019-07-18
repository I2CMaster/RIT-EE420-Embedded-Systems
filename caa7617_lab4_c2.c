#include <msp430.h> 

#define run     0xFF
#define zeros   0x00
#define ones    0xFF
#define odds    0x55
#define evens   0xAA


int main(void) {
    WDTCTL = WDTPW | WDTHOLD;   // Stop watchdog timer

    volatile unsigned int i = 0, j = 0, sum = 0;
    volatile unsigned int ArrayFill [4][4];

    // Initialize ArrayFill with 0xFF
    for (i = 0; i <= 3; i++)
        for (j = 0; j <= 3; j++)
            ArrayFill[i][j] = 0xff;

    // Fill ArrayFill and calculate the sum of all elements
    for (i = 0; i <= 3; i++) {
        for (j = 0; j <= 3; j++) {
            switch (i) {
                case 0:
                    ArrayFill[i][j] = zeros;
                    break;

                case 1:
                    ArrayFill[i][j] = ones;
                    break;

                case 2:
                    ArrayFill[i][j] = odds;
                    break;

                case 3:
                    ArrayFill[i][j] = evens;
                    break;

                default: break;
            }

            sum += ArrayFill[i][j];
        }
    }
    sum = sum;

    while (run);

    return 0;
}
