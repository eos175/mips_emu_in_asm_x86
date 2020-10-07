%define get_register(i ,r)      mov r, DWORD[m_reg + i*4]
%define set_register(i, r)      mov DWORD[m_reg + i*4], r


%define sys_call(v0, label)   __check_op v0, label

%define check_func(code, label)    __check_op code, label
%define check_op(code, label)   __check_op code, label

%macro __check_op 2
    cmp al, %1
    je %2
%endmacro


; en un registro de 32 bits
%define get_rs(r)   movsx r, BYTE[m_inst + instruction_t.rs]
%define get_rt(r)   movsx r, BYTE[m_inst + instruction_t.rt]
%define get_rd(r)   movsx r, BYTE[m_inst + instruction_t.rd]
%define get_imm(r)  movsx r, WORD[m_inst + instruction_t.imm]
%define get_target(r)  mov r, [m_inst + instruction_t.target]
%define get_shamt(r)   movsx r, BYTE[m_inst + instruction_t.shamt]


;-------------------Format R [Funct]-------------------------------------;
%define	_sys_s		0x0c ; TODO(eos175)     syscall

%define	_add_r		0x20
%define _addu_r		0x21
%define _and_r		0x24
%define _div_r		0x1A
%define _divu_r		0x1B
%define _jr_r		0x08

%define _mul_r		0x1c    ; TODO(eos175) op=0x1c func=0x02 --> voy a tratar esto como tipo I


%define _mthi_r     0x11
%define _mtlo_r     0x13

%define _mfhi_r     0x10
%define _mflo_r     0x12
%define _mult_r     0x18
%define _multu_r    0x19


%define _nor_r		0x27
%define _xor_r		0x26
%define _or_r		0x25
%define _slt_r		0x2A
%define _sltu_r		0x2B
%define _sll_r		0x00
%define _srl_r		0x02
%define _sra_r		0x03
%define _sub_r		0x22
%define _subu_r		0x23

;-------------------Format I [Opcode]------------------------------------;
%define _addi_i		0x08
%define _addiu_i	0x09
%define _andi_i		0x0C
%define _beq_i		0x04
%define _blez_i		0x06
%define _bne_i		0x05
%define _bgtz_i 	0x07
%define _lb_i		0x20
%define _lbu_i		0x24
%define _lhu_i		0x25
%define _lui_i		0x0F
%define _lw_i		0x23
%define _ori_i		0x0D
%define _sb_i		0x28
%define _sh_i 		0x29
%define _slti_i		0x0A
%define _sltiu_i	0x0B
%define _sw_i		0x2B

;-------------------Format J [Opcode]------------------------------------;
%define _j_j		0x02
%define _jal_j		0x03


__sys:
    get_register(2, eax) ; $v0 -> para saber que syscall es
    get_register(4, ebx) ; $a0 -> 1er parametro
    get_register(5, ecx) ; $a1 -> 2do parametro

    sys_call(42, __randint)         ;   random value
    sys_call(32, __sleep_ms)        ;   sleep
    sys_call(31, __sound_sys)       ;   beep sound  
    sys_call(50, __msg_Y_or_N)      ;   conditional dialog
    sys_call(56, __message_int)     ;   print a Text & a Int value
    sys_call(10, __exit)            ;   exit

__e:
    jmp _ET


__randint:
    mov edi, ecx
    call randint
    set_register(4, eax) ; $a0
    jmp _ET

__sleep_ms:
    imul eax, ebx, MILLIS2NANO
    mov QWORD[tv_nsec], rax
    sleeptime
    jmp _ET

__sound_sys:
    mov esi, sound
    mov edx, 2
    mov eax, sys_write ; Aca le digo cual syscall quier aplicar
    mov edi, 1  ; stdout, Aca le digo a donde quiero escribir
    syscall
    jmp _ET

__msg_Y_or_N: ; TODO(eos175) auto en [not]

.case_n:
    set_register(4, 1)
    jmp _ET

.case_y:
    set_register(4, 0)
    jmp _ET

.case_c:
    set_register(4, 2)
    jmp _ET


__message_int:
    push rcx

    newLine
    newLine

    sub ebx, 0x10010000
    mov ecx, m_data 
    add ecx, ebx

    mov edi, ecx
    call strlen

    ; Aqui imprimos la cadena
    mov esi, ecx
    mov edx, eax
    mov eax, sys_write ; Aca le digo cual syscall quier aplicar
    mov edi, 1  ; stdout, Aca le digo a donde quiero escribir
    syscall

    pop rcx
    mov rax, rcx

    call _print_Int

    newLine
    newLine

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

%if 0

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

%endif

__xor:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    xor eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET

__and:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    and eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET

__or:
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    or eax, ebx
    get_rd(ebx)
    set_register(ebx, eax)
    jmp _ET




__mult: ; 	$LO = rs * rt
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    mul ebx
    set_register(33, eax) ; $lo
    jmp _ET

%if 1

__div: ; $LO = rs / rt; $HI = rs % rt
    xor edx, edx
    get_rs(eax)
    get_rt(ebx)
    get_register(eax, eax)
    get_register(ebx, ebx)
    div ebx
    set_register(32, edx) ; $hi
    set_register(33, eax) ; $lo
    jmp _ET

%endif

__mflo: ; rd <- $lo
    get_rd(eax)
    get_register(33, ebx) ; $lo        
    set_register(eax, ebx)
    jmp _ET

__mfhi: ; rd <- $hi
    get_rd(eax)
    get_register(32, ecx) ; $hi
    set_register(eax, ecx)
    jmp _ET

__mthi:

__mtlo:



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
    set_register(ecx, 0)
    jmp _ET
.L0:
    set_register(ecx, 1)
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
    set_register(ecx, 0)
    jmp _ET
.L0:
    set_register(ecx, 1)
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

    cmp ebx, 0x10040000 ; $data [0x10010000 .. 0x10040000]
    jl __lw_data

; TODO(eos175) falta probar bien
__lw_stack:
    not ebx
    mov ecx, [m_stack + 4 * 512 + 0x7fffeffc +  ebx] ; para ponerlo en el limite
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

    cmp ebx, 0x10040000 ; $gp [0x10010000 .. 0x10040000]
    jl __sw_data

; TODO(eos175) falta probar
__sw_stack:
    not ebx
    mov [m_stack + 4 * 512 + 0x7fffeffc + ebx], eax
    jmp _ET

__sw_keyboard:
    mov [input_char], al ; solo 1 byte
    jmp _ET

__sw_screen:
    sub ebx, 0x10008000
    mov [m_screen + ebx], eax
    jmp _ET

__sw_data:
    sub ebx, 0x10010000
    mov [m_data + ebx], eax
    jmp _ET


__nop:
    jmp _ET

