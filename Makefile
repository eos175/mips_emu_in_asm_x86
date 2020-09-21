test:
	gcc main.c hex2int.c test.c -o hola.app
	./hola.app


build:
	gcc -Wall -c test.c
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o test.o -o hello.app

debug:
	gdb --args ./hello.app pong.text.hex pong.data.hex
	#gdb --args ./hello.app snake.text.hex snake.data.hex


clear:
	rm *.o
	rm *.app

