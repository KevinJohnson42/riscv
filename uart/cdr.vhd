library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bit_width.all;
entity cdr is
    generic
    (
        samples_g : positive := 3 --3 or greater
    );
    port
    (
        clock_i : in  std_logic;
        data_i  : in  std_logic;
        valid_o : out std_logic;
        data_o  : out std_logic
    );
end cdr;
architecture rtl of cdr is
    constant half_c : positive                    := samples_g/2;
    constant last_c : positive                    := samples_g+half_c-1;
    constant bits_c : positive                    := bitwidth(last_c+1); --Counter bits
    signal d1       : std_logic                   := '0';                --Pack in IOB
    signal d2       : std_logic                   := '0';                --Stable flop
    signal d3       : std_logic                   := '0';                --Old data
    signal delta    : std_logic                   := '0';                --The bit line changed
    signal infer    : std_logic                   := '0';                --Infer the bit
    signal counter  : unsigned(bits_c-1 downto 0) := (others => '0');    --Cycle counter
    signal data     : std_logic                   := '0';                --Data out
    signal valid    : std_logic                   := '0';                --Valid out
begin
    data_o  <= data;
    valid_o <= valid;
    delta   <= d3 xor d2;
    infer   <= '1' when (counter = last_c) else '0';
    rx_flops_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            d1 <= data_i;
            d2 <= d1;
            d3 <= d2;
        end if;
    end process;
    counter_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (delta = '1') then
                counter <= (others => '0');
            elsif (infer = '1') then
                counter <= to_unsigned(half_c,bits_c);
            else
                counter <= counter+1;
            end if;
        end if;
    end process;
    data_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (delta = '1') then
                data <= d2;
            else
                data <= d3;
            end if;
        end if;
    end process;
    valid_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (delta = '1') then
                valid <= '1';
            elsif (infer = '1') then
                valid <= '1';
            else
                valid <= '0';
            end if;
        end if;
    end process;
end architecture;