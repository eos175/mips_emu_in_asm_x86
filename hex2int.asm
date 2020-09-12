
%if 0

https://stackoverflow.com/questions/10156409/convert-hex-string-char-to-int

/**
 * hex2int
 * take a hex string and convert it to a 32bit number (max 8 hex digits)
 */
uint32_t hex2int(const char *str) 
{
    uint32_t res = 0;
    uint8_t c;

    while ((c = *str++)) {
        if (c >= '0' && c <= '9') c = c - '0';
        else if (c >= 'a' && c <='f') c = c - 'a' + 10;
        else if (c >= 'A' && c <='F') c = c - 'A' + 10;

        res = (res << 4) | (c & 0xF);
    }

    return res;
}


%endif


global hex2int


hex2int:
    mov     eax, 0 ; res = 0
    mov     r8, 0
.L1:
    movzx   edx, BYTE[rdi+r8]
    cmp     edx, '9' ; if (c >= '0' && c <= '9') c = c - '0';
    jle     .T1

    sub     edx, 'a' - 10
    jmp     .E1

.T1:
    sub     edx, '0'

.E1:
    ; res = (res << 4) | (c & 0xF);
    shl     eax, 4
    and     edx, 0xF
    or      eax, edx

    inc     r8
    cmp     r8, 8
    jl     .L1

    ret


