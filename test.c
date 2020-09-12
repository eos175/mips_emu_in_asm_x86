#include "stdint.h"
#include "stdio.h"
#include <string.h>


void print_hex(const void *buf, int length)
{
    uint8_t *s = (uint8_t *)buf;

    printf("\n%d <<< \n", length);

    for (int i = 0; i < length; i++)
        // printf("%02x[%c]%s ", s[i], s[i],
        printf("%02x%s", s[i],
            (i + 1) % 63 == 0 ? "\r\n" : "");
    
    printf("\n");

}

void print_int(int a)
{
    printf("pc=%d\n", a / 4);

}

typedef struct {
    uint8_t op, rs, rt, rd, shamt, func;
    uint16_t imm;
    uint32_t target;
} instruction_t;




void print_inst(const void *m)
{
    instruction_t d = *(instruction_t *)m;

    //  sizeof(instruction_t);
    printf("\nop=%d rs=%d rt=%d rd=%d shamt=%d, func=%d imm=%d target=%d\n", 
        d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );
    printf("op=0x%x rs=0x%x rt=0x%x rd=0x%x shamt=0x%x, func=0x%x imm=0x%x target=0x%x\n", 
        d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );

}

