library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inst_pack.all;

entity ram is
    generic
    (
        ram_depth_g  : natural    := 10;
        ram_byte_0_g : data_array := (others => (others => '0'));
        ram_byte_1_g : data_array := (others => (others => '0'));
        ram_byte_2_g : data_array := (others => (others => '0'));
        ram_byte_3_g : data_array := (others => (others => '0'))
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
        data_o        : out std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of ram is

    constant depth_c   : positive                      := ram_depth_g;
    signal ram_byte_0  : data_array                    := ram_byte_0_g;
    signal ram_byte_1  : data_array                    := ram_byte_1_g;
    signal ram_byte_2  : data_array                    := ram_byte_2_g;
    signal ram_byte_3  : data_array                    := ram_byte_3_g;
    signal addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal read_valid  : std_logic                     := '0';
    signal write_valid : std_logic                     := '0';
    signal valid       : std_logic                     := '0';
    signal dout        : std_logic_vector(31 downto 0) := (others => '0');

    signal address : unsigned(depth_c-1 downto 0) := (others => '0');

begin

    read_valid_o  <= read_valid;
    write_valid_o <= write_valid;
    data_o        <= dout;

    address <= unsigned(addr_i(depth_c-1 downto 0));

    write_byte_0_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') and (address(1 downto 0) = 0) and (mask_i(0) = '1') then
                ram_byte_0(to_integer(address(depth_c-1 downto 2))) <= data_i(7 downto 0);
            elsif (write_i = '1') and (address(1 downto 0) = 1) and (mask_i(3) = '1') then
                ram_byte_0(to_integer(address(depth_c-1 downto 2))) <= data_i(31 downto 24);
            elsif (write_i = '1') and (address(1 downto 0) = 2) and (mask_i(2) = '1') then
                ram_byte_0(to_integer(address(depth_c-1 downto 2))) <= data_i(23 downto 16);
            elsif (write_i = '1') and (address(1 downto 0) = 3) and (mask_i(1) = '1') then
                ram_byte_0(to_integer(address(depth_c-1 downto 2))) <= data_i(15 downto 8);
            end if;
        end if;
    end process;
    write_byte_1_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') and (address(1 downto 0) = 0) and (mask_i(1) = '1') then
                ram_byte_1(to_integer(address(depth_c-1 downto 2))) <= data_i(15 downto 8);
            elsif (write_i = '1') and (address(1 downto 0) = 1) and (mask_i(0) = '1') then
                ram_byte_1(to_integer(address(depth_c-1 downto 2))) <= data_i(7 downto 0);
            elsif (write_i = '1') and (address(1 downto 0) = 2) and (mask_i(3) = '1') then
                ram_byte_1(to_integer(address(depth_c-1 downto 2))) <= data_i(31 downto 24);
            elsif (write_i = '1') and (address(1 downto 0) = 3) and (mask_i(2) = '1') then
                ram_byte_1(to_integer(address(depth_c-1 downto 2))) <= data_i(23 downto 16);
            end if;
        end if;
    end process;
    write_byte_2_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') and (address(1 downto 0) = 0) and (mask_i(2) = '1') then
                ram_byte_2(to_integer(address(depth_c-1 downto 2))) <= data_i(23 downto 16);
            elsif (write_i = '1') and (address(1 downto 0) = 1) and (mask_i(1) = '1') then
                ram_byte_2(to_integer(address(depth_c-1 downto 2))) <= data_i(15 downto 8);
            elsif (write_i = '1') and (address(1 downto 0) = 2) and (mask_i(0) = '1') then
                ram_byte_2(to_integer(address(depth_c-1 downto 2))) <= data_i(7 downto 0);
            elsif (write_i = '1') and (address(1 downto 0) = 3) and (mask_i(3) = '1') then
                ram_byte_2(to_integer(address(depth_c-1 downto 2))) <= data_i(31 downto 24);
            end if;
        end if;
    end process;
    write_byte_3_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') and (address(1 downto 0) = 0) and (mask_i(3) = '1') then
                ram_byte_3(to_integer(address(depth_c-1 downto 2))) <= data_i(31 downto 24);
            elsif (write_i = '1') and (address(1 downto 0) = 1) and (mask_i(2) = '1') then
                ram_byte_3(to_integer(address(depth_c-1 downto 2))) <= data_i(23 downto 16);
            elsif (write_i = '1') and (address(1 downto 0) = 2) and (mask_i(1) = '1') then
                ram_byte_3(to_integer(address(depth_c-1 downto 2))) <= data_i(15 downto 8);
            elsif (write_i = '1') and (address(1 downto 0) = 3) and (mask_i(0) = '1') then
                ram_byte_3(to_integer(address(depth_c-1 downto 2))) <= data_i(7 downto 0);
            end if;
        end if;
    end process;

    read_valid_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            read_valid <= read_i;
        end if;
    end process;

    write_valid_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            write_valid <= write_i;
        end if;
    end process;

    read_byte_0_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (read_i = '1') and (address(1 downto 0) = 0) then
                dout <= ram_byte_3(to_integer(address(depth_c-1 downto 2))) & ram_byte_2(to_integer(address(depth_c-1 downto 2))) & ram_byte_1(to_integer(address(depth_c-1 downto 2))) & ram_byte_0(to_integer(address(depth_c-1 downto 2)));
            elsif (read_i = '1') and (address(1 downto 0) = 1) then
                dout <= ram_byte_0(to_integer(address(depth_c-1 downto 2))) & ram_byte_3(to_integer(address(depth_c-1 downto 2))) & ram_byte_2(to_integer(address(depth_c-1 downto 2))) & ram_byte_1(to_integer(address(depth_c-1 downto 2)));
            elsif (read_i = '1') and (address(1 downto 0) = 2) then
                dout <= ram_byte_1(to_integer(address(depth_c-1 downto 2))) & ram_byte_0(to_integer(address(depth_c-1 downto 2))) & ram_byte_3(to_integer(address(depth_c-1 downto 2))) & ram_byte_2(to_integer(address(depth_c-1 downto 2)));
            elsif (read_i = '1') and (address(1 downto 0) = 3) then
                dout <= ram_byte_0(to_integer(address(depth_c-1 downto 2))) & ram_byte_1(to_integer(address(depth_c-1 downto 2))) & ram_byte_2(to_integer(address(depth_c-1 downto 2))) & ram_byte_3(to_integer(address(depth_c-1 downto 2)));
            end if;
        end if;
    end process;



end architecture;