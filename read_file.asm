O_RDONLY	equ	0
O_WRONLY	equ	1
O_RDWR		equ	2

SYS_READ	equ	0
SYS_WRITE	equ	1
SYS_OPEN	equ	2
SYS_CLOSE	equ	3
SYS_STAT	equ	4
SYS_FSTAT	equ	5
SYS_LSTAT	equ	6
SYS_POLL	equ	7
SYS_LSEEK	equ	8


extern hex2int


global load_file

%if 0

int load_text(const char *filename, char *buf)
{
	...

	return len;
}

; args 
; For integers and pointers, rdi, rsi, rdx, rcx, r8, r9


%endif


section .data
    r_buf_size dd 8 * 1024 -2 ; (8 * 1024 - 2) / 9 = 910

section .bss
    r_buf resb 8 * 1024 - 2

section .text


load_file:
    mov r9, rsi

	; fd = open("filename", "rb");
    mov rax, SYS_OPEN
    ;mov rdi, filename
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall
    
    push rax ; fd

	; len = read(fd, buf, 1024);
.L1
    push rax

    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, r_buf
    mov rdx, [r_buf_size]
    syscall

    mov rdx, rax ; storing count of readed bytes to rdx
    push rax

%if 0
    ; print
    mov rax, 1 ; system call for write
    mov rdi, 1 ; file handle 1 is stdout
    syscall
%endif


    ; 8 bytes -> 4 bytes
    cmp rdx, 0
    je .E1

    mov rdi, r_buf
    mov rcx, r_buf
    add rcx, rax
    .L2:
        call hex2int
        mov [r9], eax

        add rdi, 9
        add r9, 4

        cmp rdi, rcx 
        jne .L2


.E1:
    pop rdx
    pop rax
    cmp rdx, 0
    jne .L1

	; r = close(fd);
    mov rax, SYS_CLOSE
    pop rdi ; fd
    syscall

    mov rax, rdx
	ret


