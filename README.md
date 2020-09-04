#  Emulador MIPS en ensamblador x_86 


## Instalar ensamblador NASM

```shell
sudo apt-get install -y nasm
```


## Compilar

```shell
nasm -f elf64 hello.asm -o hello.o
ld hello.o -o hello.app
./hello.app
```


## correr MARS2

```shell
java -jar MARS2.jar
```


## ToDo

- [x] usar git
- [x] bin -> hex, ver main.py
- [ ] hacer makefile
- [ ] leer args
- [ ] leer archivo


## Referencia

[Netwide Ensamblador - Netwide Assembler](https://es.qwe.wiki/wiki/Netwide_Assembler)

[x86_64 Linux Assembly #1 - "Hello, World!"](https://www.youtube.com/watch?v=VQAKkuLL31g)

[x86_64 Linux Assembly #12 - Reading Files](https://www.youtube.com/watch?v=BljOGzRP_Ws)

[obtener argumentos, code](https://gist.github.com/Gydo194/730c1775f1e05fdca6e9b0c175636f5b)

[MIPS-Simulator-Python](https://github.com/GeorgeSaman/MIPS-Simulator-Python)

[Combinacion de C y Ensamblador](https://cs.lmu.edu/~ray/notes/nasmtutorial/)

