nasm -f elf64 -g -F dwarf -o project.o project.asm
ld -o project project.o
./project
