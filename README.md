# riscv
RISCV because why not.

### RISCV implementation
The source code is written in VHDL using the 2008 standard.
The RISCV core itself is a base integer instruction set RV32I with 40 instructions.
It is designed to be easily debugged at the cost of performance.

### Execution
A state machine steps through each instruction.

Fetch	- Read the address in the program counter register. Wait for the instruction.
Decode 	- Convert the 32 bit instruction into an easily readable format.
Execute - Preform the decoded operation. Update ALU output. Update register write enable.
Load 	- Read the calculated memory address and store the result in register rd.
Store 	- Write the calculated memory address with the data in rs2.

### Instructions Per Second
I already mentioned that it is slow. Lets examine why.

Memory access - 4 cycles. Core -> Memory_controller -> Device -> Memory_controller -> Core
State machine - Each state takes a cycle

Example 1: BEQ, This takes 5 + 1 + 1 cycles because Fetch(5), Decode(1), Execute(1)
Example 2: LBU, This takes 5 + 1 + 1 + 4 cycles because Fetch(5), Decode(1), Execute(1), Load(4)


### Files
core.vhd 				- The whole RV32I core.
memory_controller.vhd 	- Connects the core to memory mapped devices.
soc.vhd 				- Includes everything. The core, controller, and memory mapped devices.

### GNU Toolchain
If you would like to program in C or C++, then make sure to do the following.
Clone the GNU toolchain and build the Newlib cross-compiler.

	git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
	sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
    cd riscv-gnu-toolchain
    ./configure --prefix=/opt/riscv
    sudo make -j8

### Compile C
I'll update this section later

### Analyze HDL
I'll update this section later

### Simulate with compiled instructions
I'll update this section later

### Program an FPGA
I'll update this section later

### Debug
I'll update this section later