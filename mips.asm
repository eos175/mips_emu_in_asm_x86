

%define get_register(i ,r)      mov r, [registers + i*4]
%define set_register(i, r)      mov [registers + i*4], r




%if 0

// ver las instruciones
https://en.wikibooks.org/wiki/MIPS_Assembly/Instruction_Formats
https://www.eg.bucknell.edu/~csci320/mips_web/

para las operaciones inmediatas, almacenamos en 
    $k0 – $k1	    $26 – $27 	    Reservados para el núcleo del S.O.


%endif



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


