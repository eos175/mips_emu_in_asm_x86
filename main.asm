SYS_EXIT    equ	60

extern print_hex
extern load_file
extern print_int

global _start


section .data
    pc dd 0

section .bss

    ; 1MB -> 262144 lineas
    m_data        RESD 1024 * 256
    m_text        RESD 1024 * 256

    registers   RESD 32
    stack       RESD 256

section .text

%include "mips.asm"


%if 0

donde obtienen argumentos
    https://gist.github.com/Gydo194/730c1775f1e05fdca6e9b0c175636f5b

https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
https://cs.lmu.edu/~ray/notes/nasmtutorial/
https://ncona.com/2019/12/debugging-assembly-with-gdb/


b _debug    mov rsi, buffer
run
p (int[32])registers


%endif


_start:
    ; mov rdi, num
    ; call hex2int

%if 0
    mov eax, 976
    mov ebx, 136
    set_register(16, eax)
    set_register(17, ebx)
    _and(1, 16, 17)
%endif


    pop r8
    cmp r8, 3 ; if (argc != 3) exit(0)
    jne exit
    pop rax ; descarto el primer argumento

    ;mov rdi, filename1
    pop rdi
    mov rsi, m_text
    call load_file

    ;mov rdi, filename2
    pop rdi
    mov rsi, m_data
    call load_file


_debug:


exit:
	mov	rax,	SYS_EXIT    ; load the EXIT syscall number into rax
	mov	rdi,    0		; the program return code
	syscall				; execute the system call

