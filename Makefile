test:
	gcc main.c hex2int.c -o hola.app
	./hola.app



loop:
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	nasm -f elf64 -g -F dwarf hex2int.asm -o loop.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o loop.o -o hello.app
	gdb ./hello.app



clear:
	rm *.o
	rm *.app

