#!/bin/bash
set -e

arg=${1::-2}

rm "${arg}.elf"
rm "${arg}.dump"
rm "${arg}.bin"
rm "vhdl.out"
rm "work-obj08.cf"
rm "tb.ghw"