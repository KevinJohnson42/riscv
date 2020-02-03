library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity io_map is
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
        gpio_data_i   : in  std_logic_vector(31 downto 0);
        gpio_data_o   : out std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of io_map is

    signal read_valid  : std_logic        := '0';
    signal write_valid : std_logic        := '0';
    signal io_dout     : std_logic_vector(31 downto 0) := (others => '0');

begin
    read_valid_o  <= read_valid;
    write_valid_o <= write_valid;
    data_o        <= gpio_data_i;
    gpio_data_o   <= io_dout;

    read_valid_o_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            read_valid  <= read_i;
            write_valid <= write_i;
        end if;
    end process;

    io_dout_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') then
                io_dout <= data_i;
            end if;
        end if;
    end process;

end architecture;