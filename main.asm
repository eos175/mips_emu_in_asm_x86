extern dump_instruction

%define PRINT_SCREEN      1
%define DEBUG             0


; debe ser 1000000 pero en algunos juego va lento
%define MILLIS2NANO       1200000


%include "utils.asm"
%include "mips.asm"
%include "instruction.asm"
%include "load_file.asm"
%include "write_file.asm"
%include "screen.asm"


global _start


section .data
    c_clock         dd 0

    filename_log    db "mips_instruction.log", 0
    question        db " [y = Yes / n = No / c = Cancel]", 0
    .len equ $-question
    sound           db 0x7, 0
    ; 64x64
    m_screen_w      equ 64
    m_screen_h      equ 64
    m_screen_size   equ m_screen_w * m_screen_h
    ; m_pc            dd 0x00400000

section .bss

    logger      RESB 2 * 8 * 1024
        .len    RESD 1
    

    m_pc         RESD 1 ; 0x00400000

    m_data       RESD 1024 * 256 ; 1MB -> 262144 lineas
    m_text       RESD 1024 * 256

    m_reg        RESD 32
    m_stack      RESD 1024

    m_screen_p   RESB m_screen_size + m_screen_h  ; proxy a la pantalla real
    m_screen     RESD m_screen_size

    m_inst       RESB instruction_t_size

    

section .text


_start:

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


%if PRINT_SCREEN
    ; para limpiar la pantalla
    call canonical_off

    mov rdi, m_screen_p
    call init_screen
%endif

    set_register(28, 0x10008000); $gp = 28
    set_register(29, 0x7fffeffc); $sp = 29

_L1:
    mov eax, [c_clock]
    inc eax
    mov [c_clock], eax
    cmp eax, DWORD 80 ; cada 100 instrucciones, añade al registro
    jne _no_save_file

%if DEBUG
    ; guardo en el log
    mov rdi, filename_log
    mov rsi, logger
    mov edx, [logger.len]
    call write_file
    
%endif

    mov [logger.len], DWORD 0
    mov [c_clock], DWORD 0

%if PRINT_SCREEN
    ; pinta la pantalla

    print clear, clear_length

    mov rdi, m_screen
    mov rsi, m_screen_p
    call print_screen

    getchar

%endif

_no_save_file:

%if DEBUG
    ; parar en un pc en especifico

    mov edx, [m_pc]
    cmp edx, 4
    jne _C1

__stop_pc:
    nop

_C1:

%endif

    mov edx, [m_pc]
    mov edi, [m_text + edx]
    mov rsi, m_inst
    call get_instruction

    mov rdi, m_inst
    mov eax, [logger.len]
    mov rsi, logger
    add rsi, rax
    mov edx, [m_pc]
    call dump_instruction ; TODO(eos175) esto esta escrito en c, con persmiso de Ernesto
    mov ebx, [logger.len]
    add eax, ebx
    mov [logger.len], eax; len += offset 


    mov al, BYTE[m_inst + instruction_t.op]

    check_op(0x00, __type_r)

    check_op(_j_j, __j)
    check_op(_jal_j, __jal)
    check_op(_lui_i, __lui)
    check_op(_lw_i, __lw)
    check_op(_sw_i, __sw)
    check_op(_addi_i, __addi)
    check_op(_addiu_i, __addi)
    check_op(_ori_i, __ori)
    check_op(_andi_i, __andi)
    check_op(_slti_i, __slti)
    check_op(_blez_i, __blez)
    check_op(_bgtz_i, __bgtz)
    check_op(_beq_i, __beq)
    check_op(_bne_i, __bne)



__type_r:

    mov al, BYTE[m_inst + instruction_t.func]

    check_func(_sys_s, __sys)

    check_func(_jr_r, __jr)
    check_func(_xor_r, __xor) ; TODO(eos175) falta agregar los demas bitwise
    check_func(_and_r, __and)
    check_func(_add_r, __add)
    check_func(_addu_r, __add)
    check_func(_sub_r, __sub)
    check_func(_mul_r, __mul)
    check_func(_div_r, __div)
    check_func(_slt_r, __slt)
    check_func(_srl_r, __srl)
    check_func(_sll_r, __sll)
    check_func(_nor_r, __nor)
    check_func(_or_r, __or)
    check_func(_sltu_r, __slt)
    check_func(_subu_r, __sub)


_ET:
    mov edx, [m_pc]
    add edx, 4
    mov [m_pc], edx


%if (DEBUG > 3 && 1)
    mov rdi, m_reg
    call print_reg
%endif

    jmp _L1


exit:
	mov	rax, SYS_EXIT
	mov	rdi, 0
	syscall

