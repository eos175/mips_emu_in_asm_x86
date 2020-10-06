
%if 0

void load_text(const char *filename, char *buf)
{
	...
}

int hex2int(const char *s)
{
    return n;
}

%endif


; https://stackoverflow.com/questions/10156409/convert-hex-string-char-to-int

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
.L1:
    push rax

    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, logger
    mov rdx, 8 * 1024 - 2 ; (8 * 1024 - 2) / 9 = 910
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

    mov rdi, logger
    mov rcx, logger
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
