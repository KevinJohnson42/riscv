library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_map is
    generic
    (
        cycles_g : positive := 10;
        depth_g  : positive := 12
    );
    port
    (
        clock_i       : in  std_logic;
        reset_i       : in  std_logic;
        read_i        : in  std_logic;
        write_i       : in  std_logic;
        mask_i        : in  std_logic_vector(3 downto 0);
        addr_i        : in  std_logic_vector(31 downto 0);
        data_i        : in  std_logic_vector(31 downto 0);
        read_valid_o  : out std_logic;
        write_valid_o : out std_logic;
        data_o        : out std_logic_vector(31 downto 0);
        rx_i          : in  std_logic;
        tx_o          : out std_logic
    );
end entity;


architecture rtl of uart_map is

    signal read_valid  : std_logic := '0';
    signal write_valid : std_logic := '0';

    signal write_enable : std_logic := '0';
    signal read_enable  : std_logic := '0';
    signal write_ready  : std_logic := '0';
    signal read_ready   : std_logic := '0';
    signal fifo_dout    : std_logic_vector(7 downto 0) := (others => '0');
    signal fifo_din     : std_logic_vector(7 downto 0) := (others => '0');
    signal write_count  : std_logic_vector(depth_g downto 0) := (others => '0');
    signal read_count   : std_logic_vector(depth_g downto 0) := (others => '0');
    signal address      : unsigned(3 downto 0) := (others => '0');

begin
    read_valid_o  <= read_valid;
    write_valid_o <= write_valid;
    address       <= unsigned(addr_i(3 downto 0));

    write_fifo_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then

            if (address = 0) then
                write_enable <= write_i;
                write_valid  <= write_i;
                read_enable  <= read_i;
                read_valid   <= read_i;
                data_o       <= x"000000" & fifo_dout;
                fifo_din     <= data_i(7 downto 0);
            elsif (address = 1) then
                write_valid <= write_i;
                read_valid  <= read_i;
                data_o      <= x"0000000" & "000" & read_ready;
            elsif (address = 2) then
                write_valid <= write_i;
                read_valid  <= read_i;
                data_o      <= x"0000000" & "000" & write_ready;
            elsif (address = 4) then
                write_valid <= write_i;
                read_valid  <= read_i;
                data_o(31 downto depth_g+1) <= (others => '0');
                data_o(depth_g downto 0) <= read_count;
            elsif (address = 8) then
                write_valid <= write_i;
                read_valid  <= read_i;
                data_o(31 downto depth_g+1) <= (others => '0');
                data_o(depth_g downto 0) <= write_count;
            end if;
        end if;
    end process;

    uart_1 : entity work.uart
        generic map (
            cycles_g => cycles_g,
            depth_g  => depth_g,
            fwft_g   => 1,
            ccd_g    => 0
        )
        port map (
            uart_clock_i => clock_i,
            fifo_clock_i => clock_i,
            reset_i      => reset_i,
            tx_o         => tx_o,
            rx_i         => rx_i,
            w_ready_o    => write_ready,
            w_enable_i   => write_enable,
            w_data_i     => fifo_din,
            w_count_o    => write_count,
            r_ready_o    => read_ready,
            r_enable_i   => read_enable,
            r_data_o     => fifo_dout,
            r_count_o    => read_count
        );

end architecture;