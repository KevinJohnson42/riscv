library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity vga_map is
    generic
    (
        h_resolution  : natural   := 800;
        h_sync_start  : natural   := 840;
        h_sync_stop   : natural   := 968;
        h_total_count : natural   := 1056;
        h_sync_active : std_logic := '0';

        v_resolution  : natural   := 600;
        v_sync_start  : natural   := 601;
        v_sync_stop   : natural   := 605;
        v_total_count : natural   := 628;
        v_sync_active : std_logic := '0'
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
        vga_r_o       : out std_logic_vector (4 downto 0);
        vga_g_o       : out std_logic_vector (5 downto 0);
        vga_b_o       : out std_logic_vector (4 downto 0);
        vga_hs_o      : out std_logic;
        vga_vs_o      : out std_logic
    );
end vga_map;

architecture rtl of vga_map is
    --Constants
    constant block_size    : positive := 8;
    constant h_address_end : positive := h_resolution/block_size;
    constant v_address_end : positive := h_address_end*(v_resolution/block_size);

    --RAM
    type ram_type is array (8192-1 downto 0) of std_logic_vector(15 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    --VGA
    signal h_count     : unsigned(10 downto 0)        := (others => '0');
    signal h_sync      : std_logic                    := '0';
    signal v_count     : unsigned(9 downto 0)         := (others => '0');
    signal v_sync      : std_logic                    := '0';
    signal pixel_red   : std_logic_vector(4 downto 0) := (others => '0');
    signal pixel_green : std_logic_vector(5 downto 0) := (others => '0');
    signal pixel_blue  : std_logic_vector(4 downto 0) := (others => '0');
    signal blank       : std_logic                    := '0';

    --VRAM
    signal h_end       : std_logic                     := '0';
    signal v_end       : std_logic                     := '0';
    signal h_address   : unsigned(12 downto 0)         := (others => '0');
    signal v_address   : unsigned(12 downto 0)         := (others => '0');
    signal ram_data    : std_logic_vector(15 downto 0) := (others => '0');
    signal ram_address : unsigned(12 downto 0); --No INIT for BRAM

    --MAP
    signal read_valid  : std_logic := '0';
    signal write_valid : std_logic := '0';
    signal dout        : std_logic_vector(31 downto 0);
begin
    read_valid_o  <= read_valid;
    write_valid_o <= write_valid;
    data_o        <= dout;

    map_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            read_valid  <= read_i;
            write_valid <= write_i;
            if (read_i = '1') then
                dout <= x"0000"&ram(to_integer(unsigned(addr_i(13 downto 1))));
            end if;
            if (write_i = '1') then
                ram(to_integer(unsigned(addr_i(13 downto 1)))) <= data_i(15 downto 0);
            end if;
        end if;
    end process;

    --Outputs
    vga_hs_o <= h_sync;
    vga_vs_o <= v_sync;
    vga_r_o  <= pixel_red;
    vga_g_o  <= pixel_green;
    vga_b_o  <= pixel_blue;

    --Horizontal Timing
    h_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (h_count = h_total_count-1) then
                h_count <= (others => '0');
            else
                h_count <= h_count+1;
            end if;
        end if;
    end process;
    h_sync_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (h_count >= h_sync_start) and (h_count < h_sync_stop) then
                h_sync <= h_sync_active;
            else
                h_sync <= not h_sync_active;
            end if;
        end if;
    end process;

    --Vertical Timing
    v_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (h_count = h_total_count-1) and (v_count = v_total_count-1) then
                v_count <= (others => '0');
            elsif (h_count = h_total_count-1) then
                v_count <= v_count+1;
            end if;
        end if;
    end process;
    v_sync_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (v_count >= v_sync_start) and (v_count < v_sync_stop) then
                v_sync <= v_sync_active;
            else
                v_sync <= not v_sync_active;
            end if;
        end if;
    end process;

    --Color Timing
    blank_ps : process(h_count, v_count)
    begin
        if (h_count < h_resolution) and (v_count < v_resolution) then
            blank <= '0';
        else
            blank <= '1';
        end if;
    end process;
    color_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (blank = '1') then
                pixel_red   <= (others => '0');
                pixel_green <= (others => '0');
                pixel_blue  <= (others => '0');
            --elsif (unsigned(h_count) = 0) then
            --    pixel_red     <= (others => '1');
            --    pixel_green   <= (others => '0');
            --    pixel_blue    <= (others => '0');
            --elsif (unsigned(h_count) = h_resolution-1) then
            --    pixel_red     <= (others => '0');
            --    pixel_green   <= (others => '1');
            --    pixel_blue   <= (others => '0');
            --elsif (unsigned(v_count) = 0) then
            --    pixel_red     <= (others => '0');
            --    pixel_green   <= (others => '0');
            --    pixel_blue    <= (others => '1');
            --elsif (unsigned(v_count) = v_resolution-1) then
            --    pixel_red     <= (others => '1');
            --    pixel_green   <= (others => '1');
            --    pixel_blue    <= (others => '1');
            else
                pixel_red   <= ram_data(15 downto 11);
                pixel_green <= ram_data(10 downto 5);
                pixel_blue  <= ram_data(4 downto 0);
            end if;
        end if;
    end process;


    h_end <= '1' when (h_count(2 downto 0) = block_size-3) else '0';
    v_end <= '1' when (v_count(2 downto 0) = block_size-1) else '0';

    h_address_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (h_address = h_address_end-1) and (h_end = '1') then
                h_address <= (others => '0');
            elsif (h_end = '1') and (blank = '0') then
                h_address <= h_address+1;
            end if;
        end if;
    end process;
    v_address_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (v_address = v_address_end-h_address_end) and (h_address = h_address_end-1) and (h_end = '1') and (v_end = '1') then
                v_address <= (others => '0');
            elsif (h_address = h_address_end-1) and (h_end = '1') and (v_end = '1') then
                v_address <= v_address+h_address_end;
            end if;
        end if;
    end process;
    ram_address_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            ram_address <= v_address+h_address;
        end if;
    end process;
    ram_data_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            ram_data <= ram(to_integer(ram_address));
        end if;
    end process;
end rtl;
