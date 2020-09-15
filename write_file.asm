
%if 0


void wrife_file(const char *filename, const char *buf, int len)
{
    
}

; args 
; For integers and pointers, rdi, rsi, rdx, rcx, r8, r9


%endif

write_file:
    push rsi ; buf
    push rdx ; len

    ; fd = open("filename", "ab+");
    mov rax, SYS_OPEN
    ;mov rdi, filename
    mov rsi, O_CREAT | O_WRONLY | O_APPEND
    mov rdx, 0666o
    syscall

    pop rdx
    pop rsi
    push rax ; fd

    mov rdi, rax
    mov rax, SYS_WRITE

    syscall

    ; r = close(fd);
    mov rax, SYS_CLOSE
    pop rdi ; fd
    syscall

    ret
