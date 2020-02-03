library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.inst_pack.all;

entity soc is
    generic
    (
        uart_cycles_g : positive := 10
    );
    port
    (
        clock_i   : in  std_logic;
        uart_rx_i : in  std_logic;
        uart_tx_o : out std_logic;
        gpio_i    : in  std_logic_vector(31 downto 0);
        gpio_o    : out std_logic_vector(31 downto 0);
        vga_r_o   : out std_logic_vector(4 downto 0);
        vga_g_o   : out std_logic_vector(5 downto 0);
        vga_b_o   : out std_logic_vector(4 downto 0);
        vga_hs_o  : out std_logic;
        vga_vs_o  : out std_logic
    );
end entity;

architecture rtl of soc is

    signal reset_i : std_logic := '0';

    signal core_mem_read_valid_i  : std_logic;
    signal core_mem_write_valid_i : std_logic;
    signal core_mem_addr_i        : std_logic_vector(31 downto 0);
    signal core_mem_data_i        : std_logic_vector(31 downto 0);
    signal core_mem_read_o        : std_logic;
    signal core_mem_write_o       : std_logic;
    signal core_mem_mask_o        : std_logic_vector(3 downto 0);
    signal core_mem_addr_o        : std_logic_vector(31 downto 0);
    signal core_mem_data_o        : std_logic_vector(31 downto 0);

    signal mc_host_read_i        : std_logic;
    signal mc_host_write_i       : std_logic;
    signal mc_host_mask_i        : std_logic_vector(3 downto 0);
    signal mc_host_addr_i        : std_logic_vector(31 downto 0);
    signal mc_host_data_i        : std_logic_vector(31 downto 0);
    signal mc_host_read_valid_o  : std_logic;
    signal mc_host_write_valid_o : std_logic;
    signal mc_host_addr_o        : std_logic_vector(31 downto 0);
    signal mc_host_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev0_read_o        : std_logic;
    signal mc_dev0_write_o       : std_logic;
    signal mc_dev0_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev0_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev0_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev0_read_valid_i  : std_logic;
    signal mc_dev0_write_valid_i : std_logic;
    signal mc_dev0_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev1_read_o        : std_logic;
    signal mc_dev1_write_o       : std_logic;
    signal mc_dev1_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev1_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev1_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev1_read_valid_i  : std_logic;
    signal mc_dev1_write_valid_i : std_logic;
    signal mc_dev1_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev2_read_o        : std_logic;
    signal mc_dev2_write_o       : std_logic;
    signal mc_dev2_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev2_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev2_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev2_read_valid_i  : std_logic;
    signal mc_dev2_write_valid_i : std_logic;
    signal mc_dev2_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev3_read_o        : std_logic;
    signal mc_dev3_write_o       : std_logic;
    signal mc_dev3_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev3_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev3_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev3_read_valid_i  : std_logic;
    signal mc_dev3_write_valid_i : std_logic;
    signal mc_dev3_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev4_read_o        : std_logic;
    signal mc_dev4_write_o       : std_logic;
    signal mc_dev4_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev4_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev4_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev4_read_valid_i  : std_logic;
    signal mc_dev4_write_valid_i : std_logic;
    signal mc_dev4_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev5_read_o        : std_logic;
    signal mc_dev5_write_o       : std_logic;
    signal mc_dev5_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev5_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev5_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev5_read_valid_i  : std_logic;
    signal mc_dev5_write_valid_i : std_logic;
    signal mc_dev5_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev6_read_o        : std_logic;
    signal mc_dev6_write_o       : std_logic;
    signal mc_dev6_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev6_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev6_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev6_read_valid_i  : std_logic;
    signal mc_dev6_write_valid_i : std_logic;
    signal mc_dev6_data_i        : std_logic_vector(31 downto 0);
    signal mc_dev7_read_o        : std_logic;
    signal mc_dev7_write_o       : std_logic;
    signal mc_dev7_mask_o        : std_logic_vector(3 downto 0);
    signal mc_dev7_addr_o        : std_logic_vector(31 downto 0);
    signal mc_dev7_data_o        : std_logic_vector(31 downto 0);
    signal mc_dev7_read_valid_i  : std_logic;
    signal mc_dev7_write_valid_i : std_logic;
    signal mc_dev7_data_i        : std_logic_vector(31 downto 0);


    signal inst_read_i        : std_logic;
    signal inst_write_i       : std_logic;
    signal inst_mask_i        : std_logic_vector(3 downto 0);
    signal inst_addr_i        : std_logic_vector(31 downto 0);
    signal inst_data_i        : std_logic_vector(31 downto 0);
    signal inst_read_valid_o  : std_logic;
    signal inst_write_valid_o : std_logic;
    signal inst_data_o        : std_logic_vector(31 downto 0);

    signal stack_read_i        : std_logic;
    signal stack_write_i       : std_logic;
    signal stack_mask_i        : std_logic_vector(3 downto 0);
    signal stack_addr_i        : std_logic_vector(31 downto 0);
    signal stack_data_i        : std_logic_vector(31 downto 0);
    signal stack_read_valid_o  : std_logic;
    signal stack_write_valid_o : std_logic;
    signal stack_data_o        : std_logic_vector(31 downto 0);

    signal timer_read_i        : std_logic;
    signal timer_write_i       : std_logic;
    signal timer_mask_i        : std_logic_vector(3 downto 0);
    signal timer_addr_i        : std_logic_vector(31 downto 0);
    signal timer_data_i        : std_logic_vector(31 downto 0);
    signal timer_read_valid_o  : std_logic;
    signal timer_write_valid_o : std_logic;
    signal timer_data_o        : std_logic_vector(31 downto 0);

    signal uart_read_i        : std_logic;
    signal uart_write_i       : std_logic;
    signal uart_mask_i        : std_logic_vector(3 downto 0);
    signal uart_addr_i        : std_logic_vector(31 downto 0);
    signal uart_data_i        : std_logic_vector(31 downto 0);
    signal uart_read_valid_o  : std_logic;
    signal uart_write_valid_o : std_logic;
    signal uart_data_o        : std_logic_vector(31 downto 0);

    signal io_read_i        : std_logic;
    signal io_write_i       : std_logic;
    signal io_mask_i        : std_logic_vector(3 downto 0);
    signal io_addr_i        : std_logic_vector(31 downto 0);
    signal io_data_i        : std_logic_vector(31 downto 0);
    signal io_read_valid_o  : std_logic;
    signal io_write_valid_o : std_logic;
    signal io_data_o        : std_logic_vector(31 downto 0);
    signal io_gpio_data_i   : std_logic_vector(31 downto 0);
    signal io_gpio_data_o   : std_logic_vector(31 downto 0);

    signal vga_read_i        : std_logic;
    signal vga_write_i       : std_logic;
    signal vga_mask_i        : std_logic_vector(3 downto 0);
    signal vga_addr_i        : std_logic_vector(31 downto 0);
    signal vga_data_i        : std_logic_vector(31 downto 0);
    signal vga_read_valid_o  : std_logic;
    signal vga_write_valid_o : std_logic;
    signal vga_data_o        : std_logic_vector(31 downto 0);

begin

    --Entity outputs
    gpio_o <= io_gpio_data_o;

    --Instances
    core_1 : entity work.core
        port map (
            clock_i           => clock_i,
            reset_i           => reset_i,
            mem_read_valid_i  => core_mem_read_valid_i,
            mem_write_valid_i => core_mem_write_valid_i,
            mem_addr_i        => core_mem_addr_i,
            mem_data_i        => core_mem_data_i,
            mem_read_o        => core_mem_read_o,
            mem_write_o       => core_mem_write_o,
            mem_mask_o        => core_mem_mask_o,
            mem_addr_o        => core_mem_addr_o,
            mem_data_o        => core_mem_data_o
        );
    memory_controller_1 : entity work.memory_controller
        generic map (
            dev0_lo => x"00000000", --Inst
            dev0_hi => x"00000FFF",
            dev1_lo => x"FFFFE000", --Stack
            dev1_hi => x"FFFFFFFF",
            dev2_lo => x"00001000", --Timer
            dev2_hi => x"00001000",
            dev3_lo => x"00002000", --UART
            dev3_hi => x"00002008",
            dev4_lo => x"00003000", --GPIO
            dev4_hi => x"00003000",
            dev5_lo => x"00004000", --VGA
            dev5_hi => x"00008000",
            dev6_lo => x"00000000",
            dev6_hi => x"00000000",
            dev7_lo => x"00000000",
            dev7_hi => x"00000000"
        )
        port map (
            clock_i            => clock_i,
            reset_i            => reset_i,
            host_read_i        => mc_host_read_i,
            host_write_i       => mc_host_write_i,
            host_mask_i        => mc_host_mask_i,
            host_addr_i        => mc_host_addr_i,
            host_data_i        => mc_host_data_i,
            host_read_valid_o  => mc_host_read_valid_o,
            host_write_valid_o => mc_host_write_valid_o,
            host_addr_o        => mc_host_addr_o,
            host_data_o        => mc_host_data_o,
            dev0_read_o        => mc_dev0_read_o,
            dev0_write_o       => mc_dev0_write_o,
            dev0_mask_o        => mc_dev0_mask_o,
            dev0_addr_o        => mc_dev0_addr_o,
            dev0_data_o        => mc_dev0_data_o,
            dev0_read_valid_i  => mc_dev0_read_valid_i,
            dev0_write_valid_i => mc_dev0_write_valid_i,
            dev0_data_i        => mc_dev0_data_i,
            dev1_read_o        => mc_dev1_read_o,
            dev1_write_o       => mc_dev1_write_o,
            dev1_mask_o        => mc_dev1_mask_o,
            dev1_addr_o        => mc_dev1_addr_o,
            dev1_data_o        => mc_dev1_data_o,
            dev1_read_valid_i  => mc_dev1_read_valid_i,
            dev1_write_valid_i => mc_dev1_write_valid_i,
            dev1_data_i        => mc_dev1_data_i,
            dev2_read_o        => mc_dev2_read_o,
            dev2_write_o       => mc_dev2_write_o,
            dev2_mask_o        => mc_dev2_mask_o,
            dev2_addr_o        => mc_dev2_addr_o,
            dev2_data_o        => mc_dev2_data_o,
            dev2_read_valid_i  => mc_dev2_read_valid_i,
            dev2_write_valid_i => mc_dev2_write_valid_i,
            dev2_data_i        => mc_dev2_data_i,
            dev3_read_o        => mc_dev3_read_o,
            dev3_write_o       => mc_dev3_write_o,
            dev3_mask_o        => mc_dev3_mask_o,
            dev3_addr_o        => mc_dev3_addr_o,
            dev3_data_o        => mc_dev3_data_o,
            dev3_read_valid_i  => mc_dev3_read_valid_i,
            dev3_write_valid_i => mc_dev3_write_valid_i,
            dev3_data_i        => mc_dev3_data_i,
            dev4_read_o        => mc_dev4_read_o,
            dev4_write_o       => mc_dev4_write_o,
            dev4_mask_o        => mc_dev4_mask_o,
            dev4_addr_o        => mc_dev4_addr_o,
            dev4_data_o        => mc_dev4_data_o,
            dev4_read_valid_i  => mc_dev4_read_valid_i,
            dev4_write_valid_i => mc_dev4_write_valid_i,
            dev4_data_i        => mc_dev4_data_i,
            dev5_read_o        => mc_dev5_read_o,
            dev5_write_o       => mc_dev5_write_o,
            dev5_mask_o        => mc_dev5_mask_o,
            dev5_addr_o        => mc_dev5_addr_o,
            dev5_data_o        => mc_dev5_data_o,
            dev5_read_valid_i  => mc_dev5_read_valid_i,
            dev5_write_valid_i => mc_dev5_write_valid_i,
            dev5_data_i        => mc_dev5_data_i,
            dev6_read_o        => mc_dev6_read_o,
            dev6_write_o       => mc_dev6_write_o,
            dev6_mask_o        => mc_dev6_mask_o,
            dev6_addr_o        => mc_dev6_addr_o,
            dev6_data_o        => mc_dev6_data_o,
            dev6_read_valid_i  => mc_dev6_read_valid_i,
            dev6_write_valid_i => mc_dev6_write_valid_i,
            dev6_data_i        => mc_dev6_data_i,
            dev7_read_o        => mc_dev7_read_o,
            dev7_write_o       => mc_dev7_write_o,
            dev7_mask_o        => mc_dev7_mask_o,
            dev7_addr_o        => mc_dev7_addr_o,
            dev7_data_o        => mc_dev7_data_o,
            dev7_read_valid_i  => mc_dev7_read_valid_i,
            dev7_write_valid_i => mc_dev7_write_valid_i,
            dev7_data_i        => mc_dev7_data_i
        );
    inst_ram : entity work.ram
        generic map (
            ram_depth_g  => memory_depth,
            ram_byte_0_g => memory_byte_0,
            ram_byte_1_g => memory_byte_1,
            ram_byte_2_g => memory_byte_2,
            ram_byte_3_g => memory_byte_3
        )
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => inst_read_i,
            write_i       => inst_write_i,
            mask_i        => inst_mask_i,
            addr_i        => inst_addr_i,
            data_i        => inst_data_i,
            read_valid_o  => inst_read_valid_o,
            write_valid_o => inst_write_valid_o,
            data_o        => inst_data_o
        );
    stack_ram : entity work.ram
        generic map (
            ram_depth_g  => 10,
            ram_byte_0_g => (others => (others => '0')),
            ram_byte_1_g => (others => (others => '0')),
            ram_byte_2_g => (others => (others => '0')),
            ram_byte_3_g => (others => (others => '0'))
        )
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => stack_read_i,
            write_i       => stack_write_i,
            mask_i        => stack_mask_i,
            addr_i        => stack_addr_i,
            data_i        => stack_data_i,
            read_valid_o  => stack_read_valid_o,
            write_valid_o => stack_write_valid_o,
            data_o        => stack_data_o
        );
    timer_map_1 : entity work.timer_map
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => timer_read_i,
            write_i       => timer_write_i,
            mask_i        => timer_mask_i,
            addr_i        => timer_addr_i,
            data_i        => timer_data_i,
            read_valid_o  => timer_read_valid_o,
            write_valid_o => timer_write_valid_o,
            data_o        => timer_data_o
        );
    uart_map_1 : entity work.uart_map
        generic map (
            cycles_g => uart_cycles_g,
            depth_g  => 12
        )
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => uart_read_i,
            write_i       => uart_write_i,
            mask_i        => uart_mask_i,
            addr_i        => uart_addr_i,
            data_i        => uart_data_i,
            read_valid_o  => uart_read_valid_o,
            write_valid_o => uart_write_valid_o,
            data_o        => uart_data_o,
            rx_i          => uart_rx_i,
            tx_o          => uart_tx_o
        );
    io_map_1 : entity work.io_map
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => io_read_i,
            write_i       => io_write_i,
            mask_i        => io_mask_i,
            addr_i        => io_addr_i,
            data_i        => io_data_i,
            read_valid_o  => io_read_valid_o,
            write_valid_o => io_write_valid_o,
            data_o        => io_data_o,
            gpio_data_i   => io_gpio_data_i,
            gpio_data_o   => io_gpio_data_o
        );
    vga_map_1 : entity work.vga_map
        port map (
            clock_i       => clock_i,
            reset_i       => reset_i,
            read_i        => vga_read_i,
            write_i       => vga_write_i,
            mask_i        => vga_mask_i,
            addr_i        => vga_addr_i,
            data_i        => vga_data_i,
            read_valid_o  => vga_read_valid_o,
            write_valid_o => vga_write_valid_o,
            data_o        => vga_data_o,
            vga_r_o       => vga_r_o,
            vga_g_o       => vga_g_o,
            vga_b_o       => vga_b_o,
            vga_hs_o      => vga_hs_o,
            vga_vs_o      => vga_vs_o
        );


    --Core inputs
    core_mem_read_valid_i  <= mc_host_read_valid_o;
    core_mem_write_valid_i <= mc_host_write_valid_o;
    core_mem_addr_i        <= mc_host_addr_o;
    core_mem_data_i        <= mc_host_data_o;

    --Memory controller inputs
    mc_host_read_i        <= core_mem_read_o;
    mc_host_write_i       <= core_mem_write_o;
    mc_host_mask_i        <= core_mem_mask_o;
    mc_host_addr_i        <= core_mem_addr_o;
    mc_host_data_i        <= core_mem_data_o;
    mc_dev0_read_valid_i  <= inst_read_valid_o;
    mc_dev0_write_valid_i <= inst_write_valid_o;
    mc_dev0_data_i        <= inst_data_o;
    mc_dev1_read_valid_i  <= stack_read_valid_o;
    mc_dev1_write_valid_i <= stack_write_valid_o;
    mc_dev1_data_i        <= stack_data_o;
    mc_dev2_read_valid_i  <= timer_read_valid_o;
    mc_dev2_write_valid_i <= timer_write_valid_o;
    mc_dev2_data_i        <= timer_data_o;
    mc_dev3_read_valid_i  <= uart_read_valid_o;
    mc_dev3_write_valid_i <= uart_write_valid_o;
    mc_dev3_data_i        <= uart_data_o;
    mc_dev4_read_valid_i  <= io_read_valid_o;
    mc_dev4_write_valid_i <= io_write_valid_o;
    mc_dev4_data_i        <= io_data_o;
    mc_dev5_read_valid_i  <= vga_read_valid_o;
    mc_dev5_write_valid_i <= vga_write_valid_o;
    mc_dev5_data_i        <= vga_data_o;
    mc_dev6_read_valid_i  <= '0';
    mc_dev6_write_valid_i <= '0';
    mc_dev6_data_i        <= (others => '0');
    mc_dev7_read_valid_i  <= '0';
    mc_dev7_write_valid_i <= '0';
    mc_dev7_data_i        <= (others => '0');

    --Inst ram inputs
    inst_read_i  <= mc_dev0_read_o;
    inst_write_i <= mc_dev0_write_o;
    inst_mask_i  <= mc_dev0_mask_o;
    inst_addr_i  <= mc_dev0_addr_o;
    inst_data_i  <= mc_dev0_data_o;

    --Stack ram inputs
    stack_read_i  <= mc_dev1_read_o;
    stack_write_i <= mc_dev1_write_o;
    stack_mask_i  <= mc_dev1_mask_o;
    stack_addr_i  <= mc_dev1_addr_o;
    stack_data_i  <= mc_dev1_data_o;

    --Timer inputs
    timer_read_i  <= mc_dev2_read_o;
    timer_write_i <= mc_dev2_write_o;
    timer_mask_i  <= mc_dev2_mask_o;
    timer_addr_i  <= mc_dev2_addr_o;
    timer_data_i  <= mc_dev2_data_o;

    --Uart inputs
    uart_read_i  <= mc_dev3_read_o;
    uart_write_i <= mc_dev3_write_o;
    uart_mask_i  <= mc_dev3_mask_o;
    uart_addr_i  <= mc_dev3_addr_o;
    uart_data_i  <= mc_dev3_data_o;

    --IO inputs
    io_read_i      <= mc_dev4_read_o;
    io_write_i     <= mc_dev4_write_o;
    io_mask_i      <= mc_dev4_mask_o;
    io_addr_i      <= mc_dev4_addr_o;
    io_data_i      <= mc_dev4_data_o;
    io_gpio_data_i <= gpio_i;

    --VGA inputs
    vga_read_i  <= mc_dev5_read_o;
    vga_write_i <= mc_dev5_write_o;
    vga_mask_i  <= mc_dev5_mask_o;
    vga_addr_i  <= mc_dev5_addr_o;
    vga_data_i  <= mc_dev5_data_o;

    --Device 6 inputs

    --Device 7 inputs


end architecture rtl;