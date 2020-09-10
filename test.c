#include "stdint.h"
#include "stdio.h"


void print_hex(const void *buf, int length)
{
    uint8_t *s = (uint8_t *)buf;

    printf("\n%d <<< \n", length);

    for (int i = 0; i < length; i++)
        // printf("%02x[%c]%s ", s[i], s[i],
        printf("%c%s", s[i],
            (i + 1) % 63 == 0 ? "\r\n" : "");
    
    printf("\n");

}

void print_int(int a)
{
    printf("i=%d\n", a);

}