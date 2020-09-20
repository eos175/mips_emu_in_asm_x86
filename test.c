#include "stdint.h"
#include "stdio.h"
#include <string.h>
#include <time.h>
#include <stdlib.h>


void init()
{
    srand(time(NULL));
}

int randint(int n)
{
    return rand() % n; // randint(30) -> 0 .. 29
}


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

/*
void print_screen(void *d)
{
    uint8_t *s = (uint8_t *)d;

    for (int i = 0; i < 64 * 64; i++)
    {
        printf("%c%s", s[i],
            (i + 1) % 64 == 0 ? "\r\n" : "");
    }
    
}
*/


void print_screen(void *d)
{
    int *s = (int *)d;

    for (int i = 0; i < 64 * 64; i++)
    {
        printf("%c%s", s[i] == 0 ? 0x20 : 0xb1,
            (i + 1) % 64 == 0 ? "\r\n" : "");
    }
    
}

void print_reg(void *arr)
{
    for (int i = 0; i < 32; i ++) {
        printf(
            "%2d -> 0x%08x\n", i , ((int *)arr)[i]
        );
    }
}



typedef struct {
    uint8_t op, rs, rt, rd, shamt, func;
    uint16_t imm;
    uint32_t target;
} instruction_t;




void print_inst(const void *m, int pc)
{
    instruction_t d = *(instruction_t *)m;

    int line = (int)((float)(pc / 4) +1);

    printf("line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
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

    if (0)
    printf("line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );
    

    pc += 0x00400000;

    return sprintf(k, "line=%d pc=0x%x op=0x%x rs=%d rt=%d rd=%d shamt=0x%x, func=0x%x imm=0x%d target=0x%x\n", 
        line, pc, d.op, d.rs, d.rt, d.rd, d.shamt, d.func, d.imm, d.target
    );
    
}

