
%if 0

https://stackoverflow.com/questions/23299846/pointer-for-the-first-struct-member-list-in-nasm-assembly

typedef struct {
    uint8_t op, rs, rt, rd, shamt, func;
    uint16_t imm;
    uint32_t target;
} instruction_t;

void get_instruction(int t, void *m)
{
    instruction_t b;
    b.op = (t & 0xfc000000) >> 26;
    b.rs = (t & 0x3f00000) >> 21;
    b.rt = (t & 0x1f0000) >> 16;
    b.rd = (t & 0xf800) >> 11;
    b.shamt = (t & 0x7c0) >> 6;
    b.func = t & 0x3f;

    b.imm = t & 0xffff;

    b.target = t & 0x3ffffff;

    memcpy(m, &b, sizeof(instruction_t));
}

%endif


struc instruction_t
    ; tipo R
    .op resb 1
    .rs resb 1
    .rt resb 1
    .rd resb 1
    .shamt resb 1
    .func resb 1
    ; tipo I
    .imm resw 1
    ; tipo J
    .target resd 1
endstruc


global get_instruction

get_instruction:
    ; op = t >> 26
    mov     eax, edi
    shr     eax, 26
    mov     BYTE[rsi], al

    ; rs = (t & 0x3f00000) >> 21
    mov     eax, edi
    and     eax, 0x3f00000
    shr     eax, 21
    mov     BYTE[rsi+1], al ; mov BYTE[inst + instruction_t.rs], al

    ; rt = (t & 0x1f0000) >> 16
    mov     eax, edi
    and     eax, 0x1f0000
    shr     eax, 16
    mov     BYTE[rsi+2], al

    ; rd = (t & 0xf800) >> 11
    mov     eax, edi
    and     eax, 0xf800
    shr     eax, 11
    mov     BYTE[rsi+3], al

    ; shamt = (t & 0x7c0) >> 6
    mov     eax, edi
    and     eax, 0x7c0
    shr     eax, 6
    mov     BYTE[rsi+4], al

    ; func = t & 0x3f
    mov     eax, edi
    and     eax, 0x3f
    mov     BYTE[rsi+5], al
    
    ; imm = t & 0xffff
    mov     WORD[rsi+6], di

    ; target = t & 0x3ffffff
    and     edi, 67108863
    mov     DWORD[rsi+8], edi
    ret
