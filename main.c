#include "stdio.h"
#include "stdint.h"


uint32_t hex2int(const char *str);
uint32_t xtou64(const char *str);

/*

001001 00000100000000000000000011

*/

int main(int argc, char const *argv[])
{

    uint32_t a = xtou64("34262ea8");
    uint32_t b = hex2int("34262ea8");


    printf("a=%08x b=%08x\n", a, b);

    return 0;
}



