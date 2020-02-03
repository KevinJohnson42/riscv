--------------------------------------------------------------------------------
-- Title       : <Title Block>
-- Project     : Living The Dream
--------------------------------------------------------------------------------
-- File        : uart_rx_tb.vhd
-- Author      : Kevin Johnson
-- Company     : Freedom
-- Created     : Sun Dec 22 10:33:57 2019
-- Last update : Sun Dec 22 10:43:42 2019
-- Platform    : Xilinx
-- Standard    : VHDL-2008
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------

entity uart_rx_tb is

end entity uart_rx_tb;

-----------------------------------------------------------

architecture testbench of uart_rx_tb is

    -- Testbench DUT generics
    constant cycles_g : positive := 5;

    -- Testbench DUT ports
    signal clock_i  : std_logic                    := '0';
    signal rx_i     : std_logic                    := '0';
    signal enable_o : std_logic                    := '0';
    signal data_o   : std_logic_vector(7 downto 0) := (others => '0');

    signal tx_clock_i  : std_logic                    := '0';
    signal tx_enable_i : std_logic                    := '0';
    signal tx_data_i   : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_ready_o  : std_logic                    := '0';
    signal tx_o        : std_logic                    := '0';



    -- Other constants
    constant C_CLK_PERIOD : real := 10.0e-9; -- NS

begin
    -----------------------------------------------------------
    -- Clocks and Reset
    -----------------------------------------------------------
    CLK_GEN : process
    begin
        clock_i <= '1';
        wait for C_CLK_PERIOD / 2.0 * (1 SEC);
        clock_i <= '0';
        wait for C_CLK_PERIOD / 2.0 * (1 SEC);
    end process CLK_GEN;

    -----------------------------------------------------------
    -- Testbench Stimulus
    -----------------------------------------------------------

    uart_tx_inst : entity work.uart_tx
        generic map
        (
            cycles_g => cycles_g
        )
        port map
        (
            clock_i  => clock_i,
            enable_i => tx_enable_i,
            data_i   => tx_data_i,
            ready_o  => tx_ready_o,
            tx_o     => tx_o
        );

    tx_enable_i_ps : process
    begin
        wait for 100 ns;
        wait until clock_i = '1';
        tx_enable_i <= '1';
        L1 : loop
            wait until clock_i = '1';
            if (tx_ready_o = '1') then
                tx_data_i <= std_logic_vector(unsigned(tx_data_i)+1);
            end if;
        end loop;
        wait;
    end process;

    rx_i <= tx_o;
    -----------------------------------------------------------
    -- Entity Under Test
    -----------------------------------------------------------
    DUT : entity work.uart_rx
        generic map (
            cycles_g => cycles_g
        )
        port map (
            clock_i  => clock_i,
            rx_i     => rx_i,
            enable_o => enable_o,
            data_o   => data_o
        );




end architecture testbench;