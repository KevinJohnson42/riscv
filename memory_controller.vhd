library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_controller is
    generic
    (
        dev0_lo : unsigned(31 downto 0) := x"00000000";
        dev0_hi : unsigned(31 downto 0) := x"00000000";
        dev1_lo : unsigned(31 downto 0) := x"00000000";
        dev1_hi : unsigned(31 downto 0) := x"00000000";
        dev2_lo : unsigned(31 downto 0) := x"00000000";
        dev2_hi : unsigned(31 downto 0) := x"00000000";
        dev3_lo : unsigned(31 downto 0) := x"00000000";
        dev3_hi : unsigned(31 downto 0) := x"00000000";
        dev4_lo : unsigned(31 downto 0) := x"00000000";
        dev4_hi : unsigned(31 downto 0) := x"00000000";
        dev5_lo : unsigned(31 downto 0) := x"00000000";
        dev5_hi : unsigned(31 downto 0) := x"00000000";
        dev6_lo : unsigned(31 downto 0) := x"00000000";
        dev6_hi : unsigned(31 downto 0) := x"00000000";
        dev7_lo : unsigned(31 downto 0) := x"00000000";
        dev7_hi : unsigned(31 downto 0) := x"00000000"
    );
    port
    (
        clock_i            : in  std_logic;
        reset_i            : in  std_logic;
        host_read_i        : in  std_logic;
        host_write_i       : in  std_logic;
        host_mask_i        : in  std_logic_vector(3 downto 0);
        host_addr_i        : in  std_logic_vector(31 downto 0);
        host_data_i        : in  std_logic_vector(31 downto 0);
        host_read_valid_o  : out std_logic;
        host_write_valid_o : out std_logic;
        host_addr_o        : out std_logic_vector(31 downto 0);
        host_data_o        : out std_logic_vector(31 downto 0);
        dev0_read_o        : out std_logic;
        dev0_write_o       : out std_logic;
        dev0_mask_o        : out std_logic_vector(3 downto 0);
        dev0_addr_o        : out std_logic_vector(31 downto 0);
        dev0_data_o        : out std_logic_vector(31 downto 0);
        dev0_read_valid_i  : in  std_logic;
        dev0_write_valid_i : in  std_logic;
        dev0_data_i        : in  std_logic_vector(31 downto 0);
        dev1_read_o        : out std_logic;
        dev1_write_o       : out std_logic;
        dev1_mask_o        : out std_logic_vector(3 downto 0);
        dev1_addr_o        : out std_logic_vector(31 downto 0);
        dev1_data_o        : out std_logic_vector(31 downto 0);
        dev1_read_valid_i  : in  std_logic;
        dev1_write_valid_i : in  std_logic;
        dev1_data_i        : in  std_logic_vector(31 downto 0);
        dev2_read_o        : out std_logic;
        dev2_write_o       : out std_logic;
        dev2_mask_o        : out std_logic_vector(3 downto 0);
        dev2_addr_o        : out std_logic_vector(31 downto 0);
        dev2_data_o        : out std_logic_vector(31 downto 0);
        dev2_read_valid_i  : in  std_logic;
        dev2_write_valid_i : in  std_logic;
        dev2_data_i        : in  std_logic_vector(31 downto 0);
        dev3_read_o        : out std_logic;
        dev3_write_o       : out std_logic;
        dev3_mask_o        : out std_logic_vector(3 downto 0);
        dev3_addr_o        : out std_logic_vector(31 downto 0);
        dev3_data_o        : out std_logic_vector(31 downto 0);
        dev3_read_valid_i  : in  std_logic;
        dev3_write_valid_i : in  std_logic;
        dev3_data_i        : in  std_logic_vector(31 downto 0);
        dev4_read_o        : out std_logic;
        dev4_write_o       : out std_logic;
        dev4_mask_o        : out std_logic_vector(3 downto 0);
        dev4_addr_o        : out std_logic_vector(31 downto 0);
        dev4_data_o        : out std_logic_vector(31 downto 0);
        dev4_read_valid_i  : in  std_logic;
        dev4_write_valid_i : in  std_logic;
        dev4_data_i        : in  std_logic_vector(31 downto 0);
        dev5_read_o        : out std_logic;
        dev5_write_o       : out std_logic;
        dev5_mask_o        : out std_logic_vector(3 downto 0);
        dev5_addr_o        : out std_logic_vector(31 downto 0);
        dev5_data_o        : out std_logic_vector(31 downto 0);
        dev5_read_valid_i  : in  std_logic;
        dev5_write_valid_i : in  std_logic;
        dev5_data_i        : in  std_logic_vector(31 downto 0);
        dev6_read_o        : out std_logic;
        dev6_write_o       : out std_logic;
        dev6_mask_o        : out std_logic_vector(3 downto 0);
        dev6_addr_o        : out std_logic_vector(31 downto 0);
        dev6_data_o        : out std_logic_vector(31 downto 0);
        dev6_read_valid_i  : in  std_logic;
        dev6_write_valid_i : in  std_logic;
        dev6_data_i        : in  std_logic_vector(31 downto 0);
        dev7_read_o        : out std_logic;
        dev7_write_o       : out std_logic;
        dev7_mask_o        : out std_logic_vector(3 downto 0);
        dev7_addr_o        : out std_logic_vector(31 downto 0);
        dev7_data_o        : out std_logic_vector(31 downto 0);
        dev7_read_valid_i  : in  std_logic;
        dev7_write_valid_i : in  std_logic;
        dev7_data_i        : in  std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of memory_controller is

    signal host_read_valid  : std_logic                     := '0';
    signal host_write_valid : std_logic                     := '0';
    signal host_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal host_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev0_read        : std_logic                     := '0';
    signal dev0_write       : std_logic                     := '0';
    signal dev0_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev0_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev0_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev1_read        : std_logic                     := '0';
    signal dev1_write       : std_logic                     := '0';
    signal dev1_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev1_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev1_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev2_read        : std_logic                     := '0';
    signal dev2_write       : std_logic                     := '0';
    signal dev2_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev2_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev2_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev3_read        : std_logic                     := '0';
    signal dev3_write       : std_logic                     := '0';
    signal dev3_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev3_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev3_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev4_read        : std_logic                     := '0';
    signal dev4_write       : std_logic                     := '0';
    signal dev4_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev4_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev4_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev5_read        : std_logic                     := '0';
    signal dev5_write       : std_logic                     := '0';
    signal dev5_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev5_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev5_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev6_read        : std_logic                     := '0';
    signal dev6_write       : std_logic                     := '0';
    signal dev6_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev6_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev6_data        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev7_read        : std_logic                     := '0';
    signal dev7_write       : std_logic                     := '0';
    signal dev7_mask        : std_logic_vector(3 downto 0)  := (others => '0');
    signal dev7_addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal dev7_data        : std_logic_vector(31 downto 0) := (others => '0');


begin

    host_read_valid_o  <= host_read_valid;
    host_write_valid_o <= host_write_valid;
    host_addr_o        <= host_addr;
    host_data_o        <= host_data;
    dev0_read_o        <= dev0_read;
    dev0_write_o       <= dev0_write;
    dev0_mask_o        <= dev0_mask;
    dev0_addr_o        <= dev0_addr;
    dev0_data_o        <= dev0_data;
    dev1_read_o        <= dev1_read;
    dev1_write_o       <= dev1_write;
    dev1_mask_o        <= dev1_mask;
    dev1_addr_o        <= dev1_addr;
    dev1_data_o        <= dev1_data;
    dev2_read_o        <= dev2_read;
    dev2_write_o       <= dev2_write;
    dev2_mask_o        <= dev2_mask;
    dev2_addr_o        <= dev2_addr;
    dev2_data_o        <= dev2_data;
    dev3_read_o        <= dev3_read;
    dev3_write_o       <= dev3_write;
    dev3_mask_o        <= dev3_mask;
    dev3_addr_o        <= dev3_addr;
    dev3_data_o        <= dev3_data;
    dev4_read_o        <= dev4_read;
    dev4_write_o       <= dev4_write;
    dev4_mask_o        <= dev4_mask;
    dev4_addr_o        <= dev4_addr;
    dev4_data_o        <= dev4_data;
    dev5_read_o        <= dev5_read;
    dev5_write_o       <= dev5_write;
    dev5_mask_o        <= dev5_mask;
    dev5_addr_o        <= dev5_addr;
    dev5_data_o        <= dev5_data;
    dev6_read_o        <= dev6_read;
    dev6_write_o       <= dev6_write;
    dev6_mask_o        <= dev6_mask;
    dev6_addr_o        <= dev6_addr;
    dev6_data_o        <= dev6_data;
    dev7_read_o        <= dev7_read;
    dev7_write_o       <= dev7_write;
    dev7_mask_o        <= dev7_mask;
    dev7_addr_o        <= dev7_addr;
    dev7_data_o        <= dev7_data;

    host_addr_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            host_addr <= host_addr_i;
        end if;
    end process;

    select_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (unsigned(host_addr_i) >= dev0_lo) and (unsigned(host_addr_i) <= dev0_hi) then
                dev0_read        <= host_read_i;
                dev0_write       <= host_write_i;
                dev0_mask        <= host_mask_i;
                dev0_addr        <= host_addr_i;
                dev0_data        <= host_data_i;
                host_read_valid  <= dev0_read_valid_i;
                host_write_valid <= dev0_write_valid_i;
                host_data        <= dev0_data_i;
            elsif (unsigned(host_addr_i) >= dev1_lo) and (unsigned(host_addr_i) <= dev1_hi) then
                dev1_read        <= host_read_i;
                dev1_write       <= host_write_i;
                dev1_mask        <= host_mask_i;
                dev1_addr        <= host_addr_i;
                dev1_data        <= host_data_i;
                host_read_valid  <= dev1_read_valid_i;
                host_write_valid <= dev1_write_valid_i;
                host_data        <= dev1_data_i;
            elsif (unsigned(host_addr_i) >= dev2_lo) and (unsigned(host_addr_i) <= dev2_hi) then
                dev2_read        <= host_read_i;
                dev2_write       <= host_write_i;
                dev2_mask        <= host_mask_i;
                dev2_addr        <= host_addr_i;
                dev2_data        <= host_data_i;
                host_read_valid  <= dev2_read_valid_i;
                host_write_valid <= dev2_write_valid_i;
                host_data        <= dev2_data_i;
            elsif (unsigned(host_addr_i) >= dev3_lo) and (unsigned(host_addr_i) <= dev3_hi) then
                dev3_read        <= host_read_i;
                dev3_write       <= host_write_i;
                dev3_mask        <= host_mask_i;
                dev3_addr        <= host_addr_i;
                dev3_data        <= host_data_i;
                host_read_valid  <= dev3_read_valid_i;
                host_write_valid <= dev3_write_valid_i;
                host_data        <= dev3_data_i;
            elsif (unsigned(host_addr_i) >= dev4_lo) and (unsigned(host_addr_i) <= dev4_hi) then
                dev4_read        <= host_read_i;
                dev4_write       <= host_write_i;
                dev4_mask        <= host_mask_i;
                dev4_addr        <= host_addr_i;
                dev4_data        <= host_data_i;
                host_read_valid  <= dev4_read_valid_i;
                host_write_valid <= dev4_write_valid_i;
                host_data        <= dev4_data_i;
            elsif (unsigned(host_addr_i) >= dev5_lo) and (unsigned(host_addr_i) <= dev5_hi) then
                dev5_read        <= host_read_i;
                dev5_write       <= host_write_i;
                dev5_mask        <= host_mask_i;
                dev5_addr        <= host_addr_i;
                dev5_data        <= host_data_i;
                host_read_valid  <= dev5_read_valid_i;
                host_write_valid <= dev5_write_valid_i;
                host_data        <= dev5_data_i;
            elsif (unsigned(host_addr_i) >= dev6_lo) and (unsigned(host_addr_i) <= dev6_hi) then
                dev6_read        <= host_read_i;
                dev6_write       <= host_write_i;
                dev6_mask        <= host_mask_i;
                dev6_addr        <= host_addr_i;
                dev6_data        <= host_data_i;
                host_read_valid  <= dev6_read_valid_i;
                host_write_valid <= dev6_write_valid_i;
                host_data        <= dev6_data_i;
            elsif (unsigned(host_addr_i) >= dev7_lo) and (unsigned(host_addr_i) <= dev7_hi) then
                dev7_read        <= host_read_i;
                dev7_write       <= host_write_i;
                dev7_mask        <= host_mask_i;
                dev7_addr        <= host_addr_i;
                dev7_data        <= host_data_i;
                host_read_valid  <= dev7_read_valid_i;
                host_write_valid <= dev7_write_valid_i;
                host_data        <= dev7_data_i;
            end if;
        end if;
    end process;



end architecture;