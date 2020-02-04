# riscv
RISCV because why not.

### RISCV implementation
The source code is written in VHDL using the 2008 standard.
The RISCV core itself is a base integer instruction set RV32I with 40 instructions.
It is designed to be easily debugged at the cost of performance.

### Download

	git clone https://github.com/KevinJohnson42/riscv

### GNU Toolchain
If you would like to program in C or C++, then make sure to do the following.
Clone the GNU toolchain and build the Newlib cross-compiler.

	git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
	sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
    cd riscv-gnu-toolchain
    ./configure --prefix=/opt/riscv
    sudo make -j8

### GHDL and GTKWAVE
If you would like to simulate vhdl using the scripts. Install GHDL.

	sudo apt install ghdl gtkwave

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

### Compile C

    ./compile.sh program.c

### Analyze and Simulate HDL

    ./sim.sh 100us
    gtkwave tb.ghw

### All in one. Compile, Analyze, Simulate

    ./all.sh program.c 100us

### Remove generated files

    ./clean.sh program.c

### Create memory mapped devices
Open soc.vhd. Find the memory_controller instantiation. Modify the next available address range. Connect your device to the controller.

### Program an FPGA
For Xilinx, The instruction RAM should be infered as BRAM.
Don't forget to include your IO constraints.

### You've read this far
It is a work in progress. Please don't expect it to "just work". As of 02/04/2020 i'm still working on it.