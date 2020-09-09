
extern hex2int

global _start



section .data

    num db "24120003", 10, 0

    pc dd 0

section .bss

    ; 1MB
    data        RESD 1024*256
    text        RESD 1024*256

    registers   RESD 32
    stack       RESD 256

section .text

%include "mips.asm"


%if 0


https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
https://cs.lmu.edu/~ray/notes/nasmtutorial/
https://ncona.com/2019/12/debugging-assembly-with-gdb/


b _debug
run
p (int[32])registers


%endif


_start:
    ; mov rdi, num
    ; call hex2int

    mov eax, 976
    mov ebx, 136
    set_register(16, eax)
    set_register(17, ebx)
    _and(1, 16, 17)

_debug:
	mov	eax, 1 ; exit
	mov	ebx, 0
	int	0x80   ; exit(0)
