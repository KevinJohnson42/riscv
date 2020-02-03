ghdl -a bit_width.vhd
ghdl -a cdr.vhd
ghdl -a fifo_generic.vhd
ghdl -a uart_rx.vhd
ghdl -a uart_tx.vhd
ghdl -a uart.vhd
ghdl -a uart_tb.vhd
ghdl -r uart_tb --stop-time=100us --vcd=tb.vcd