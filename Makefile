
build:
	gcc -Wall -c dependencies.c
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o dependencies.o -o mips_emu.app


debug:
	#gdb --args ./mips_emu.app ejemplos/pong.text.hex ejemplos/pong.data.hex
	gdb --args ./mips_emu.app ejemplos/snake.text.hex ejemplos/snake.data.hex


clear:
	rm *.o
	rm *.app
	rm *.log
