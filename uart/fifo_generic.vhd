----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity fifo_normal is
generic
(
    width_g     : positive   := 8;
    depth_g     : positive   := 8
);
port
(
    clock_i     : in  std_logic;
    reset_i     : in  std_logic;
    w_ready_o   : out std_logic;
    w_enable_i  : in  std_logic;
    w_data_i    : in  std_logic_vector(width_g-1 downto 0);
    r_ready_o   : out std_logic;
    r_enable_i  : in  std_logic;
    r_data_o    : out std_logic_vector(width_g-1 downto 0);
    count_o     : out std_logic_vector(depth_g downto 0)
);
end entity;
architecture rtl of fifo_normal is
    --RAM buffer
    type memory is array (0 to 2**depth_g-1) of std_logic_vector(width_g-1 downto 0);
    signal ram              : memory                                := (others => (others => '0'));
    signal ram_out          : std_logic_vector(width_g-1 downto 0)  := (others => '0');

    --Read signals
    signal valid_read       : std_logic                             := '0';
    signal read_address     : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_ready       : std_logic                             := '0';

    --Write signals
    signal valid_write      : std_logic                             := '0';
    signal write_address    : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_ready      : std_logic                             := '1';
    
    --Data count
    signal count            : unsigned(depth_g downto 0)            := (others => '0');

begin
    --Outputs
    w_ready_o   <= write_ready;
    r_ready_o   <= read_ready;
    r_data_o    <= ram_out;
    count_o     <= std_logic_vector(count);
    
    --Internal
    valid_read  <= r_enable_i and read_ready;
    valid_write <= w_enable_i and write_ready;
    read_address_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                read_address <= (others => '0');
            else
                if (valid_read = '1') then
                    read_address <= read_address+1;
                end if;
            end if;
        end if;
    end process;
    write_address_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                write_address <= (others => '0');
            else
                if (valid_write = '1') then
                    write_address <= write_address+1;
                end if;
            end if;
        end if;
    end process;
    count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                count <= (others => '0');
            else
                if (valid_write = '1') and (valid_read = '0') then
                    count <= count + 1;
                elsif (valid_write = '0') and (valid_read = '1') then
                    count <= count - 1;
                end if;
            end if;
        end if;
    end process;
    ram_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (valid_write = '1') then
                ram(to_integer(write_address)) <= w_data_i;
            end if;
        end if;
    end process;
    ram_out_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (valid_read = '1') then
                ram_out <= ram(to_integer(read_address));
            end if;
        end if;
    end process;
    read_ready_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                read_ready <= '0';
            else
                if (read_address = write_address-1) and (valid_read = '1') and (valid_write = '0') then
                    read_ready <= '0';
                elsif (valid_read = '0') and (valid_write = '1') then
                    read_ready <= '1';
                end if;
            end if;
        end if;
    end process;
    write_ready_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                write_ready <= '1';
            else
                if (write_address = read_address-1) and (valid_read = '0') and (valid_write = '1') then
                    write_ready <= '0';
                elsif (valid_read = '1') and (valid_write = '0') then
                    write_ready <= '1';
                end if;
            end if;
        end if;
    end process;
end architecture;
----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity fifo_fwft is
generic
(
    width_g     : positive   := 8;
    depth_g     : positive   := 8
);
port
(
    clock_i     : in  std_logic;
    reset_i     : in  std_logic;
    w_ready_o   : out std_logic;
    w_enable_i  : in  std_logic;
    w_data_i    : in  std_logic_vector(width_g-1 downto 0);
    r_ready_o   : out std_logic;
    r_enable_i  : in  std_logic;
    r_data_o    : out std_logic_vector(width_g-1 downto 0);
    count_o     : out std_logic_vector(depth_g downto 0)
);
end entity;
architecture rtl of fifo_fwft is
    signal fifo_read    : std_logic                         := '0';
    signal w_ready      : std_logic                         := '0';
    signal r_ready      : std_logic                         := '0';
    signal valid_write  : std_logic                         := '0';
    signal valid_read   : std_logic                         := '0';
    signal data_count   : unsigned(depth_g downto 0)        := (others => '0');
    signal valid_data   : std_logic                         := '0';
begin
    --Outputs
    w_ready_o   <= w_ready;
    r_ready_o   <= valid_data;
    count_o     <= std_logic_vector(data_count);

    --Internal
    valid_write <= w_enable_i and w_ready;
    valid_read  <= r_enable_i and valid_data;
    fifo_read_ps : process(valid_data, r_enable_i)
    begin
        if (valid_data = '0') then
            fifo_read <= '1';
        else
            fifo_read <= r_enable_i;
        end if;
    end process;
    valid_data_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                valid_data <= '0';
            else
                if (r_ready = '1') and (valid_data = '0') then
                    valid_data <= '1';
                elsif (r_ready = '0') and (r_enable_i = '1') then
                    valid_data <= '0';
                end if;
            end if;
        end if;
    end process;
    data_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (reset_i = '1') then
                data_count <= (others => '0');
            else
                if (valid_write = '1') and (valid_read = '0') then
                    data_count <= data_count + 1;
                elsif (valid_write = '0') and (valid_read = '1') then
                    data_count <= data_count - 1;
                end if;
            end if;
        end if;
    end process;
    fifo_normal_inst : entity work.fifo_normal
    generic map
    (
        width_g     => width_g,
        depth_g     => depth_g
    )
    port map
    (
        clock_i     => clock_i,
        reset_i     => reset_i,
        w_ready_o   => w_ready,
        w_enable_i  => w_enable_i,
        w_data_i    => w_data_i,
        r_ready_o   => r_ready,
        r_enable_i  => fifo_read,
        r_data_o    => r_data_o,
        count_o     => open   
    );
end architecture;
----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity fifo_ccd is
generic
(
    width_g     : positive   := 8;
    depth_g     : positive   := 8
);
port
(
    reset_i     : in  std_logic;
    w_clock_i   : in  std_logic;
    w_ready_o   : out std_logic;
    w_enable_i  : in  std_logic;
    w_data_i    : in  std_logic_vector(width_g-1 downto 0);
    w_count_o   : out std_logic_vector(depth_g downto 0);
    r_clock_i   : in  std_logic;
    r_ready_o   : out std_logic;
    r_enable_i  : in  std_logic;
    r_data_o    : out std_logic_vector(width_g-1 downto 0);
    r_count_o   : out std_logic_vector(depth_g downto 0)
);
end entity;
architecture rtl of fifo_ccd is
    --RAM buffer
    type memory is array (0 to 2**depth_g-1) of std_logic_vector(width_g-1 downto 0);
    signal ram              : memory                                := (others => (others => '0'));
    signal ram_out          : std_logic_vector(width_g-1 downto 0)  := (others => '0');

    --Read signals
    signal valid_read       : std_logic                             := '0';
    signal read_address     : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_gray        : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_gray_1     : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_gray_2     : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_address_ccd: unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_ready       : std_logic                             := '0';
    signal read_count       : unsigned(depth_g-1 downto 0)          := (others => '0');

    --Write signals
    signal valid_write      : std_logic                             := '0';
    signal write_address    : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_gray       : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_gray_1      : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_gray_2      : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal read_address_ccd : unsigned(depth_g-1 downto 0)          := (others => '0');
    signal write_ready      : std_logic                             := '1';
    signal write_count      : unsigned(depth_g-1 downto 0)          := (others => '0');

begin
    --Outputs
    w_ready_o   <= write_ready;
    w_count_o   <= "0"&std_logic_vector(write_count);
    r_ready_o   <= read_ready;
    r_data_o    <= ram_out;
    r_count_o   <= "0"&std_logic_vector(read_count);

    --Internal
    valid_read  <= r_enable_i and read_ready;
    valid_write <= w_enable_i and write_ready;
    read_address_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            read_address <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                if (valid_read = '1') then
                    read_address <= read_address+1;
                end if;
            end if;
        end if;
    end process;
    read_gray_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            read_gray <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                for i in 0 to depth_g-2 loop
                    read_gray(i) <= read_address(i) xor read_address(i+1);
                end loop;
                read_gray(depth_g-1) <= read_address(depth_g-1);
            end if;
        end if;
    end process;
    write_gray_ccd_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            write_gray_1 <= (others => '0');
            write_gray_2 <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                write_gray_1 <= write_gray;
                write_gray_2 <= write_gray_1;
            end if;
        end if;
    end process;
    write_address_ccd_ps : process(r_clock_i, reset_i)
    variable ripple_v : std_logic := '0';
    begin
        if (reset_i = '1') then
            write_address_ccd <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                ripple_v := write_gray_2(depth_g-1);
                for i in 0 to depth_g-2 loop
                    ripple_v := ripple_v xor write_gray_2(depth_g-2-i);
                    write_address_ccd(depth_g-2-i) <= ripple_v;
                end loop;
                write_address_ccd(depth_g-1) <= write_gray_2(depth_g-1);
            end if;
        end if;
    end process;
    write_address_ps : process(w_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            write_address <= (others => '0');
        else
            if rising_edge(w_clock_i) then
                if (valid_write = '1') then
                    write_address <= write_address+1;
                end if;
            end if;
        end if;
    end process;
    write_gray_ps : process(w_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            write_gray <= (others => '0');
        else
            if rising_edge(w_clock_i) then
                for i in 0 to depth_g-2 loop
                    write_gray(i) <= write_address(i) xor write_address(i+1);
                end loop;
                write_gray(depth_g-1) <= write_address(depth_g-1);
            end if;
        end if;
    end process;
    read_gray_ccd_ps : process(w_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            read_gray_1 <= (others => '0');
            read_gray_2 <= (others => '0');
        else
            if rising_edge(w_clock_i) then
                read_gray_1 <= read_gray;
                read_gray_2 <= read_gray_1;
            end if;
        end if;
    end process;
    read_address_ccd_ps : process(w_clock_i, reset_i)
    variable ripple_v : std_logic := '0';
    begin
        if (reset_i = '1') then
            read_address_ccd <= (others => '0');
        else
            if rising_edge(w_clock_i) then
                ripple_v := read_gray_2(depth_g-1);
                for i in 0 to depth_g-2 loop
                    ripple_v := ripple_v xor read_gray_2(depth_g-2-i);
                    read_address_ccd(depth_g-2-i) <= ripple_v;
                end loop;
                read_address_ccd(depth_g-1) <= read_gray_2(depth_g-1);
            end if;
        end if;
    end process;    
    ram_ps : process(w_clock_i)
    begin
        if rising_edge(w_clock_i) then
            if (valid_write = '1') then
                ram(to_integer(write_address)) <= w_data_i;
            end if;
        end if;
    end process;
    ram_out_ps : process(r_clock_i)
    begin
        if rising_edge(r_clock_i) then
            if (valid_read = '1') then
                ram_out <= ram(to_integer(read_address));
            end if;
        end if;
    end process;
    read_ready_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            read_ready <= '0';
        else
            if rising_edge(r_clock_i) then
                if (read_address = write_address_ccd-1) and (valid_read = '1') then
                    read_ready <= '0';
                elsif (read_address /= write_address_ccd) then
                    read_ready <= '1';
                end if;
            end if;
        end if;  
    end process;
    write_ready_ps : process(w_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            write_ready <= '1';
        else
            if rising_edge(w_clock_i) then
                if (write_address = read_address_ccd-2) and (valid_write = '1') then
                    write_ready <= '0';
                elsif (write_address /= read_address_ccd-1) then
                    write_ready <= '1';
                end if;
            end if;
        end if;
    end process;
    read_count_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            read_count <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                if (valid_read = '1') then
                    read_count <= write_address_ccd - read_address - 1;
                else
                    read_count <= write_address_ccd - read_address;
                end if;
            end if;
        end if;
    end process;
    write_count_ps : process(w_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            write_count <= (others => '0');
        else
            if rising_edge(w_clock_i) then
                if (valid_write = '1') then
                    write_count <= write_address - read_address_ccd + 1;
                else
                    write_count <= write_address - read_address_ccd;
                end if;
            end if;
        end if;
    end process;
end architecture;
----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity fifo_ccd_fwft is
generic
(
    width_g     : positive   := 8;
    depth_g     : positive   := 8
);
port
(
    reset_i     : in  std_logic;
    w_clock_i   : in  std_logic;
    w_ready_o   : out std_logic;
    w_enable_i  : in  std_logic;
    w_data_i    : in  std_logic_vector(width_g-1 downto 0);
    w_count_o   : out std_logic_vector(depth_g downto 0);
    r_clock_i   : in  std_logic;
    r_ready_o   : out std_logic;
    r_enable_i  : in  std_logic;
    r_data_o    : out std_logic_vector(width_g-1 downto 0);
    r_count_o   : out std_logic_vector(depth_g downto 0)
);
end entity;
architecture rtl of fifo_ccd_fwft is
    signal fifo_read    : std_logic                             := '0';
    signal r_ready      : std_logic                             := '0';
    signal valid_data   : std_logic                             := '0';
    signal r_count      : std_logic_vector(depth_g downto 0)    := (others => '0');
    signal data_count   : unsigned(depth_g downto 0)            := (others => '0');
begin
    --Outputs
    r_ready_o <= valid_data;
    r_count_o <= std_logic_vector(data_count);

    --Internals
    fifo_read_ps : process(valid_data, r_enable_i)
    begin
        if (valid_data = '0') then
            fifo_read <= '1';
        else
            fifo_read <= r_enable_i;
        end if;
    end process;
    valid_data_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            valid_data <= '0';
        else
            if rising_edge(r_clock_i) then
                if (r_ready = '1') and (valid_data = '0') then
                    valid_data <= '1';
                elsif (r_ready = '0') and (r_enable_i = '1') then
                    valid_data <= '0';
                end if;
            end if;
        end if;
    end process;
    data_count_ps : process(r_clock_i, reset_i)
    begin
        if (reset_i = '1') then
            data_count <= (others => '0');
        else
            if rising_edge(r_clock_i) then
                if (fifo_read = '1') and (r_ready = '1') then
                    data_count <= unsigned(r_count);
                elsif (valid_data = '1') and (r_enable_i = '0') then
                    data_count <= unsigned(r_count) + 1;
                elsif (valid_data = '1') and (r_enable_i = '1') then
                    data_count <= unsigned(r_count);
                end if;
            end if;
        end if;
    end process;
    fifo_ccd_inst : entity work.fifo_ccd
    generic map
    (
        width_g     => width_g,
        depth_g     => depth_g
    )
    port map
    (
        reset_i     => reset_i   ,
        w_clock_i   => w_clock_i ,
        w_ready_o   => w_ready_o ,
        w_enable_i  => w_enable_i,
        w_data_i    => w_data_i  ,
        w_count_o   => w_count_o ,
        r_clock_i   => r_clock_i ,
        r_ready_o   => r_ready ,
        r_enable_i  => fifo_read,
        r_data_o    => r_data_o  ,
        r_count_o   => r_count 
    );

end architecture;
----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity fifo_generic is
generic
(
    width_g     : positive  := 8;
    depth_g     : positive  := 12;
    fwft_g      : natural   := 0;
    ccd_g       : natural   := 0
);
port
(
    reset_i     : in  std_logic;
    w_clock_i   : in  std_logic;
    w_ready_o   : out std_logic;
    w_enable_i  : in  std_logic;
    w_data_i    : in  std_logic_vector(width_g-1 downto 0);
    w_count_o   : out std_logic_vector(depth_g downto 0);
    r_clock_i   : in  std_logic;
    r_ready_o   : out std_logic;
    r_enable_i  : in  std_logic;
    r_data_o    : out std_logic_vector(width_g-1 downto 0);
    r_count_o   : out std_logic_vector(depth_g downto 0)
);
end entity;
architecture rtl of fifo_generic is
    signal duplicate_count : std_logic_vector(depth_g downto 0);
begin
    gen_fifo_normal : if (ccd_g = 0) and (fwft_g = 0) generate
        fifo_normal_inst : entity work.fifo_normal
        generic map
        (
            width_g     => width_g,
            depth_g     => depth_g
        )
        port map
        (
            clock_i     => w_clock_i ,
            reset_i     => reset_i   ,
            w_ready_o   => w_ready_o ,
            w_enable_i  => w_enable_i,
            w_data_i    => w_data_i  ,
            r_ready_o   => r_ready_o ,
            r_enable_i  => r_enable_i,
            r_data_o    => r_data_o  ,
            count_o     => duplicate_count
        );
        w_count_o <= duplicate_count;
        r_count_o <= duplicate_count;
    end generate;
    gen_fifo_fwft : if (ccd_g = 0) and (fwft_g = 1) generate
        fifo_fwft_inst : entity work.fifo_fwft
        generic map
        (
            width_g     => width_g,
            depth_g     => depth_g
        )
        port map
        (
            clock_i     => w_clock_i ,
            reset_i     => reset_i   ,
            w_ready_o   => w_ready_o ,
            w_enable_i  => w_enable_i,
            w_data_i    => w_data_i  ,
            r_ready_o   => r_ready_o ,
            r_enable_i  => r_enable_i,
            r_data_o    => r_data_o  ,
            count_o     => duplicate_count
        );
        w_count_o <= duplicate_count;
        r_count_o <= duplicate_count;
    end generate;
    gen_fifo_ccd : if (ccd_g = 1) and (fwft_g = 0) generate
        fifo_ccd_inst : entity work.fifo_ccd
        generic map
        (
            width_g     => width_g,
            depth_g     => depth_g
        )
        port map
        (
            reset_i     => reset_i   ,
            w_clock_i   => w_clock_i ,
            w_ready_o   => w_ready_o ,
            w_enable_i  => w_enable_i,
            w_data_i    => w_data_i  ,
            w_count_o   => w_count_o ,
            r_clock_i   => r_clock_i ,
            r_ready_o   => r_ready_o ,
            r_enable_i  => r_enable_i,
            r_data_o    => r_data_o  ,
            r_count_o   => r_count_o 
        );
    end generate;
    gen_fifo_ccd_fwft : if (ccd_g = 1) and (fwft_g = 1) generate
        fifo_ccd_fwft_inst : entity work.fifo_ccd_fwft
        generic map
        (
            width_g     => width_g,
            depth_g     => depth_g
        )
        port map
        (
            reset_i     => reset_i   ,
            w_clock_i   => w_clock_i ,
            w_ready_o   => w_ready_o ,
            w_enable_i  => w_enable_i,
            w_data_i    => w_data_i  ,
            w_count_o   => w_count_o ,
            r_clock_i   => r_clock_i ,
            r_ready_o   => r_ready_o ,
            r_enable_i  => r_enable_i,
            r_data_o    => r_data_o  ,
            r_count_o   => r_count_o 
        );
    end generate;
end architecture;