SYS_EXIT    equ	60

extern print_hex
extern print_int
extern print_key
extern print_inst
extern print_reg
extern print_screen
extern get_instruction ; tmp para llevar un registro

extern init
extern randint


%include "utils.asm"
%include "mips.asm"
%include "instruction.asm"
%include "read_file.asm"
%include "write_file.asm"


global _start

; c 100 deco, save file
; op=0x9 rs=0 rt=16 rd=0 shamt=0x0, func=0x3 imm=0x3 target=0x100003


section .data
    c_clock         dd 0

    filename_log    db "mips_instruction.log", 0

    ; 64x64
    m_screen_w      equ 64
    m_screen_h      equ 64
    m_screen_size   dd  m_screen_w * m_screen_h

section .bss

    input_char RESB 1


    logger      RESB 16 * 1024
        .len    RESD 1
    

    m_pc         RESD 1 ; 0x00400000

    m_data       RESD 1024 * 256 ; 1MB -> 262144 lineas
    m_text       RESD 1024 * 256

    m_res        RESD 32
    m_stack      RESD 256

    m_screen_p     RESB m_screen_w * m_screen_h ; proxy a la pantalla real
    m_screen     RESD m_screen_w * m_screen_h

    m_inst resb instruction_t_size

section .text



%if 0

donde obtienen argumentos
    https://gist.github.com/Gydo194/730c1775f1e05fdca6e9b0c175636f5b
m_screen_size
https://www.cs.uaf.edu/2017/fall/cs301/reference/x86_64.html
https://cs.lmu.edu/~ray/notes/nasmtutorial/
https://ncona.com/2019/12/debugging-assembly-with-gdb/


b _L1
run
p/x (int[32])m_res
c 16388 -> donde termina la pantalla

b __beq.advance_pc
run
p/x (int[32])m_res
i r eax ebx edx
m_screen_size


b __ori
run
b _L1
c 30




Program received signal SIGSEGV, Segmentation fault.
__white () at main.asm:501
501	    mov [m_screen + ebx], BYTE 0xb1

(gdb) i r eax ebx ecx
eax            0x4b0               1200
ebx            0x3bffe000          1006624768
ecx            0x0                 0


(gdb) p/x (int[32])m_res
$1 = {0x0, 0x10010000, 0x10009f7c, 0x0, 0x1f, 0x1f, 0x64, 0x0, 0xffff0000, 0x1, 0x0, 0x64, 0x0, 0x0, 0x0, 
  0x64, 0x0, 0x0, 0x0, 0x1f, 0x1f, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x10008000, 0x0, 0x0, 0x4b0}

%endif


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

    call init


    ; https://superuser.com/questions/380059/display-characters-on-a-square-grid
    ; https://stackoverflow.com/questions/5584806/extended-ascii-in-linux
    ; lleno la pantalla de espacios
    mov eax, [m_screen_size]
_L00:
    dec eax
    mov [m_screen + eax * 4], DWORD 0xb1b1b1b1; 0x20202020 ; b' ' * 4
    jne _L00



%if 1
    ; para limpiar la pantalla
    call canonical_off
    print clear, clear_length	; limpia la pantalla
%endif


    set_register(28, DWORD 0x10008000); $gp = 28
    set_register(29, DWORD 0x7fffeffc); $sp = 29

_L1:
    mov eax, [c_clock]
    inc eax
    mov [c_clock], eax
    cmp eax, DWORD 100 ; cada 100 instrucciones, añade al registro
    jne no_save_file

    ; guardo en el log
    mov rdi, filename_log
    mov rsi, logger
    mov edx, [logger.len]
    ;call write_file

    mov [logger.len], DWORD 0
    mov [c_clock], DWORD 0


    ; pinta la pantalla
%if 1
    mov rdi, m_screen
    call print_screen

    getchar

    ;unsetnonblocking
    sleeptime
    print clear, clear_length
%endif




%if 0
    mov edx, [pc]
    ;mov edi, [m_text + edx]
    ;cmp edi, DWORD 0x0000000c
    cmp edx, DWORD 3180
    je _debug
%endif

no_save_file:

    mov edx, [m_pc]
    mov edi, [m_text + edx]

    mov rsi, m_inst

    mov eax, [logger.len]
    mov rdx, logger
    add rdx, rax
    mov ecx, [m_pc]
    call get_instruction

    mov ebx, [logger.len]
    add eax, ebx
    mov [logger.len], eax; len += offset 


%if 0
    mov rdi, inst
    mov rsi, 12
    call print_hex

    mov rdi, inst
    call print_inst

%endif


    mov al, BYTE[m_inst + instruction_t.op]

    check_op(_lui_i, __lui)
    check_op(_lw_i, __lw)
    check_op(_addi_i, __addi)
    check_op(_addiu_i, __addi)
    check_op(_ori_i, __ori)
    check_op(_andi_i, __andi)
    check_op(_beq_i, __beq)
    check_op(_bne_i, __bne)
    check_op(_sw_i, __sw)
    check_op(_j_j, __j)
    check_op(_jal_j, __jal)

    
    mov al, BYTE[m_inst + instruction_t.func]

    check_func(_sys_s, __sys)

    check_func(_mul_r, __mul)
    check_func(_add_r, __add)
    check_func(_addu_r, __add)
    check_func(_jr_r, __jr)


_debug:
    mov rdi, m_inst
    mov esi, [m_pc]
    call print_inst
    jmp exit


__sys:
    get_register(2, eax) ; $v0 -> para saber que syscall es
    get_register(4, ebx) ; $a0 -> 1er parametro
    get_register(5, ecx) ; $a1 -> 1er parametro

    cmp eax, DWORD 42 ; random 
    je __random_int

    cmp eax, DWORD 32 ; sleep 
    je __sleep_ms

    cmp eax, DWORD 10 ; exit 
    je __exit

__sys_e:

    jmp _ET

__random_int:
    ; randint(0, $a1)

    mov edi, ecx 
    call randint
    set_register(4, eax) ; $a0

    jmp _ET

__sleep_ms:
    ; sleep_ms($a0)

    jmp _ET

__exit:
    jmp exit




__j:
    mov eax, [m_pc]
    add eax, 0x00400000
    and eax, 0xf0000000

    get_target(ebx)
    shl ebx, 2

    ; pc = (target << 2) | (pc & 0xf0000000)
    or eax, ebx
    sub eax, 0x00400000
    mov [m_pc], eax
    jmp _L1


__jal:
    ; TODO(eos175) aqui debe ser PC + 4 
    mov eax, [m_pc]
    add eax, 4
    set_register(31, eax) ; $ra = PC + 8
    jmp __j


__jr:
    get_rs(eax)
    get_register(eax, eax)
    mov [m_pc], eax
    jmp _L1


__mul:
    ;  __mul rd, rs, rt
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    mul ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET


__add:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    add ebx, eax
    get_rd(eax)
    set_register(eax, ebx)
    jmp _ET


__addi:
    get_imm(eax)
    get_rs(ebx)
    get_register(ebx, ebx)
    add ebx, eax
    get_rt(eax)
    set_register(eax, ebx)

    jmp _ET


__andi:
    get_imm(eax)
    get_rs(ebx)
    get_register(ebx, ebx)
    and ebx, eax
    get_rt(eax)
    set_register(eax, ebx)

    jmp _ET

__ori:
    get_imm(eax)
    get_rs(ebx)
    get_register(ebx, ebx)
    or ebx, eax
    get_rt(eax)
    set_register(eax, ebx)

    jmp _ET



; TODO(eos175) juntar beq, bne
__beq:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    je __advance_pc
    jmp _ET

__bne:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    jne __advance_pc
    jmp _ET

__advance_pc:
    mov ebx, [m_pc]
    add ebx, 0x00400000

    get_imm(eax)

    shl eax, 2
    add ebx, eax
    sub ebx, 0x00400000
    mov [m_pc], ebx
    jmp _ET


__lui:
    get_imm(ebx)
    shl ebx, 16
    get_rt(eax)
    set_register(eax, ebx)

    jmp _ET


__lw:
    get_rs(ebx)
    get_register(ebx, ebx)

    get_imm(ecx)
    add ebx, ecx


    ; http://www.cs.uwm.edu/classes/cs315/Bacon/Lecture/HTML/ch14s03.html
    ; recv_ctrl -> se pone en 1 cuando se preciona una tecla
    cmp ebx, 0xffff0000 ; teclado
    je __lw_keyboard_ctrl

    cmp ebx, 0xffff0004 ; teclado
    je __lw_keyboard


    cmp ebx, 0x10010000 ; $gp [0x10008000 .. 0x10010000]
    jl __lw_screen

    cmp ebx, 0x10040000 ; $gp [0x10010000 .. 0x10040000]
    jl __lw_data

    jmp __lw_stack


; TODO(eos175) falta probar bien
__lw_stack:
    sub ebx, 0x7fffeffc
    mov ecx, [m_stack + (4 * 128) + ebx] ; para ponerlo en el limite
    get_rt(eax)
    set_register(eax, ecx)

    jmp _ET


; parche para q siempre lea el teclado
__lw_keyboard_ctrl:
    movsx ebx, BYTE[input_char]
    cmp ebx, 0
    je __ignore_k_01
    mov ebx, 0x1
__ignore_k_01:
    get_rt(eax)
    set_register(eax, ebx)
    jmp _ET


__lw_keyboard:
    movsx rdi, BYTE[input_char]
    call print_key

    movsx ebx, BYTE[input_char]
    get_rt(eax)
    set_register(eax, ebx)

    mov [input_char], BYTE 0 ; TODO(eos175) esto no debe de estar

    jmp _ET


__lw_screen:
    sub ebx, 0x10008000
    ;shr ebx, 2 ; / 4 ->  TODO(eos175)  4 -> 1 bytes
    mov ecx, [m_screen + ebx]
    get_rt(eax)
    set_register(eax, ecx)
    jmp _ET


__lw_data:
    sub ebx, 0x10010000
    mov ecx, [m_data + ebx]
    get_rt(eax)
    set_register(eax, ecx)
    jmp _ET


__sw:
    get_imm(eax)
    get_rs(ebx)
    get_register(ebx, ebx)
    add ebx, eax

    get_rt(eax)
    get_register(eax, eax)

    ; TODO(eos175) esto esta mal es guardar en esa direcion de memoria

    cmp ebx, 0x10010000 ; $gp [0x10008000 .. 0x10010000]
    jl __sw_screen

    cmp ebx, 0x10040000 ; $gp [0x10010000 .. 0x10040000]
    jl __sw_data

    jmp __sw_stack


; TODO(eos175) falta probar bien
__sw_stack:
    sub ebx, 0x7fffeffc
    mov [m_stack + (4 * 128) + ebx], eax

    jmp _ET


__sw_screen:
    sub ebx, 0x10008000
%if 0
    shr ebx, 2 ; / 4 ->  TODO(eos175) 4 -> 1 bytes
    cmp eax, 0x0
    je __black ; screen 1 bytes
%endif
    mov [m_screen + ebx], eax ; screen 4 bytes
    jmp _ET

%if 0
__white:
    mov [m_screen + ebx], BYTE 0xb1 ; '▒'
    jmp _ET

__black:
    mov [m_screen + ebx], BYTE 0x20 ; ' '
    jmp _ET
%endif


__sw_data:
    sub ebx, 0x10010000
    mov [m_data + ebx], eax

    jmp _ET


_ET:
    mov edx, [m_pc]
    add edx, 4
    mov [m_pc], edx

%if 0
    mov rdi, m_res
    call print_reg
%endif


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

