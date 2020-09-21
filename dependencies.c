#include "stdint.h"
#include "stdio.h"


typedef struct {
    uint8_t op, rs, rt, rd, shamt, func;
    uint16_t imm;
    uint32_t target;
} instruction_t;


int get_instruction(void *inst, char *buf, int pc)
{
    instruction_t d = *(instruction_t *)inst;
    
    int line = (pc / 4) +1;

    pc += 0x00400000;

    if (0)
    printf("line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );

    return sprintf(buf, "line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );
}



/*

void print_reg(void *arr)
{
    int *s = (int *)arr;
    for (int i = 0; i < 32; i++) {
        printf("%2d -> 0x%08x\n", i , s[i]);
    }
}

void print_screen(void *d)
{
    int *s = (int *)d;
    for (int i = 0; i < 64 * 64; i++) {
        printf("%c%s", s[i] == 0 ? 0x20 : 0xb1,
            (i + 1) % 64 == 0 ? "\r\n" : "");
    }
    
}

*/