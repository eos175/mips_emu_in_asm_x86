#include "stdio.h"
#include "stdint.h"


uint32_t hex2int(const char *str);
uint32_t xtou64(const char *str);

/*

001001 00000100000000000000000011

*/

int main(int argc, char const *argv[])
{

    uint32_t a = xtou64("0000000c");
    uint32_t b = hex2int("0000000c");


    printf("a=%08x b=%d\n", a, b);

    return 0;
}



