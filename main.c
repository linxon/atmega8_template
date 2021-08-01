#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <util/delay.h>

#include "typedef.h"

int main() {
    uart_init();
    printf("Ready!\n");

    for (;;) {
        ;
    }

    fclose(&uart_str);

    return 0;
}

void uart_init(void) {
    UBRRH = (unsigned char) (USART_SCALED_UBRR >> 8);
    UBRRL = (unsigned char) USART_SCALED_UBRR;

    UCSRB |= (1 << RXEN) | (1 << TXEN);
    UCSRC |= (1 << URSEL) | (1 << USBS) | (1 << UCSZ1) | (1 << UCSZ0);

    stdin = &uart_str;
    stdout = &uart_str;
}

byte uart_rx_char(void) {
    loop_until_bit_is_set(UCSRA, RXC);
    return UDR;
}

void uart_tx_char(unsigned char data) {
    if (data == '\n')
        uart_tx_char('\r');

    loop_until_bit_is_set(UCSRA, UDRE);
    UDR = data;
}
