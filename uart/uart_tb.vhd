--------------------------------------------------------------------------------
-- Title       : UART TB
-- Project     : Living The Dream
--------------------------------------------------------------------------------
-- File        : uart_tb.vhd
-- Author      : Kevin Johnson
-- Company     : Freedom
-- Created     : Mon Dec 23 21:35:43 2019
-- Last update : Tue Jan  7 17:32:36 2020
-- Platform    : Xilinx
-- Standard    : VHDL-2008
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-----------------------------------------------------------

entity uart_tb is

end entity uart_tb;

-----------------------------------------------------------

architecture testbench of uart_tb is

    -- Testbench DUT generics
    constant cycles_g : positive := 10;
    constant depth_g  : positive := 12;
    constant fwft_g   : natural  := 1;
    constant ccd_g    : natural  := 0;

    -- Testbench DUT ports
    signal uart_clock_i : std_logic                          := '0';
    signal fifo_clock_i : std_logic                          := '0';
    signal reset_i      : std_logic                          := '0';
    signal tx_o         : std_logic                          := '0';
    signal rx_i         : std_logic                          := '0';
    signal w_ready_o    : std_logic                          := '0';
    signal w_enable_i   : std_logic                          := '0';
    signal w_data_i     : std_logic_vector(7 downto 0)       := (others => '0');
    signal w_count_o    : std_logic_vector(depth_g downto 0) := (others => '0');
    signal r_ready_o    : std_logic                          := '0';
    signal r_enable_i   : std_logic                          := '0';
    signal r_data_o     : std_logic_vector(7 downto 0)       := (others => '0');
    signal r_count_o    : std_logic_vector(depth_g downto 0) := (others => '0');

    -- Other constants
    constant C_CLK_PERIOD : real := 10.0e-9; -- NS

begin
    -----------------------------------------------------------
    -- Clocks and Reset
    -----------------------------------------------------------
    CLK_GEN : process
    begin
        uart_clock_i <= '1';
        wait for C_CLK_PERIOD / 2.0 * (1 SEC);
        uart_clock_i <= '0';
        wait for C_CLK_PERIOD / 2.0 * (1 SEC);
    end process CLK_GEN;

    -----------------------------------------------------------
    -- Testbench Stimulus
    -----------------------------------------------------------
    w_enable_i_ps : process
    begin
        for i in 0 to 127 loop
            wait until uart_clock_i = '1';
            w_enable_i <= '0';
        end loop;
        for i in 0 to 3 loop
            wait until uart_clock_i = '1';
            w_enable_i <= '1';
        end loop;
        for i in 0 to 127 loop
            wait until uart_clock_i = '1';
            w_enable_i <= '0';
        end loop;
    end process;

    w_data_i_ps : process
    begin
        wait until uart_clock_i = '1';
        if (w_enable_i = '1') and (w_ready_o = '1') then
            w_data_i <= std_logic_vector(unsigned(w_data_i)+1);
        end if;
    end process;

    r_enable_i <= '1';
    rx_i <= transport tx_o after 13 ns;
    -----------------------------------------------------------
    -- Entity Under Test
    -----------------------------------------------------------
    DUT : entity work.uart
        generic map (
            cycles_g => cycles_g,
            depth_g  => depth_g,
            fwft_g   => fwft_g,
            ccd_g    => ccd_g
        )
        port map (
            uart_clock_i => uart_clock_i,
            fifo_clock_i => uart_clock_i,
            reset_i      => reset_i,
            tx_o         => tx_o,
            rx_i         => rx_i,
            w_ready_o    => w_ready_o,
            w_enable_i   => w_enable_i,
            w_data_i     => w_data_i,
            w_count_o    => w_count_o,
            r_ready_o    => r_ready_o,
            r_enable_i   => r_enable_i,
            r_data_o     => r_data_o,
            r_count_o    => r_count_o
        );

end architecture testbench;