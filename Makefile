FORMAT=elf

gcd: gcd.o
	gcc -m32 -nostartfiles -g -o gcd gcd.o

gcd.o: gcd.asm
	nasm -f $(FORMAT) -F dwarf -g gcd.asm

clean:
	rm gcd gcd.o
