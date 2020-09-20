SYS_EXIT    equ	60

extern print_hex
extern print_int
extern print_inst
extern print_reg
extern print_screen
extern get_instruction ; tmp para llevar un registro


%define PRINT_SCREEN      1
%define DEBUG             0


%include "utils.asm"
%include "mips.asm"
%include "instruction.asm"
%include "read_file.asm"
%include "write_file.asm"


global _start


section .data
    c_clock         dd 0

    filename_log    db "mips_instruction.log", 0

    ; 64x64
    m_screen_w      equ 64
    m_screen_h      equ 64
    m_screen_size   dd  m_screen_w * m_screen_h

    ; m_pc            dd 0x00400000

section .bss

    input_char RESB 1


    logger      RESB 16 * 8 * 1024
        .len    RESD 1
    

    m_pc         RESD 1 ; 0x00400000

    m_data       RESD 1024 * 256 ; 1MB -> 262144 lineas
    m_text       RESD 1024 * 256

    m_res        RESD 32
    m_stack      RESD 1024

    ;m_screen_p     RESB m_screen_w * m_screen_h ; proxy a la pantalla real
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


    ; https://superuser.com/questions/380059/display-characters-on-a-square-grid
    ; https://stackoverflow.com/questions/5584806/extended-ascii-in-linux
    ; lleno la pantalla de espacios
    mov eax, [m_screen_size]
_L00:
    dec eax
    mov [m_screen + eax * 4], DWORD 0 ;0xb1b1b1b1; 0x20202020 ; b' ' * 4
    jne _L00



%if PRINT_SCREEN
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
    cmp eax, DWORD 600 ; cada 100 instrucciones, añade al registro
    jne _no_save_file

    ; guardo en el log
    mov rdi, filename_log
    mov rsi, logger
    mov edx, [logger.len]
    ;call write_file

    mov [logger.len], DWORD 0
    mov [c_clock], DWORD 0

%if PRINT_SCREEN
    ; pinta la pantalla

    mov rdi, m_screen
    call print_screen

    getchar

    ;unsetnonblocking
    sleeptime
    print clear, clear_length

%endif

_no_save_file:

%if DEBUG
    ; para en un pc en especifico

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
    check_func(_add_r, __add)
    check_func(_addu_r, __add)
    check_func(_sub_r, __sub)
    check_func(_mul_r, __mul)
    check_func(_div_r, __div)
    check_func(_slt_r, __slt)
    check_func(_srl_r, __srl)
    check_func(_sll_r, __sll)


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
    je __randint

    cmp eax, DWORD 32 ; sleep 
    je __sleep_ms

    cmp eax, DWORD 10 ; exit 
    je __exit

__e:
    jmp _ET


__randint:
    ; para no usar el random de c voy a usar el clock virtual como generador seudoaleatorio
    ; rand() % n
    ; https://stackoverflow.com/questions/8231882/how-to-implement-the-mod-operator-in-assembly/8232170
    
    mov eax, [c_clock]
    cqd
    idiv ecx
    set_register(4, edx) ; $a0
    jmp _ET

__sleep_ms:
    ; sleep_ms($a0)

    jmp _ET

__exit:
    jmp exit




__srl: ; rd = rt >> shamt
    get_rt(eax)
    get_register(eax, eax)
    get_shamt(ebx)
.L0:
    cmp ebx, 0
    je .E0
    shr eax, 1
    dec ebx
    jmp .L0
.E0:
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET


__sll: ; rd = rt << shamt
    get_rt(eax)
    get_register(eax, eax)
    get_shamt(ebx)
.L0:
    cmp ebx, 0
    je .E0
    shl eax, 1
    dec ebx
    jmp .L0
.E0:
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET



__jal: ; $ra = PC + 4
    mov eax, [m_pc]
    add eax, 4
    set_register(31, eax)

__j: ; pc = (target << 2) | (pc & 0xf0000000)
    mov eax, [m_pc]
    add eax, 0x00400000
    and eax, 0xf0000000
    get_target(ebx)
    shl ebx, 2
    or eax, ebx
    sub eax, 0x00400000
    mov [m_pc], eax
    jmp _L1

__jr: ; PC = rs
    get_rs(eax)
    get_register(eax, eax)
    mov [m_pc], eax
    jmp _L1



__add:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    add eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET

__sub: ; rd = rs - rt
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    sub eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET



__mul: ; rd = rs * rt
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    mul ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET

__div: ; rd = rs / rt
    ; https://stackoverflow.com/questions/45506439/division-of-two-numbers-in-nasm
    xor edx, edx
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    div ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET    


__xor:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    xor eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET



%if 0

if rs < rt
    rd = 1
else
    rd = 0

%endif


__slt:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    get_rd(ecx)
    cmp eax, ebx
    jl .L0
    set_register(ecx, DWORD 0)
    jmp _ET
.L0:
    set_register(ecx, DWORD 1)
    jmp _ET



%if 0

if rs < imm
    rd = 1;
else
    rd = 0;

%endif

__slti:
    get_imm(eax)
    get_rs(ebx)
    get_register(ebx, ebx)
    get_rt(ecx)
    cmp ebx, eax
    jl .L0
    set_register(ecx, DWORD 0)
    jmp _ET
.L0:
    set_register(ecx, DWORD 1)
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



%if 0

if rs == rt 
    PC += imm << 2;
else 
    PC += 4;

%endif
__beq:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    je __advance_pc
    jmp _ET

__bne: ; if rs != rt ... 
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    cmp eax, ebx
    jne __advance_pc
    jmp _ET

__bgtz: ; if rs > 0 ... 
    get_rs(eax)
    get_register(eax, eax)
    cmp eax, 0
    ja __advance_pc
    jmp _ET

__blez: ; if rs <= 0 ...
    get_rs(eax)
    get_register(eax, eax)
    cmp eax, 0
    jle __advance_pc
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




__lui: ; rt = imm << 16
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


    cmp ebx, 0xffff0000 ; teclado
    je __lw_key_recv_ctrl

    cmp ebx, 0xffff0004 ; teclado
    je __lw_keyboard


    cmp ebx, 0x10010000 ; $gp [0x10008000 .. 0x10010000]
    jl __lw_screen

    cmp ebx, 0x20040000 ; $data [0x10010000 .. 0x10040000]
    jl __lw_data

    jmp __lw_stack


; TODO(eos175) falta probar bien
__lw_stack:
    not ebx
    add ebx, 0x7fffeffc
    mov ecx, [m_stack + (4 * 512) +  ebx] ; para ponerlo en el limite
    get_rt(eax)
    set_register(eax, ecx)
    jmp _ET


; http://www.cs.uwm.edu/classes/cs315/Bacon/Lecture/HTML/ch14s03.html
; recv_ctrl -> se pone en 1 cuando se preciona una tecla
__lw_key_recv_ctrl:
    movsx ebx, BYTE[input_char]
    cmp ebx, 0
    je .L0
    mov ebx, 0x1
.L0:
    get_rt(eax)
    set_register(eax, ebx)
    jmp _ET


__lw_keyboard:
    movsx ebx, BYTE[input_char]
    get_rt(eax)
    set_register(eax, ebx)
    mov [input_char], BYTE 0 ; TODO(eos175) esto lo debe hacer el usuario -> sw $zero, 0xffff0004
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

    cmp ebx, 0xffff0000 ; teclado
    je __sw_keyboard

    cmp ebx, 0xffff0004 ; teclado
    je __sw_keyboard

    cmp ebx, 0x10010000 ; $gp [0x10008000 .. 0x10010000]
    jl __sw_screen

    cmp ebx, 0x20040000 ; $gp [0x10010000 .. 0x10040000]
    jl __sw_data

    jmp __sw_stack


__sw_keyboard:
    mov [input_char], al ; solo 1 byte
    jmp _ET


; TODO(eos175) falta probar
__sw_stack:
    not ebx
    add ebx, 0x7fffeffc
    mov [m_stack + (4 * 512)+ ebx], eax
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


%if (DEBUG > 3)
    mov rdi, m_res
    call print_reg
%endif

    jmp _L1


exit:
	mov	rax,	SYS_EXIT    ; load the EXIT syscall number into rax
	mov	rdi,    0		; the program return code
	syscall				; execute the system call

