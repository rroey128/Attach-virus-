CC=gcc
AS=nasm
CFLAGS=-m32 -Wall -ansi -c -nostdlib -fno-stack-protector -g
LDFLAGS=-m elf_i386
OBJS=start.o util.o main.o

all: task2

task2: $(OBJS)
	ld $(LDFLAGS) $(OBJS) -g -o task2

start.o: start.s
	$(AS) -f elf32 -g start.s -o start.o

util.o: util.c util.h
	$(CC) $(CFLAGS) util.c -o util.o

main.o: main.c util.h
	$(CC) $(CFLAGS) main.c -o main.o

clean:
	rm -f task2 $(OBJS)
