#include "stdio.h"
#include "stdint.h"


uint32_t hex2int(const char *str);

/*

001001 00000100000000000000000011

*/

int main(int argc, char const *argv[])
{

    uint32_t a = hex2int("24100003");
    uint32_t b = hex2int("24120003");


    printf("p = %d\n", b);

    return 0;
}



