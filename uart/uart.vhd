library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bit_width.all;

entity uart is
    generic
    (
        cycles_g : positive := 10;
        depth_g  : positive := 12;
        fwft_g   : natural  := 0;
        ccd_g    : natural  := 0
    );
    port
    (
        uart_clock_i : in  std_logic;
        fifo_clock_i : in  std_logic;
        reset_i      : in  std_logic;
        tx_o         : out std_logic;
        rx_i         : in  std_logic;
        w_ready_o    : out std_logic;
        w_enable_i   : in  std_logic;
        w_data_i     : in  std_logic_vector(7 downto 0);
        w_count_o    : out std_logic_vector(depth_g downto 0);
        r_ready_o    : out std_logic;
        r_enable_i   : in  std_logic;
        r_data_o     : out std_logic_vector(7 downto 0);
        r_count_o    : out std_logic_vector(depth_g downto 0)
    );
end entity uart;

architecture rtl of uart is
    signal uart_tx_enable_i : std_logic                    := '0';
    signal uart_tx_data_i   : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx_ready_o  : std_logic                    := '0';
    signal uart_rx_enable_o : std_logic                    := '0';
    signal uart_rx_data_o   : std_logic_vector(7 downto 0) := (others => '0');
begin
    uart_tx_inst : entity work.uart_tx
        generic map
        (
            cycles_g => cycles_g
        )
        port map
        (
            clock_i  => uart_clock_i,
            enable_i => uart_tx_enable_i,
            data_i   => uart_tx_data_i,
            ready_o  => uart_tx_ready_o,
            tx_o     => tx_o
        );
    uart_rx_inst : entity work.uart_rx
        generic map
        (
            cycles_g => cycles_g
        )
        port map
        (
            clock_i  => uart_clock_i,
            rx_i     => rx_i,
            enable_o => uart_rx_enable_o,
            data_o   => uart_rx_data_o
        );
    fifo_generic_tx_inst : entity work.fifo_generic
        generic map
        (
            width_g => 8,
            depth_g => depth_g,
            fwft_g  => 1,
            ccd_g   => ccd_g
        )
        port map
        (
            reset_i    => reset_i,
            w_clock_i  => fifo_clock_i,
            w_ready_o  => w_ready_o,
            w_enable_i => w_enable_i,
            w_data_i   => w_data_i,
            w_count_o  => w_count_o,
            r_clock_i  => uart_clock_i,
            r_ready_o  => uart_tx_enable_i,
            r_enable_i => uart_tx_ready_o,
            r_data_o   => uart_tx_data_i,
            r_count_o  => open
        );
    fifo_generic_rx_inst : entity work.fifo_generic
        generic map
        (
            width_g => 8,
            depth_g => depth_g,
            fwft_g  => fwft_g,
            ccd_g   => ccd_g
        )
        port map
        (
            reset_i    => reset_i,
            w_clock_i  => uart_clock_i,
            w_ready_o  => open,
            w_enable_i => uart_rx_enable_o,
            w_data_i   => uart_rx_data_o,
            w_count_o  => open,
            r_clock_i  => fifo_clock_i,
            r_ready_o  => r_ready_o,
            r_enable_i => r_enable_i,
            r_data_o   => r_data_o,
            r_count_o  => r_count_o
        );
end architecture rtl;