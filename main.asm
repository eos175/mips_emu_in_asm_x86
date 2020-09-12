SYS_EXIT    equ	60

extern print_hex
extern print_int
extern print_inst


%include "mips.asm"
%include "instruction.asm"
%include "read_file.asm"


global _start


section .data
    pc dd 0 ; 0x00400000

section .bss

    ; 1MB -> 262144 lineas
    m_data        RESD 1024 * 256
    m_text        RESD 1024 * 256

    registers   RESD 32
    stack       RESD 256

    inst: resb instruction_t_size

section .text



%if 0

donde obtienen argumentos
    https://gist.github.com/Gydo194/730c1775f1e05fdca6e9b0c175636f5b

https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
https://cs.lmu.edu/~ray/notes/nasmtutorial/
https://ncona.com/2019/12/debugging-assembly-with-gdb/


b _L1
run
p/x (int[32])registers
c 16392

b __beq.advance_pc
run
p/x (int[32])registers
i r eax ebx edx


(pc / 4) +1 -> saber q linea es

%endif


_start:

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


    mov [registers + 28 * 4], DWORD 0x10008000 ; $gp = 28

_L1:

%if 0
    mov edx, [pc]
    ;mov edi, [m_text + edx]
    ;cmp edi, DWORD 0x0000000c
    cmp edx, DWORD 3180
    je _debug
%endif


    mov edx, [pc]
    mov edi, [m_text + edx]
    mov rsi, inst
    call get_instruction

%if 0
    mov rdi, inst
    mov rsi, 12
    call print_hex

    mov rdi, inst
    call print_inst

%endif


    mov al, BYTE[inst + instruction_t.op]

    check_op(_lui_i, __lui)
    check_op(_lw_i, __lw)
    check_op(_addi_i, __addi)
    check_op(_addiu_i, __addi)
    check_op(_beq_i, __beq)
    check_op(_bne_i, __bne)
    check_op(_sw_i, __sw)
    check_op(_j_j, __j)
    check_op(_jal_j, __jal)

    
    mov al, BYTE[inst + instruction_t.func]

    check_func(_mul_r, __mul)
    check_func(_add_r, __add)
    check_func(_addu_r, __add)
    check_func(_jr_r, __jr)



_debug:
    mov rdi, inst
    call print_inst

    mov edi, [pc]  
    add edi, 4  
    call print_int

    jmp exit

__j:
    mov eax, [pc]
    add eax, 0x00400000
    and eax, 0xf0000000

    mov ebx, [inst + instruction_t.target]
    shl ebx, 2

    ; pc = (target << 2) | (pc & 0xf0000000)
    or eax, ebx
    sub eax, 0x00400000
    mov [pc], eax
    jmp _L1


__jal:
    mov eax, [pc]
    add eax, 8
    set_register(31, eax) ; $ra = PC + 8
    jmp __j


__jr:
    movsx   eax, BYTE[inst + instruction_t.rs]
    get_register(eax, eax)
    mov [pc], eax
    jmp _L1


__mul:
    ;  __mul rd, rs, rt
    movsx   eax, BYTE[inst + instruction_t.rs]
    movsx   ebx, BYTE[inst + instruction_t.rt]
    get_register(eax, eax)
    get_register(ebx, ebx)
    mul     ebx
    movsx   ebx, BYTE[inst + instruction_t.rd]
    set_register(ebx, eax)
    jmp _ET


__add:
    movsx   eax, BYTE[inst + instruction_t.rs]
    movsx   ebx, BYTE[inst + instruction_t.rt]
    get_register(eax, eax)
    get_register(ebx, ebx)
    add ebx, eax
    movsx   eax, BYTE[inst + instruction_t.rd]
    set_register(eax, ebx)
    jmp _ET


__addi:
    movsx   eax, WORD[inst + instruction_t.imm]
    movsx   ebx, BYTE[inst + instruction_t.rs]
    get_register(ebx, ebx)
    add ebx, eax
    movsx   eax, BYTE[inst + instruction_t.rt]
    set_register(eax, ebx)

    jmp _ET



; TODO(eos175) juntar beq, bne
__beq:
    movsx   eax, BYTE[inst + instruction_t.rs]
    movsx   ebx, BYTE[inst + instruction_t.rt]
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    je __advance_pc
    jmp _ET

__bne:
    movsx   eax, BYTE[inst + instruction_t.rs]
    movsx   ebx, BYTE[inst + instruction_t.rt]
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    jne __advance_pc
    jmp _ET

__advance_pc:
    mov ebx, [pc]
    add ebx, 0x00400000

    movsx   eax, WORD[inst + instruction_t.imm]
    shl eax, 2
    add ebx, eax
    sub ebx, 0x00400000
    mov [pc], ebx
    jmp _ET





__lui:
    movsx   rax, BYTE[inst + instruction_t.rt]
    movsx   ebx, WORD[inst + instruction_t.imm]
    shl     ebx, 16
    set_register(eax, ebx)

    jmp _ET


__lw:
    mov    al, [inst + instruction_t.rt]
    movsx  ebx, BYTE[inst + instruction_t.rs]
    get_register(ebx, ebx)

    movsx  ecx, WORD[inst + instruction_t.imm]
    add ecx, ebx

    ; 0xffff0000 -> teclado

    sub ecx, 0x10010000
    mov ebx, [m_data + ecx]

    set_register(eax, ebx)

    jmp _ET

__sw:
    movsx  eax, WORD[inst + instruction_t.imm]
    movsx  ebx, BYTE[inst + instruction_t.rs]
    get_register(ebx, ebx)
    add ebx, eax
    sub ecx, 0x10010000
    movsx  eax, BYTE[inst + instruction_t.rt]
    
    ; TODO(eos175) esto esta mal es guardar en esa direcion de memoria
    ; set_register(eax, ebx)
    
    jmp _ET


_ET:
    mov edx, [pc]
    add edx, 4
    mov [pc], edx

%if 0

    mov rdi, inst
    call print_inst

    movsx rdi, DWORD[pc]
    call print_int

%endif


    jmp _L1



exit:
	mov	rax,	SYS_EXIT    ; load the EXIT syscall number into rax
	mov	rdi,    0		; the program return code
	syscall				; execute the system call

