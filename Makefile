
build:
	gcc -Wall -c dependencies.c
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o dependencies.o -o mips_emu.app


debug:
	#gdb --args ./mips_emu.app examples/pong.text.hex examples/pong.data.hex
	gdb --args ./mips_emu.app examples/snake.text.hex examples/snake.data.hex


clear:
	rm *.o
	rm *.app
	rm *.log
