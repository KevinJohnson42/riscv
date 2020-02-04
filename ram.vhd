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
    signal ram_0       : data_array                    := ram_byte_0_g;
    signal ram_1       : data_array                    := ram_byte_1_g;
    signal ram_2       : data_array                    := ram_byte_2_g;
    signal ram_3       : data_array                    := ram_byte_3_g;
    signal addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal read_valid  : std_logic                     := '0';
    signal write_valid : std_logic                     := '0';
    signal valid       : std_logic                     := '0';
    signal dout        : std_logic_vector(31 downto 0) := (others => '0');
    signal byte_0      : std_logic_vector(7 downto 0)  := (others => '0');
    signal byte_1      : std_logic_vector(7 downto 0)  := (others => '0');
    signal byte_2      : std_logic_vector(7 downto 0)  := (others => '0');
    signal byte_3      : std_logic_vector(7 downto 0)  := (others => '0');
    signal offset      : unsigned(1 downto 0)          := (others => '0');
    signal address     : natural                       := 0;

begin

    read_valid_o  <= read_valid;
    write_valid_o <= write_valid;
    data_o        <= dout;

    byte_0 <= data_i(7 downto 0);
    byte_1 <= data_i(15 downto 8);
    byte_2 <= data_i(23 downto 16);
    byte_3 <= data_i(31 downto 24);


    offset  <= unsigned(addr_i(1 downto 0));
    address <= to_integer(unsigned(addr_i(depth_c-1 downto 2)));

    write_ram_0_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') then
                if (offset = 0) and (mask_i(0) = '1') then ram_0(address) <= byte_0;
                elsif (offset = 1) and (mask_i(3) = '1') then ram_0(address) <= byte_3;
                elsif (offset = 2) and (mask_i(2) = '1') then ram_0(address) <= byte_2;
                elsif (offset = 3) and (mask_i(1) = '1') then ram_0(address) <= byte_1;
                end if;
            end if;
        end if;
    end process;
    write_ram_1_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') then
                if (offset = 0) and (mask_i(1) = '1') then ram_1(address) <= byte_1;
                elsif (offset = 1) and (mask_i(0) = '1') then ram_1(address) <= byte_0;
                elsif (offset = 2) and (mask_i(3) = '1') then ram_1(address) <= byte_3;
                elsif (offset = 3) and (mask_i(2) = '1') then ram_1(address) <= byte_2;
                end if;
            end if;
        end if;
    end process;
    write_ram_2_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') then
                if (offset = 0) and (mask_i(2) = '1') then ram_2(address) <= byte_2;
                elsif (offset = 1) and (mask_i(1) = '1') then ram_2(address) <= byte_1;
                elsif (offset = 2) and (mask_i(0) = '1') then ram_2(address) <= byte_0;
                elsif (offset = 3) and (mask_i(3) = '1') then ram_2(address) <= byte_3;
                end if;
            end if;
        end if;
    end process;
    write_ram_3_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (write_i = '1') then
                if (offset = 0) and (mask_i(3) = '1') then ram_3(address) <= byte_3;
                elsif (offset = 1) and (mask_i(2) = '1') then ram_3(address) <= byte_2;
                elsif (offset = 2) and (mask_i(1) = '1') then ram_3(address) <= byte_1;
                elsif (offset = 3) and (mask_i(0) = '1') then ram_3(address) <= byte_0;
                end if;
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

    read_ram_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (read_i = '1') then
                if (offset = 0) then dout <= ram_3(address) & ram_2(address) & ram_1(address) & ram_0(address);
                elsif (offset = 1) then dout <= ram_0(address) & ram_3(address) & ram_2(address) & ram_1(address);
                elsif (offset = 2) then dout <= ram_1(address) & ram_0(address) & ram_3(address) & ram_2(address);
                elsif (offset = 3) then dout <= ram_2(address) & ram_1(address) & ram_0(address) & ram_3(address);
                end if;
            end if;
        end if;
    end process;



end architecture;