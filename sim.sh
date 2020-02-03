#!/bin/bash
set -e

echo "Compiling UART"
ghdl -a --std=08 uart/bit_width.vhd uart/fifo_generic.vhd uart/cdr.vhd
ghdl -a --std=08 uart/uart_rx.vhd uart/uart_tx.vhd uart/uart.vhd

echo "Compiling RISCV core and devices"
ghdl -a --std=08 inst_pack.vhd core.vhd memory_controller.vhd ram.vhd timer_map.vhd uart_map.vhd io_map.vhd vga_map.vhd

echo "Compiling RISCV SOC"
ghdl -a --std=08 soc.vhd soc_tb.vhd

echo "Simulating. View: gtkwave tb.ghw"
ghdl -r --std=08 soc_tb --stop-time=$1 --wave=tb.ghw