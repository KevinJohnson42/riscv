library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity soc_tb is
end entity soc_tb;

architecture testbench of soc_tb is

    signal clock_i   : std_logic := '0';
    signal uart_rx_i : std_logic := '1';
    signal uart_tx_o : std_logic := '0';
    signal gpio_i    : std_logic_vector(31 downto 0) := (others => '0');
    signal gpio_o    : std_logic_vector(31 downto 0) := (others => '0');
    signal vga_r_o   : std_logic_vector(4 downto 0) := (others => '0');
    signal vga_g_o   : std_logic_vector(5 downto 0) := (others => '0');
    signal vga_b_o   : std_logic_vector(4 downto 0) := (others => '0');
    signal vga_hs_o  : std_logic := '0';
    signal vga_vs_o  : std_logic := '0';

begin
    clock_i_ps : process
    begin
        wait for 5 ns;
        clock_i <= not clock_i;
    end process;

    DUT : entity work.soc
        generic map
        (
            uart_cycles_g => 10
        )
        port map
        (
            clock_i   => clock_i,
            uart_rx_i => uart_rx_i,
            uart_tx_o => uart_tx_o,
            gpio_i    => gpio_i,
            gpio_o    => gpio_o,
            vga_r_o   => vga_r_o ,
            vga_g_o   => vga_g_o ,
            vga_b_o   => vga_b_o ,
            vga_hs_o  => vga_hs_o,
            vga_vs_o  => vga_vs_o
        );

    --LOOP back
    gpio_i <= gpio_o;
    uart_rx_i <= uart_tx_o;

end architecture testbench;