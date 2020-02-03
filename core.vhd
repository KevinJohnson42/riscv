library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is
    port
    (
        clock_i           : in  std_logic;
        reset_i           : in  std_logic;
        mem_read_valid_i  : in  std_logic;
        mem_write_valid_i : in  std_logic;
        mem_addr_i        : in  std_logic_vector(31 downto 0);
        mem_data_i        : in  std_logic_vector(31 downto 0);
        mem_read_o        : out std_logic;
        mem_write_o       : out std_logic;
        mem_mask_o        : out std_logic_vector(3 downto 0);
        mem_addr_o        : out std_logic_vector(31 downto 0);
        mem_data_o        : out std_logic_vector(31 downto 0)
    );
end entity;


architecture rtl of core is

    --Constants
    constant xlen_c : natural := 32; --(Section 2.1)

    --Define the internal registers (Section 2.1)
    type register_array is array (xlen_c-1 downto 0) of unsigned(xlen_c-1 downto 0);
    signal registers : register_array              := (others => (others => '0'));
    signal reg_write : std_logic                   := '0';
    signal pc_reg    : unsigned(xlen_c-1 downto 0) := (others => '0');
    signal pc_nominal: unsigned(xlen_c-1 downto 0) := (others => '0');
    signal pc_b_imm  : unsigned(xlen_c-1 downto 0) := (others => '0');
    signal pc_j_imm  : unsigned(xlen_c-1 downto 0) := (others => '0');

    --Define instruction subfields (Section 2.2)
    signal funct7 : unsigned(6 downto 0)  := (others => '0');
    signal rs2    : natural range 0 to 31 := 0;
    signal rs1    : natural range 0 to 31 := 0;
    signal funct3 : unsigned(2 downto 0)  := (others => '0');
    signal rd     : natural range 0 to 31 := 0;
    signal opcode : unsigned(6 downto 0)  := (others => '0');

    --Immediates (Section 2.3)
    signal i_imm : unsigned(31 downto 0) := (others => '0');
    signal s_imm : unsigned(31 downto 0) := (others => '0');
    signal b_imm : unsigned(31 downto 0) := (others => '0');
    signal u_imm : unsigned(31 downto 0) := (others => '0');
    signal j_imm : unsigned(31 downto 0) := (others => '0');
    signal inst  : unsigned(31 downto 0) := (others => '0');

    --Instructions (Chapter 24)
    type RV_instruction is
        (
            --RV32I
            lui_32i, auipc_32i, jal_32i, jalr_32i, beq_32i, bne_32i, blt_32i, bge_32i,
            bltu_32i, bgeu_32i, lb_32i, lh_32i, lw_32i, lbu_32i, lhu_32i, sb_32i,
            sh_32i, sw_32i, addi_32i, slti_32i, sltiu_32i, xori_32i, ori_32i, andi_32i,
            slli_32i, srli_32i, srai_32i, add_32i, sub_32i, sll_32i, slt_32i, sltu_32i,
            xor_32i, srl_32i, sra_32i, or_32i, and_32i, fence_32i, ecall_32i, ebreak_32i,

            --?
            unknown
        );
    signal inst_decoded : RV_instruction := unknown;

    --Instruction Registers
    signal r1 : unsigned(xlen_c-1 downto 0) := (others => '0');
    signal r2 : unsigned(xlen_c-1 downto 0) := (others => '0');

    --ALU output
    signal alu_dout : unsigned(xlen_c-1 downto 0) := (others => '0');

    --State machine
    type state_type is (fetch, decode, execute, load, store);
    signal state : state_type := fetch;

    --Memory IO
    signal mem_read  : std_logic                    := '0';
    signal mem_write : std_logic                    := '0';
    signal mem_mask  : std_logic_vector(3 downto 0) := (others => '0');
    signal mem_addr  : unsigned(31 downto 0)        := (others => '0');
    signal mem_din   : unsigned(31 downto 0)        := (others => '0');
    signal mem_dout  : unsigned(31 downto 0)        := (others => '0');

    signal mem_addr_load   : unsigned(31 downto 0) := (others => '0');
    signal mem_read_active : std_logic             := '0';

begin

    --Memory output
    mem_read_o  <= mem_read;
    mem_write_o <= mem_write;
    mem_mask_o  <= mem_mask;
    mem_addr_o  <= std_logic_vector(mem_addr);
    mem_data_o  <= std_logic_vector(mem_dout);

    --Memory input
    mem_din <= unsigned(mem_data_i);

    --State machine
    state_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            case state is
                when fetch =>
                    if (unsigned(mem_addr_i) = pc_reg) and (mem_read_valid_i = '1') and (mem_read_active = '1') then
                        state <= decode;
                    end if;
                when decode  => state <= execute;
                when execute =>
                    case inst_decoded is
                        when lb_32i  => state <= load;
                        when lh_32i  => state <= load;
                        when lw_32i  => state <= load;
                        when lbu_32i => state <= load;
                        when lhu_32i => state <= load;
                        when sb_32i  => state <= store;
                        when sh_32i  => state <= store;
                        when sw_32i  => state <= store;
                        when others  => state <= fetch;
                    end case;
                when load =>
                    if (unsigned(mem_addr_i) = mem_addr_load) and (mem_read_valid_i = '1') and (mem_read_active = '1') then
                        state <= fetch;
                    end if;
                when store =>
                    state <= fetch;
                when others => null; --Never
            end case;
        end if;
    end process;

    --Register the instruction
    inst_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = fetch) and (unsigned(mem_addr_i) = pc_reg) and (mem_read_valid_i = '1') and (mem_read_active = '1') then
                inst <= mem_din;
            end if;
        end if;
    end process;

    --Read from memory
    mem_read_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = fetch) and (mem_read = '0') and (mem_read_active = '0') then
                mem_read <= '1';
            elsif (state = execute) and (mem_read = '0') and (mem_read_active = '0') then
                case inst_decoded is
                    when lb_32i  => mem_read <= '1';
                    when lh_32i  => mem_read <= '1';
                    when lw_32i  => mem_read <= '1';
                    when lbu_32i => mem_read <= '1';
                    when lhu_32i => mem_read <= '1';
                    when others  => mem_read <= '0';
                end case;
            --elsif (state = load) and (mem_read_valid_i = '1') then --change
            --    mem_read <= '1';
            --elsif (state = store) then--and (mem_read_valid_i = '1') then --change
            --    mem_read <= '1';
            else
                mem_read <= '0';
            end if;
        end if;
    end process;

    --Waiting for data to come from memory
    mem_read_active_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (mem_read_valid_i = '1') then
                mem_read_active <= '0';
            elsif (mem_read = '1') then
                mem_read_active <= '1';
            end if;
        end if;
    end process;

    --Write to memory
    mem_write_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (mem_write = '1') then
                mem_write <= '0';
            elsif (state = execute) then
                case inst_decoded is
                    when sb_32i => mem_write <= '1';
                    when sh_32i => mem_write <= '1';
                    when sw_32i => mem_write <= '1';
                    when others => mem_write <= '0';
                end case;
            end if;
        end if;
    end process;

    --Mask memory bytes
    mem_mask_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = fetch) then
                mem_mask <= "1111";
            elsif (state = execute) then
                case inst_decoded is
                    when sb_32i => mem_mask <= "0001";
                    when sh_32i => mem_mask <= "0011";
                    when sw_32i => mem_mask <= "1111";
                    when others => mem_mask <= "----";
                end case;
            end if;
        end if;
    end process;

    --Memory address
    mem_addr_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = fetch) then
                mem_addr <= pc_reg;
            elsif (state = execute) then
                case inst_decoded is
                    when lb_32i  => mem_addr <= r1 + i_imm;
                    when lh_32i  => mem_addr <= r1 + i_imm;
                    when lw_32i  => mem_addr <= r1 + i_imm;
                    when lbu_32i => mem_addr <= r1 + i_imm;
                    when lhu_32i => mem_addr <= r1 + i_imm;
                    when sb_32i  => mem_addr <= r1 + s_imm;
                    when sh_32i  => mem_addr <= r1 + s_imm;
                    when sw_32i  => mem_addr <= r1 + s_imm;
                    when others  => null;
                end case;
            --elsif (state = load) and (mem_read_valid_i = '1') then --change
            --    mem_addr <= pc_reg;
            --elsif (state = store) then --and (mem_read_valid_i = '1') then --change
            --    mem_addr <= pc_reg;
            end if;
        end if;
    end process;

    mem_addr_load_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = execute) then
                case inst_decoded is
                    when lb_32i  => mem_addr_load <= r1 + i_imm;
                    when lh_32i  => mem_addr_load <= r1 + i_imm;
                    when lw_32i  => mem_addr_load <= r1 + i_imm;
                    when lbu_32i => mem_addr_load <= r1 + i_imm;
                    when lhu_32i => mem_addr_load <= r1 + i_imm;
                    when others  => null;
                end case;
            end if;
        end if;
    end process;

    --Memory data
    mem_dout_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = execute) then
                mem_dout <= r2;
            end if;
        end if;
    end process;

    --Load registers into ALU
    load_registers_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = decode) then
                r1 <= registers(rs1);
                r2 <= registers(rs2);
            end if;
        end if;
    end process;


    --Subfields
    funct7 <= inst(31 downto 25);
    rs2    <= to_integer(inst(24 downto 20));
    rs1    <= to_integer(inst(19 downto 15));
    funct3 <= inst(14 downto 12);
    rd     <= to_integer(inst(11 downto 7));
    opcode <= inst(6 downto 0);


    --I-immediate
    i_imm(31 downto 11) <= (others => '1') when (inst(31) = '1') else (others => '0');
    i_imm(10 downto 0)  <= inst(30 downto 20);
    --S-immediate
    s_imm(31 downto 11) <= (others => '1') when (inst(31) = '1') else (others => '0');
    s_imm(10 downto 0)  <= inst(30 downto 25) & inst(11 downto 7);
    --B-immediate
    b_imm(31 downto 12) <= (others => '1') when (inst(31) = '1') else (others => '0');
    b_imm(11 downto 0)  <= inst(7) & inst(30 downto 25) & inst(11 downto 8) & "0";
    --U-immediate
    u_imm <= inst(31) & inst(30 downto 20) & inst(19 downto 12) & x"000";
    --J-immediate
    j_imm(31 downto 20) <= (others => '1') when (inst(31) = '1') else (others => '0');
    j_imm(19 downto 0)  <= inst(19 downto 12) & inst(20) & inst(30 downto 21) & "0";


    --Write registers
    registers_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            --Do not write register 0
            if (rd /= 0) and (reg_write = '1') then
                registers(rd) <= alu_dout;
            elsif (state = load) and (unsigned(mem_addr_i) = mem_addr_load) and (mem_read_valid_i = '1') and (mem_read_active = '1') then
                case inst_decoded is
                    when lb_32i  => registers(rd) <= x"FFFFFF"&mem_din(7 downto 0) when (mem_din(7)='1') else x"000000"&mem_din(7 downto 0);
                    when lh_32i  => registers(rd) <= x"FFFF"&mem_din(15 downto 0) when (mem_din(15)='1') else x"0000"&mem_din(15 downto 0);
                    when lw_32i  => registers(rd) <= mem_din;
                    when lbu_32i => registers(rd) <= x"000000"&mem_din(7 downto 0);
                    when lhu_32i => registers(rd) <= x"0000"&mem_din(15 downto 0);
                    when others  => null;
                end case;
            end if;
        end if;
    end process;

    --Decode instruction
    inst_decoded_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (opcode = "0110111") then inst_decoded <= lui_32i;
            elsif (opcode = "0010111") then inst_decoded <= auipc_32i;
            elsif (opcode = "1101111") then inst_decoded <= jal_32i;
            elsif (funct3 = "000") and (opcode = "1100111") then inst_decoded <= jalr_32i;
            elsif (funct3 = "000") and (opcode = "1100011") then inst_decoded <= beq_32i;
            elsif (funct3 = "001") and (opcode = "1100011") then inst_decoded <= bne_32i;
            elsif (funct3 = "100") and (opcode = "1100011") then inst_decoded <= blt_32i;
            elsif (funct3 = "101") and (opcode = "1100011") then inst_decoded <= bge_32i;
            elsif (funct3 = "110") and (opcode = "1100011") then inst_decoded <= bltu_32i;
            elsif (funct3 = "111") and (opcode = "1100011") then inst_decoded <= bgeu_32i;
            elsif (funct3 = "000") and (opcode = "0000011") then inst_decoded <= lb_32i;
            elsif (funct3 = "001") and (opcode = "0000011") then inst_decoded <= lh_32i;
            elsif (funct3 = "010") and (opcode = "0000011") then inst_decoded <= lw_32i;
            elsif (funct3 = "100") and (opcode = "0000011") then inst_decoded <= lbu_32i;
            elsif (funct3 = "101") and (opcode = "0000011") then inst_decoded <= lhu_32i;
            elsif (funct3 = "000") and (opcode = "0100011") then inst_decoded <= sb_32i;
            elsif (funct3 = "001") and (opcode = "0100011") then inst_decoded <= sh_32i;
            elsif (funct3 = "010") and (opcode = "0100011") then inst_decoded <= sw_32i;
            elsif (funct3 = "000") and (opcode = "0010011") then inst_decoded <= addi_32i;
            elsif (funct3 = "010") and (opcode = "0010011") then inst_decoded <= slti_32i;
            elsif (funct3 = "011") and (opcode = "0010011") then inst_decoded <= sltiu_32i;
            elsif (funct3 = "100") and (opcode = "0010011") then inst_decoded <= xori_32i;
            elsif (funct3 = "110") and (opcode = "0010011") then inst_decoded <= ori_32i;
            elsif (funct3 = "111") and (opcode = "0010011") then inst_decoded <= andi_32i;
            elsif (funct7 = "0000000") and (funct3 = "001") and (opcode = "0010011") then inst_decoded <= slli_32i;
            elsif (funct7 = "0000000") and (funct3 = "101") and (opcode = "0010011") then inst_decoded <= srli_32i;
            elsif (funct7 = "0100000") and (funct3 = "101") and (opcode = "0010011") then inst_decoded <= srai_32i;
            elsif (funct7 = "0000000") and (funct3 = "000") and (opcode = "0110011") then inst_decoded <= add_32i;
            elsif (funct7 = "0100000") and (funct3 = "000") and (opcode = "0110011") then inst_decoded <= sub_32i;
            elsif (funct7 = "0000000") and (funct3 = "001") and (opcode = "0110011") then inst_decoded <= sll_32i;
            elsif (funct7 = "0000000") and (funct3 = "010") and (opcode = "0110011") then inst_decoded <= slt_32i;
            elsif (funct7 = "0000000") and (funct3 = "011") and (opcode = "0110011") then inst_decoded <= sltu_32i;
            elsif (funct7 = "0000000") and (funct3 = "100") and (opcode = "0110011") then inst_decoded <= xor_32i;
            elsif (funct7 = "0000000") and (funct3 = "101") and (opcode = "0110011") then inst_decoded <= srl_32i;
            elsif (funct7 = "0100000") and (funct3 = "101") and (opcode = "0110011") then inst_decoded <= sra_32i;
            elsif (funct7 = "0000000") and (funct3 = "110") and (opcode = "0110011") then inst_decoded <= or_32i;
            elsif (funct7 = "0000000") and (funct3 = "111") and (opcode = "0110011") then inst_decoded <= and_32i;
            elsif (funct3 = "000") and (opcode = "0001111") then inst_decoded <= fence_32i;
            elsif (inst = "00000000000000000000000001110011") then inst_decoded <= ecall_32i;
            elsif (inst = "00000000000100000000000001110011") then inst_decoded <= ebreak_32i;
            else inst_decoded <= unknown;
            end if;
        end if;
    end process;

    next_program_counter_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = decode) then
                pc_nominal <= 4 + pc_reg;
                pc_j_imm   <= j_imm + pc_reg;
                pc_b_imm   <= b_imm + pc_reg;
            end if;
        end if;
    end process;

    program_counter_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = execute) then
                case inst_decoded is
                    when jal_32i  => pc_reg <= pc_j_imm;
                    when jalr_32i => pc_reg <= i_imm + r1; --It's suppose to be I-type (Section 2.5)
                    when beq_32i  => pc_reg <= pc_b_imm when (r1=r2) else pc_nominal;
                    when bne_32i  => pc_reg <= pc_b_imm when (r1/=r2) else pc_nominal;
                    when blt_32i  => pc_reg <= pc_b_imm when (signed(r1)<signed(r2)) else pc_nominal;
                    when bge_32i  => pc_reg <= pc_b_imm when (signed(r1)>=signed(r2)) else pc_nominal;
                    when bltu_32i => pc_reg <= pc_b_imm when (r1<r2) else pc_nominal;
                    when bgeu_32i => pc_reg <= pc_b_imm when (r1>=r2) else pc_nominal;
                    when unknown  => null; --Halt, you shall not pass
                    when others   => pc_reg <= pc_nominal;
                end case;
            end if;
        end if;
    end process;

    --Execute instruction
    alu_dout_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = execute) then
                case inst_decoded is
                    when lui_32i    => alu_dout <= u_imm;
                    when auipc_32i  => alu_dout <= u_imm + pc_reg;
                    when jal_32i    => alu_dout <= pc_nominal;--pc_reg + 4;
                    when jalr_32i   => alu_dout <= pc_nominal;--pc_reg + 4;
                    when beq_32i    => alu_dout <= (others => '-');
                    when bne_32i    => alu_dout <= (others => '-');
                    when blt_32i    => alu_dout <= (others => '-');
                    when bge_32i    => alu_dout <= (others => '-');
                    when bltu_32i   => alu_dout <= (others => '-');
                    when bgeu_32i   => alu_dout <= (others => '-');
                    when lb_32i     => alu_dout <= (others => '-');
                    when lh_32i     => alu_dout <= (others => '-');
                    when lw_32i     => alu_dout <= (others => '-');
                    when lbu_32i    => alu_dout <= (others => '-');
                    when lhu_32i    => alu_dout <= (others => '-');
                    when sb_32i     => alu_dout <= (others => '-');
                    when sh_32i     => alu_dout <= (others => '-');
                    when sw_32i     => alu_dout <= (others => '-');
                    when addi_32i   => alu_dout <= i_imm + r1;
                    when slti_32i   => alu_dout <= x"00000001" when (signed(r1) < signed(i_imm)) else (others => '0');
                    when sltiu_32i  => alu_dout <= x"00000001" when (r1 < i_imm) else (others => '0');
                    when xori_32i   => alu_dout <= r1 xor i_imm;
                    when ori_32i    => alu_dout <= r1 or i_imm;
                    when andi_32i   => alu_dout <= r1 and i_imm;
                    when slli_32i   => alu_dout <= r1 sll to_integer(i_imm(4 downto 0));
                    when srli_32i   => alu_dout <= r1 srl to_integer(i_imm(4 downto 0));
                    when srai_32i   => alu_dout <= unsigned(signed(r1) srl to_integer(i_imm(4 downto 0)));
                    when add_32i    => alu_dout <= r1 + r2;
                    when sub_32i    => alu_dout <= r1 - r2;
                    when sll_32i    => alu_dout <= r1 sll to_integer(r2(4 downto 0));
                    when slt_32i    => alu_dout <= x"00000001" when (signed(r2) /= 0) else (others => '0');
                    when sltu_32i   => alu_dout <= x"00000001" when (r2 /= 0) else (others => '0');
                    when xor_32i    => alu_dout <= r1 xor r2;
                    when srl_32i    => alu_dout <= r1 srl to_integer(r2(4 downto 0));
                    when sra_32i    => alu_dout <= unsigned(signed(r1) srl to_integer(r2(4 downto 0)));
                    when or_32i     => alu_dout <= r1 or r2;
                    when and_32i    => alu_dout <= r1 and r2;
                    when fence_32i  => alu_dout <= (others => '-'); --Don't care, this is an in-order design
                    when ecall_32i  => alu_dout <= (others => '-'); --Not implemented
                    when ebreak_32i => alu_dout <= (others => '-'); --Not implemented
                    when unknown    => alu_dout <= (others => '-'); --Not implemented / invalid
                    when others     => alu_dout <= (others => '-'); --Should never reach here
                end case;
            end if;
        end if;
    end process;

    --Register write back
    reg_write_ps : process(clock_i)
    begin
        if rising_edge(clock_i) then
            if (state = execute) then
                case inst_decoded is
                    when lui_32i    => reg_write <= '1';
                    when auipc_32i  => reg_write <= '1';
                    when jal_32i    => reg_write <= '1';
                    when jalr_32i   => reg_write <= '1';
                    when beq_32i    => reg_write <= '0';
                    when bne_32i    => reg_write <= '0';
                    when blt_32i    => reg_write <= '0';
                    when bge_32i    => reg_write <= '0';
                    when bltu_32i   => reg_write <= '0';
                    when bgeu_32i   => reg_write <= '0';
                    when lb_32i     => reg_write <= '0';
                    when lh_32i     => reg_write <= '0';
                    when lw_32i     => reg_write <= '0';
                    when lbu_32i    => reg_write <= '0';
                    when lhu_32i    => reg_write <= '0';
                    when sb_32i     => reg_write <= '0';
                    when sh_32i     => reg_write <= '0';
                    when sw_32i     => reg_write <= '0';
                    when addi_32i   => reg_write <= '1';
                    when slti_32i   => reg_write <= '1';
                    when sltiu_32i  => reg_write <= '1';
                    when xori_32i   => reg_write <= '1';
                    when ori_32i    => reg_write <= '1';
                    when andi_32i   => reg_write <= '1';
                    when slli_32i   => reg_write <= '1';
                    when srli_32i   => reg_write <= '1';
                    when srai_32i   => reg_write <= '1';
                    when add_32i    => reg_write <= '1';
                    when sub_32i    => reg_write <= '1';
                    when sll_32i    => reg_write <= '1';
                    when slt_32i    => reg_write <= '1';
                    when sltu_32i   => reg_write <= '1';
                    when xor_32i    => reg_write <= '1';
                    when srl_32i    => reg_write <= '1';
                    when sra_32i    => reg_write <= '1';
                    when or_32i     => reg_write <= '1';
                    when and_32i    => reg_write <= '1';
                    when fence_32i  => reg_write <= '0';
                    when ecall_32i  => reg_write <= '0';
                    when ebreak_32i => reg_write <= '0';
                    when unknown    => reg_write <= '0';
                    when others     => reg_write <= '0';
                end case;
            else
                reg_write <= '0';
            end if;
        end if;
    end process;



end architecture rtl;





--case inst is
--when "-------------------------0110111" => inst_decoded <= lui_32i;
--when "-------------------------0010111" => inst_decoded <= auipc_32i;
--when "-------------------------1101111" => inst_decoded <= jal_32i;
--when "-----------------000-----1100111" => inst_decoded <= jalr_32i;
--when "-----------------000-----1100011" => inst_decoded <= beq_32i;
--when "-----------------001-----1100011" => inst_decoded <= bne_32i;
--when "-----------------100-----1100011" => inst_decoded <= blt_32i;
--when "-----------------101-----1100011" => inst_decoded <= bge_32i;
--when "-----------------110-----1100011" => inst_decoded <= bltu_32i;
--when "-----------------111-----1100011" => inst_decoded <= bgeu_32i;
--when "-----------------000-----0000011" => inst_decoded <= lb_32i;
--when "-----------------001-----0000011" => inst_decoded <= lh_32i;
--when "-----------------010-----0000011" => inst_decoded <= lw_32i;
--when "-----------------100-----0000011" => inst_decoded <= lbu_32i;
--when "-----------------101-----0000011" => inst_decoded <= lhu_32i;
--when "-----------------000-----0100011" => inst_decoded <= sb_32i;
--when "-----------------001-----0100011" => inst_decoded <= sh_32i;
--when "-----------------010-----0100011" => inst_decoded <= sw_32i;
--when "-----------------000-----0010011" => inst_decoded <= addi_32i;
--when "-----------------010-----0010011" => inst_decoded <= slti_32i;
--when "-----------------011-----0010011" => inst_decoded <= sltiu_32i;
--when "-----------------100-----0010011" => inst_decoded <= xori_32i;
--when "-----------------110-----0010011" => inst_decoded <= ori_32i;
--when "-----------------111-----0010011" => inst_decoded <= andi_32i;
--when "0000000----------001-----0010011" => inst_decoded <= slli_32i;
--when "0000000----------101-----0010011" => inst_decoded <= srli_32i;
--when "0100000----------101-----0010011" => inst_decoded <= srai_32i;
--when "0000000----------000-----0110011" => inst_decoded <= add_32i;
--when "0100000----------000-----0110011" => inst_decoded <= sub_32i;
--when "0000000----------001-----0110011" => inst_decoded <= sll_32i;
--when "0000000----------010-----0110011" => inst_decoded <= slt_32i;
--when "0000000----------011-----0110011" => inst_decoded <= sltu_32i;
--when "0000000----------100-----0110011" => inst_decoded <= xor_32i;
--when "0000000----------101-----0110011" => inst_decoded <= srl_32i;
--when "0100000----------101-----0110011" => inst_decoded <= sra_32i;
--when "0000000----------110-----0110011" => inst_decoded <= or_32i;
--when "0000000----------111-----0110011" => inst_decoded <= and_32i;
--when "-----------------000-----0001111" => inst_decoded <= fence_32i;
--when "00000000000000000000000001110011" => inst_decoded <= ecall_32i;
--when "00000000000100000000000001110011" => inst_decoded <= ebreak_32i;
--when others                             => inst_decoded <= unknown;
--end case;