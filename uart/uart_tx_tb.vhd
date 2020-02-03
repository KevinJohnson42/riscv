--------------------------------------------------------------------------------
-- Title       : <Title Block>
-- Project     : Living The Dream
--------------------------------------------------------------------------------
-- File        : uart_tx_tb.vhd
-- Author      : Kevin Johnson
-- Company     : Freedom
-- Created     : Sat Dec 21 09:30:43 2019
-- Last update : Sun Dec 22 10:22:27 2019
-- Platform    : Xilinx
-- Standard    : VHDL-2008
--------------------------------------------------------------------------------
-- Description: 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------

entity uart_tx_tb is
end entity uart_tx_tb;

-----------------------------------------------------------

architecture testbench of uart_tx_tb is

    -- Testbench DUT generics
    constant cycles_g : positive := 10;

    -- Testbench DUT ports
    signal clock_i  : std_logic                    := '0';
    signal enable_i : std_logic                    := '0';
    signal data_i   : std_logic_vector(7 downto 0) := (others => '0');
    signal ready_o  : std_logic                    := '0';
    signal tx_o     : std_logic                    := '0';

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
    --data_i  <= x"55";
    enable_i_ps : process
    begin
        wait for 50 ns;
        wait until clock_i = '1';
        enable_i <= '1';
        L1 : loop
            wait until clock_i = '1';
            if (ready_o = '1') then
                data_i <= std_logic_vector(unsigned(data_i)+1);
            end if;
        end loop;

        --wait until clock_i = '1';
        --enable_i <= '0';
        wait;
    end process;


    -----------------------------------------------------------
    -- Entity Under Test
    -----------------------------------------------------------
    DUT : entity work.uart_tx
        generic map (
            cycles_g => cycles_g
        )
        port map (
            clock_i  => clock_i,
            enable_i => enable_i,
            data_i   => data_i,
            ready_o  => ready_o,
            tx_o     => tx_o
        );

end architecture testbench;