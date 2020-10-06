
%if 0

generador pseudo aleatorio, se inicializa con una
semilla aleatoria generada por urandom  

https://stackoverflow.com/questions/32225896/pseudo-random-function-in-c
https://stackoverflow.com/questions/8231882/how-to-implement-the-mod-operator-in-assembly/8232170


randint(10) -> 0 ... 9

%endif


init_random:
	; fd = open("filename", "rb");
    mov rax, SYS_OPEN
    mov rdi, file_urandom
    mov rsi, O_RDONLY
    mov rdx, 0
    syscall

    push rax ; fd

    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, next_s
    mov rdx, 128
    syscall

    ; r = close(fd);
    mov rax, SYS_CLOSE
    pop rdi ; fd
    syscall

    ret


randint:
    imul    rax, QWORD[next_s], 0x41c64e6b
    xor     edx, edx
    add     rax, 12345
    mov     QWORD[next_s], rax
    shr     rax, 16
    and     eax, 0x7fff
    div     edi
    mov     eax, edx
    ret

