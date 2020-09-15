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



int get_instruction(int t, void *m, char *k, int pc)
{
    
    instruction_t b, d;
    b.op = (t & 0xfc000000) >> 26;
    b.rs = (t & 0x3f00000) >> 21;
    b.rt = (t & 0x1f0000) >> 16;
    b.rd = (t & 0xf800) >> 11;
    b.shamt = (t & 0x7c0) >> 6;
    b.func = t & 0x3f;

    b.imm = t & 0xffff;

    b.target = t & 0x3ffffff;

    memcpy(m, &b, sizeof(instruction_t));
    memcpy(&d, &b, sizeof(instruction_t));

    int line = (int)((float)(pc / 4) +1);

    // printf("pc=%d line=%d k=%p\n", pc, line, k);

    pc += 0x00400000;

    return sprintf(k, "line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );
    
}

