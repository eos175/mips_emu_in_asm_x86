
; Leer de consola es a través de STDIN
STDIN_FILENO: equ 0
;Necesario para limpiar consona
F_SETFL:	equ 0x0004
;O_NONBLOCK: equ 0x0004


; Acá básicamente le estoy asignando nombres a los syscalls
sys_read: equ 0	
sys_write:	equ 1
sys_nanosleep:	equ 35
sys_time:	equ 201
sys_fcntl:	equ 72

section .data


    ;Este comando es para limpiar la pantalla, no es intuitivo usenlo como tal
    clear:		db 27, "[2J", 27, "[H"
    clear_length:	equ $-clear
        

    ; Esto se requiere para que la termina no se bloquee usar tal cual
    termios:        times 36 db 0
    stdin:          equ 0
    ICANON:         equ 1<<1
    ECHO:           equ 1<<3
    VTIME: 			equ 5
    VMIN:			equ 6
    CC_C:			equ 18


; Esto es para hacer un sleep
timespec:
tv_sec  dq 0
tv_nsec dq 9000000 ;200 000 000


section .bss

    input_char RESB 1

section .text



; Este par que están tienen que ver con lo de consola y no bloquearla, uselos tal cual
%macro setnonblocking 0
	mov rax, sys_fcntl
    mov rdi, STDIN_FILENO
    mov rsi, F_SETFL
    mov rdx, O_NONBLOCK
    syscall
%endmacro

%macro unsetnonblocking 0
        mov rax, sys_fcntl
    mov rdi, STDIN_FILENO
    mov rsi, F_SETFL
    mov rdx, 0
    syscall
%endmacro


%macro print 2
	mov eax, sys_write ; Aca le digo cual syscall quier aplicar
	mov edi, 1 	; stdout, Aca le digo a donde quiero escribir
	mov rsi, %1 ;Aca va el mensaje
	mov edx, %2 ;Aca el largo del mensaje
	syscall
%endmacro


;Usenlo tal cual está acá
%macro getchar 0
    mov     rax, sys_read
    mov     rdi, STDIN_FILENO
    mov     rsi, input_char
    mov     rdx, 1 ; Numero de bytes que vamos a leer (solo es uno)
    syscall         ;recuperar el texto desde la consola
%endmacro


%macro sleeptime 0
	mov eax, sys_nanosleep
	mov rdi, timespec
	xor esi, esi		; ignore remaining time in case of call interruption
	syscall			; sleep for tv_sec seconds + tv_nsec nanoseconds
%endmacro


;Acá va el código que se va a utilizar
;;;;;;;;;;;;;;;;;;;;Todo esto es para lo de la terminal, usar tal cual;;;;;;;;;;;;;;;;;
canonical_off:
        call read_stdin_termios

        ; clear canonical bit in local mode flags
        push rax
        mov eax, ICANON
        not eax
        and [termios+12], eax
		mov byte[termios+CC_C+VTIME], 0
		mov byte[termios+CC_C+VMIN], 0
        pop rax

        call write_stdin_termios
        ret

echo_off:
        call read_stdin_termios

        ; clear echo bit in local mode flags
        push rax
        mov eax, ECHO
        not eax
        and [termios+12], eax
        pop rax

        call write_stdin_termios
        ret

canonical_on:
        call read_stdin_termios

        ; set canonical bit in local mode flags
        or dword [termios+12], ICANON
		mov byte[termios+CC_C+VTIME], 0
		mov byte[termios+CC_C+VMIN], 1
        call write_stdin_termios
        ret

echo_on:
        call read_stdin_termios

        ; set echo bit in local mode flags
        or dword [termios+12], ECHO

        call write_stdin_termios
        ret

read_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5401h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

write_stdin_termios:
        push rax
        push rbx
        push rcx
        push rdx

        mov eax, 36h
        mov ebx, stdin
        mov ecx, 5402h
        mov edx, termios
        int 80h

        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

