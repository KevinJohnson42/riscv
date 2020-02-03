#!/bin/bash
set -e

arg=${1::-2}

echo "Compiling: ${arg}"
/opt/riscv/bin/./riscv64-unknown-elf-gcc -nostdlib -T linker.ld "${arg}.c" -o "${arg}.elf" -march=rv32i -mabi=ilp32 -Os

echo "Creating .dump"
/opt/riscv/bin/./riscv64-unknown-elf-objdump -D "${arg}.elf" > "${arg}.dump"

echo "Creating .bin"
/opt/riscv/bin/./riscv64-unknown-elf-objcopy "${arg}.elf" -O binary "${arg}.bin"

echo "Hexdump of .bin"
hexdump -C "${arg}.bin"

echo "Writing VHDL inst_pack.vhd"
gcc vhdl.c -o vhdl.out
./vhdl.out "${arg}.bin"