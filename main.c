#include "stdio.h"
#include "stdint.h"


uint32_t hex2int(const char *str);
uint32_t xtou64(const char *str);
int randint(int, int);
void init();

/*

001001 00000100000000000000000011

*/

int main(int argc, char const *argv[])
{
    init();
    uint32_t a = xtou64("0000000c");
    uint32_t b = hex2int("0000000c");


    printf("a=%08x b=%d\n", a, randint(0, 62));

    for (;;) {
        a =  randint(0, 62);
        if (a == 62) break;
        printf("a=%d\n", a);
    }

    return 0;
}



