test:
	gcc main.c hex2int.c -o hola.app
	./hola.app


debug:
	gcc -Wall -c test.c 
	nasm -f elf64 -g -F dwarf main.asm -o main.o
	ld -lc -I /lib64/ld-linux-x86-64.so.2 main.o test.o -o hello.app
	gdb --args ./hello.app snake.text.hex snake.data.hex



clear:
	rm *.o
	rm *.app

