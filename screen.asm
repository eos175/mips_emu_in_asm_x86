init_screen:
    mov     edx, m_screen_size
    mov     eax, 1
    mov     ecx, 0
.L0:
    inc     eax
    dec     edx
    je      .L2
.L1:
    cmp     eax, m_screen_w
    je      .L3
    inc     ecx
    inc     eax
    dec     edx
    jne     .L1
.L2:
    ret
.L3:
    add     ecx, 2
    movsx   rax, ecx
    mov     BYTE[rdi+rax], 0xa; '\n'
    mov     eax, 0
    jmp     .L0



print_screen:
    mov     rax, rdi
    add     rdi, m_screen_size * 4
    mov     ecx, 1
    mov     edx, 0

.L0:
    cmp     DWORD[rax], 0
    jne     .L1
    movsx   r8, edx
    mov     BYTE[rsi+r8], 0x20 ; ' '
    jmp     .L2

.L1:
    movsx   r8, edx
    mov     BYTE[rsi+r8], 0xb1 ; '▒'

.L2:
    cmp     ecx, m_screen_w
    jne     .L3
    inc     edx
    mov     ecx, 0

.L3:
    inc     edx
    inc     ecx
    add     rax, 4
    cmp     rax, rdi
    jne     .L0
    
    mov eax, sys_write
    mov edi, 1
    mov edx, m_screen_size + m_screen_h 
    syscall

    ret

