test:
	gcc main.c hex2int.c -o hola.app
	./hola.app



loop:
	gcc -Wall -c test.c 
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	nasm -f elf64 -g -F dwarf hex2int.asm -o loop.o
	nasm -f elf64 -g -F dwarf read_file.asm -o read_file.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o loop.o read_file.o test.o -o hello.app
	gdb --args ./hello.app def.text.hex def.data.hex



clear:
	rm *.o
	rm *.app

