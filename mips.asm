 

%define get_register(i ,r)      mov r, [m_res + i*4]
%define set_register(i, r)      mov [m_res + i*4], r


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




%if 0

// ver las instruciones
https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
https://www.eg.bucknell.edu/~csci320/mips_web/

para las operaciones inmediatas, almacenamos en 
    $k0 – $k1	    $26 – $27 	    Reservados para el núcleo del S.O.


http://www.mrc.uidaho.edu/mrc/people/jff/digital/MIPSir.html


%endif

;-------------------Format R [Funct]-------------------------------------;
%define	_sys_s		0x0c ; TODO(eos175)     syscall


%define	_add_r		0x20
%define _addu_r		0x21
%define _and_r		0x24
%define _div_r		0x1A
%define _divu_r		0x1B
%define _jr_r		0x08
%define	_mfhi_r		0x10
%define _mthi_r		0x11
%define _mflo_r		0x12
%define _mtlo_r		0x13
%define _mult_r		0x18
%define _mul_r		0x02     ; TODO(eos175)
%define _multu_r	0x19
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


%if 0

%define __t1    eax
%define __t2    ecx


%define _add(rd, rs, rt)        __add rd, rs, rt
%define _sub(rd, rs, rt)        __sub rd, rs, rt
%define _mul(rd, rs, rt)        __mul rd, rs, rt
%define _div(rd, rs, rt)        __div rd, rs, rt


%define _or(rd, rs, rt)        __or rd, rs, rt
%define _and(rd, rs, rt)        __and rd, rs, rt
%define _sll(rd, rs, rt)        __sll rd, rs, rt
%define _srl(rd, rs, rt)        __srl rd, rs, rt


%macro __add 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    add __t1, __t2
    set_register(%1, __t1)
%endmacro

%macro __sub 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    sub __t1, __t2
    set_register(%1, __t1)
%endmacro

%macro __mul 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    mul  __t2
    set_register(%1, __t1)
%endmacro


; hay q poner edx en 0
; https://stackoverflow.com/questions/45506439/division-of-two-numbers-in-nasm
%macro __div 3
    xor edx, edx
    get_register(%3, __t2)
    get_register(%2, __t1)
    div __t2
    set_register(%1, __t1)
%endmacro




%macro __or 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    or __t1, __t2
    set_register(%1, __t1)
%endmacro

%macro __and 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    and __t1, __t2
    set_register(%1, __t1)
%endmacro


%macro __sll 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    shl __t1, __t2
    set_register(%1, __t1)
%endmacro

%macro __srl 3
    get_register(%3, __t2)
    get_register(%2, __t1)
    shr __t1, __t2
    set_register(%1, __t1)
%endmacro



%endif