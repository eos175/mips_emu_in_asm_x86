section .data
	filename db "def.text.hex",0

section .bss
	text resb 9

section .text
	global _start

_start:
	;ABIR EL ARCHIVO, SYS_OPEN;
	
	mov rax, 2
	mov rdi, filename
	;FLAG PARA LEER EL ARCHIVO [O_RDONLY = 0];
	mov rsi, 0
	;DEFINO LOS PERMISOS;
	mov rdx, 0644o
	syscall
	
	;LEO EL ARCHIVO, SYS_READ;
	push rax
	;LE PASO LA ETIQUETA DEL ARCHIVO;
	mov rdi, rax
	mov rax, 0
	mov rsi, text
	mov rdx, 9
	syscall

	;CIERRO EL ARCHIVO, SYS_CLOSE;
	mov rax, 3
	pop rdi
	syscall
	
	;PRINT LO QUE HAYA LEIDO;
	call _printText	
	
	;RETURN 0;
	mov rax, 60
	mov rdi, 0
	syscall

_printText:
	mov rax, 1
	mov rdi, 1
	mov rsi, text
	mov rdx, 9

	syscall
	ret
