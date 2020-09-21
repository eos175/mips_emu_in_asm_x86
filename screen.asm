init_screen:
    mov     edx, m_screen_size
    mov     eax, 1
    xor     ecx, ecx
.L2:
    add     eax, 1
    sub     edx, 1
    je      .L7
.L5:
    cmp     eax, m_screen_w
    je      .L3
    add     ecx, 1
    add     eax, 1
    sub     edx, 1
    jne     .L5
.L7:
    ret
.L3:
    add     ecx, 2
    movsx   rax, ecx
    mov     BYTE[rdi+rax], 0xa; '\n'
    xor     eax, eax
    jmp     .L2



print_screen:
    mov     rax, rdi
    add     rdi, m_screen_size * 4
    mov     ecx, 1
    mov     edx, 0
.L10:
    cmp     DWORD[rax], 0
    jne     .L7
    movsx   r8, edx
    mov     BYTE[rsi+r8], 0x20 ; ' '
    jmp     .L8
.L7:
    movsx   r8, edx
    mov     BYTE[rsi+r8], 0xb1 ; '▒'
.L8:
    cmp     ecx, m_screen_w
    jne     .L9
    add     edx, 1
    mov     ecx, 0
.L9:
    add     edx, 1
    add     ecx, 1
    add     rax, 4
    cmp     rax, rdi
    jne     .L10
    
    mov eax, sys_write
    mov edi, 1
    mov edx, m_screen_size + (m_screen_h * 1)
    syscall

    ret

