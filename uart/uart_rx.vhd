library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.bit_width.all;

entity uart_rx is
    generic
    (
        cycles_g : positive := 10
    );
    port
    (
        clock_i  : in  std_logic;
        rx_i     : in  std_logic;
        enable_o : out std_logic;
        data_o   : out std_logic_vector(7 downto 0)
    );
end entity uart_rx;

architecture rtl of uart_rx is



    signal cdr_valid  : std_logic                    := '0';
    signal cdr_data   : std_logic                    := '0';
    signal cdr_data_1 : std_logic                    := '0';
    signal data_fall  : std_logic                    := '0';
    signal run        : std_logic                    := '0';
    signal data_count : unsigned(3 downto 0)         := (others => '0');
    signal data_reg   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_valid : std_logic                    := '0';


begin

    enable_o <= data_valid;
    data_o   <= data_reg;

    cdr_inst : entity work.cdr
        generic map
        (
            samples_g => cycles_g
        )
        port map
        (
            clock_i => clock_i,
            data_i  => rx_i,
            valid_o => cdr_valid,
            data_o  => cdr_data
        );


    cdr_data_1_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (cdr_valid = '1') then
                cdr_data_1 <= cdr_data;
            end if;
        end if;
    end process;

    data_fall <= '1' when (cdr_data_1 = '1') and (cdr_data = '0') else '0';

    run_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (data_fall = '1') and (cdr_valid = '1') then
                run <= '1';
            elsif (data_count(3) = '1') and (cdr_valid = '1') then
                run <= '0';
            end if;
        end if;
    end process;
    data_reg_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (run = '1') and (data_count(3) = '0') and (cdr_valid = '1') then
                data_reg <= cdr_data & data_reg(7 downto 1);
            end if;
        end if;
    end process;
    data_count_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (data_count(3) = '1') and (cdr_valid = '1') then
                data_count <= (others => '0');
            elsif (run = '1') and (cdr_valid = '1') then
                data_count <= data_count + 1;
            end if;
        end if;
    end process;
    data_valid_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (data_count(3) = '1') and (cdr_data = '1') and (cdr_valid = '1') then
                data_valid <= '1';
            else
                data_valid <= '0';
            end if;
        end if;
    end process;


end architecture rtl;