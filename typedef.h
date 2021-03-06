#include <stddef.h>
#include <avr/io.h>

#define HIGH              1
#define LOW               0

#ifndef F_CPU
#define F_CPU             8000000UL
#endif

typedef unsigned char byte;
typedef unsigned char bool;

#define USART_BAUDRATE 57600
#define USART_SCALED_UBRR ((F_CPU / (USART_BAUDRATE * 16UL)) -1)

void uart_init(void);
int _uart_rx_char(FILE *stream);
int _uart_tx_char(char data, FILE *stream);

static FILE uart_str = FDEV_SETUP_STREAM(&_uart_tx_char, &_uart_rx_char, _FDEV_SETUP_RW);
