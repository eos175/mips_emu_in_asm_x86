#  MIPS Emulator in Assembly x86
The idea of ​​this project is to do something similar to what MARS2 does, to be able to interpret
MIPS type instructions and use the linux terminal as a graphical environment to have
data output and input. All this is designed in asssembler for the x86 CPU architecture 


## Installing NASM

```shell
sudo apt-get install -y nasm
```


## How do I compile the Emulator?

```shell
make build
```
## Change the Command Line Arguments

### pong

```shell
./mips_emu.app ejemplos/pong.text.hex ejemplos/pong.data.hex
```
![pong](https://user-images.githubusercontent.com/68199556/95167002-18457680-076c-11eb-93cd-0e7d73cafae0.gif)

### snake

```shell
./mips_emu.app ejemplos/snake.text.hex ejemplos/snake.data.hex
```
![snake](https://user-images.githubusercontent.com/68199556/95167040-2abfb000-076c-11eb-9951-308f44228cbf.gif)


## run MARS2

```shell
java -jar MARS2.jar
```


## ToDo

- [x] use git
- [x] bin -> hex
- [x] do makefile
- [x] reed args
- [x] reed file
- [x] link the emulator
- [x] $gp -> pointer screen
- [x] pointer keyboard



## References

All suggestions and criticism are welcome

[Netwide Ensamblador - Netwide Assembler](https://es.qwe.wiki/wiki/Netwide_Assembler)

[x86_64 Linux Assembly #1 - "Hello, World!"](https://www.youtube.com/watch?v=VQAKkuLL31g)

[x86_64 Linux Assembly #12 - Reading Files](https://www.youtube.com/watch?v=BljOGzRP_Ws)

[Combine C & Assembly](https://cs.lmu.edu/~ray/notes/nasmtutorial/)

