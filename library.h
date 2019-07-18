#ifndef LIBRARY_H_
#define LIBRARY_H_

#define CHECK_BIT(var, pos)     ((((var) & (pos)) > 0 ) ? (1) : (0))

#define __clear_timerA_flg()    (TACTL &= ~TAIFG)
#define __clear_ccr0_flg()      (TACCTL0 &= ~CCIFG)
#define __clear_ccr1_flg()      (TACCTL1 &= ~CCIFG)
#define __clear_ccr2_flg()      (TACCTL2 &= ~CCIFG)

#define __wdt_stop()            (WDTCTL = WDTPW + WDTHOLD)

#define MCLK_1MHz               0x00
#define MCLK_8MHz               0x01
#define MCLK_12MHz              0x02
#define MCLK_16MHz              0x03
#define ACLK_32KHz              0x03
#define ACLK_ENABLE             BIT4

#define RUN                     BIT0
#define SLOW                    ~BIT1
#define FAST                    BIT1
#define LIN                     ~BIT2
#define LOG                     BIT2

/* #define PROX                 BIT0 */  // Not used for this project
#define LEFT                    BIT1
#define DOWN                    BIT2
#define RIGHT                   BIT3
#define UP                      BIT4
#define CENTER                  BIT5

#define LED0        0x01
#define LED1        0x02
#define LED2        0x03
#define LED3        0x04
#define LED4        0x05
#define LED5        0x06
#define LED6        0x07
#define LED7        0x08
#define LED8        0x09
#define LED_CENTER  0x09
#define NOLED       0x00

extern void board_reset(void);
extern void clock_setup(unsigned int);

extern void delay(unsigned int);
extern void delay_500ms(void);
extern void delay_10ms(void);
extern void delay_5ms(void);

extern char byte_to_hex(char);
extern char bit_to_num(char);

extern void adc_print(unsigned int);
extern void touch_print(unsigned int);

extern void print_hex(char);
extern void print_ready(void);
extern void print_done(void);

extern void waitForCenter(void);
extern void waitForUpDown(void);
extern void waitForLeftRight(void);

extern void getSamples(void);
extern void convertSamples(void);
extern void displaySamples(void);

extern void touch_setup(unsigned int);
extern unsigned int touch_read(void);
extern void touch_baseline(void);
extern unsigned int touch_report(void);
extern void touch_test();

extern void display(unsigned int i);
extern void display_stop(void);

extern void adc_setup(void);
extern unsigned int adc_read(void);

extern void uart_setup(void);
extern void uart_print(char);
extern void uart_newline();

#endif /* LIBRARY_H_ */
