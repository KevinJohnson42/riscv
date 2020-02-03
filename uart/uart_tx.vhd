library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bit_width.all;

entity uart_tx is
    generic
    (
        cycles_g : positive := 10
    );
    port
    (
        clock_i  : in  std_logic;
        enable_i : in  std_logic;
        data_i   : in  std_logic_vector(7 downto 0);
        ready_o  : out std_logic;
        tx_o     : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is

    signal cycle_count : unsigned(bitwidth(cycles_g)-1 downto 0) := (others => '0');
    signal tx_enable   : std_logic                               := '0';
    signal data_count  : unsigned(3 downto 0)                    := (others => '0');
    signal stop_bit    : std_logic                               := '0';
    signal run         : std_logic                               := '0';
    signal data_reg    : std_logic_vector(9 downto 0)            := (others => '1');
    signal ready       : std_logic                               := '0';
    signal tx_bit      : std_logic                               := '1';

begin
    ready_o <= ready;
    tx_o    <= tx_bit;


    cycle_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (cycle_count = cycles_g-1) then
                cycle_count <= (others => '0');
            else
                cycle_count <= cycle_count + 1;
            end if;
        end if;
    end process;
    tx_enable_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (cycle_count = cycles_g-1) then
                tx_enable <= '1';
            else
                tx_enable <= '0';
            end if;
        end if;
    end process;
    tx_bit_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (tx_enable = '1') then
                tx_bit <= data_reg(0);
            end if;
        end if;
    end process;
    data_reg_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (enable_i = '1') and (ready = '1') then
                data_reg <= '1' & data_i & '0';
            elsif (tx_enable = '1') then
                data_reg <= '1' & data_reg(9 downto 1);
            end if;
        end if;
    end process;
    run_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (enable_i = '1') and (ready = '1') then
                run <= '1';
            elsif (stop_bit = '1') and (tx_enable = '1') then
                run <= '0';
            end if;
        end if;
    end process;
    stop_bit_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (stop_bit = '1') and (tx_enable = '1') then
                stop_bit <= '0';
            elsif (tx_enable = '1') and (data_count(3) = '1') then
                stop_bit <= '1';
            end if;
        end if;
    end process;
    data_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (tx_enable = '1') and (stop_bit = '1') then
                data_count <= (others => '0');
            elsif (run = '1') and (tx_enable = '1') then
                data_count <= data_count + 1;
            end if;
        end if;
    end process;
    ready_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (enable_i = '1') and (ready = '1') then
                ready <= '0';
            elsif (stop_bit = '1') and (tx_enable = '1') then
                ready <= '1';
            elsif (run = '0') then
                ready <= '1';
            end if;
        end if;
    end process;
end architecture rtl;