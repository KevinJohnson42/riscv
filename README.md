# riscv
RISCV because why not.

### GNU Toolchain 
Clone the GNU toolchain and build the Newlib cross-compiler.

	git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
	sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
    ./configure --prefix=/opt/riscv
    sudo make -j8