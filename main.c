#include <stdio.h>
#include <stdint.h>
#include <util/delay.h>
#include <avr/interrupt.h>

#include "typedef.h"

int main() {
    uart_init();
    printf("Ready!\n");

    for (;;) {
        asm("nop");
    }

    fclose(&uart_str);

    return 0;
}

void uart_init(void) {
    unsigned char old_sreg = SREG;
    cli();

    UBRRH = (unsigned char) (USART_SCALED_UBRR >> 8);
    UBRRL = (unsigned char) USART_SCALED_UBRR;

    SREG = old_sreg;

    UCSRB |= (1 << RXEN) | (1 << TXEN);
    UCSRC |= (1 << URSEL) | (1 << USBS) | (1 << UCSZ1) | (1 << UCSZ0);

    stdin = &uart_str;
    stdout = &uart_str;
}

int _uart_rx_char(FILE *stream) {
    loop_until_bit_is_set(UCSRA, RXC);
    return UDR;
}

int _uart_tx_char(char data, FILE *stream) {
    if (data == '\n')
        _uart_tx_char('\r', stream);

    loop_until_bit_is_set(UCSRA, UDRE);
    UDR = data;
}
