library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the execution stage of the pipeline.
entity stage_ex is
    port (
        reset               : in std_logic;
        clock               : in std_logic;
        use_branch_predict  : in std_logic;
        rs                  : in std_logic_vector(31 downto 0);
        rt                  : in std_logic_vector(31 downto 0);
        ctrl_in             : in CTRL_TYPE;
        use_new_pc          : out std_logic;
        new_pc              : out std_logic_vector(31 downto 0);
        new_pc_src_address  : out std_logic_vector(31 downto 0);
        ctrl_out            : out CTRL_TYPE
    );
end stage_ex;

architecture stage_ex_arch of stage_ex is

    --import alu
    component alu is
        port (
            reset   : in std_logic;
            op      : in ALU_OP_TYPE;
            input0  : in std_logic_vector(31 downto 0);
            input1  : in std_logic_vector(31 downto 0);
            output  : out std_logic_vector(31 downto 0)
        );
    end component;
    
    --extract the different parts of the instruction
    alias shamt         : std_logic_vector(4 downto 0) is ctrl_in.instruction(10 downto 6);
    alias immediate     : std_logic_vector(15 downto 0) is ctrl_in.instruction(15 downto 0);
    alias address       : std_logic_vector(25 downto 0) is ctrl_in.instruction(25 downto 0);
    
    --signals for the alu inputs
    signal alu_op       : ALU_OP_TYPE;
    signal alu_in0      : std_logic_vector(31 downto 0);
    signal alu_in1      : std_logic_vector(31 downto 0);
    
    --signals for handling branch prediction corrections
    signal use_new_pc_1 : std_logic;
    signal use_new_pc_2 : std_logic;
    signal new_pc_1     : std_logic_vector(31 downto 0);
    signal new_pc_2     : std_logic_vector(31 downto 0);
    
begin
    
    --alu instance
    alu_inst: alu port map (
        reset => reset,
        op => alu_op,
        input0 => alu_in0,
        input1 => alu_in1,
        output => ctrl_out.alu_output
    );
    
    --main behaviors
    main_proc: process(clock)
        
        variable var_alu_in0        : std_logic_vector(31 downto 0);
        variable var_alu_in1        : std_logic_vector(31 downto 0);
        variable var_mem_write      : std_logic_vector(31 downto 0);
        variable var_use_new_pc     : std_logic;
        variable var_new_pc         : std_logic_vector(31 downto 0);
        variable var_new_pc_src     : std_logic_vector(31 downto 0);
        
    begin
        if falling_edge(clock) then
            if (reset = '1') then
                alu_in0     <= x"00000000";
                alu_in1     <= x"00000000";
                use_new_pc  <= '0';
                new_pc      <= x"00000000";
                
                ctrl_out.pc                 <= x"00000000";
                ctrl_out.instruction        <= x"00000000";
                ctrl_out.instruct_type      <= i_no_op;
                ctrl_out.alu_op             <= alu_add;
                ctrl_out.mem_write_val      <= x"00000000";
                ctrl_out.write_reg_num      <= "00000";
                
                use_new_pc_1    <= '0';
                use_new_pc_2    <= '0';
                new_pc_1        <= x"00000000";
                new_pc_2        <= x"00000000";
                
            else
                if ((use_new_pc_1 = '1' and (ctrl_in.pc /= new_pc_1 or use_branch_predict = '0')) or ctrl_in.instruct_type = i_no_op) then
                    alu_in0     <= x"00000000";
                    alu_in1     <= x"00000000";
                    use_new_pc  <= '0';
                    new_pc      <= x"00000000";
                    
                    ctrl_out.pc                 <= x"00000000";
                    ctrl_out.instruction        <= x"00000000";
                    ctrl_out.instruct_type      <= i_no_op;
                    ctrl_out.alu_op             <= alu_add;
                    ctrl_out.mem_write_val      <= x"00000000";
                    ctrl_out.write_reg_num      <= "00000";
                    
                    use_new_pc_2    <= '0';
                    new_pc_2        <= x"00000000";
                    use_new_pc_1    <= use_new_pc_2;
                    new_pc_1        <= new_pc_2;
                    
                else
                    use_new_pc_2    <= '0';
                    new_pc_2        <= x"00000000";
                    use_new_pc_1    <= use_new_pc_2;
                    new_pc_1        <= new_pc_2;
                    
                    var_alu_in0     := x"00000000";
                    var_alu_in1     := x"00000000";
                    var_mem_write   := x"00000000";
                    var_use_new_pc  := '0';
                    var_new_pc      := x"00000000";
                    var_new_pc_src  := x"00000000";
                    
                    case ctrl_in.instruct_type is
                        when i_no_op|i_add|i_sub|i_mult|i_div|i_slt|i_and|i_or|i_nor|i_xor|i_mfhi|i_mflo =>
                            var_alu_in0     := rs;
                            var_alu_in1     := rt;
                            
                        when i_sll|i_srl|i_sra =>
                            var_alu_in0     := rt;
                            var_alu_in1     := std_logic_vector(resize(unsigned(shamt), 32));
                            
                        when i_andi|i_ori|i_xori => 
                            var_alu_in0     := rs;
                            var_alu_in1     := std_logic_vector(resize(unsigned(immediate), 32));
                            
                        when i_addi|i_slti|i_lw =>
                            var_alu_in0     := rs;
                            var_alu_in1     := std_logic_vector(resize(signed(immediate), 32));
                            
                        when i_sw =>
                            var_alu_in0     := rs;
                            var_alu_in1     := std_logic_vector(resize(signed(immediate), 32));
                            var_mem_write   := rt;
                            
                        when i_lui =>
                            var_alu_in0     := std_logic_vector(resize(signed(immediate), 32));
                            
                        when i_beq =>
                            var_use_new_pc  := '1';
                            var_new_pc_src  := ctrl_in.pc;
                            
                            if (rs = rt) then
                                var_new_pc  := std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + 4 + to_integer(signed(immediate & "00")), 32));
                            else
                                var_new_pc  := std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + 4, 32));
                            end if;
                            
                            use_new_pc_1    <= '1';
                            new_pc_1        <= var_new_pc;
                            use_new_pc_2    <= '1';
                            new_pc_2        <= std_logic_vector(unsigned(var_new_pc) + to_unsigned(4, 32));
                            
                        when i_bne =>
                            var_use_new_pc  := '1';
                            var_new_pc_src  := ctrl_in.pc;
                            
                            if (rs /= rt) then
                                var_new_pc  := std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + 4 + to_integer(signed(immediate & "00")), 32));
                            else
                                var_new_pc  := std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + 4, 32));
                            end if;
                            
                            use_new_pc_1    <= '1';
                            new_pc_1        <= var_new_pc;
                            use_new_pc_2    <= '1';
                            new_pc_2        <= std_logic_vector(unsigned(var_new_pc) + to_unsigned(4, 32));
                            
                        when i_j|i_jal =>
                            var_alu_in0     := ctrl_in.pc; --output = pc + 8
                            var_alu_in1     := x"00000008";
                            
                            var_use_new_pc  := '1';
                            var_new_pc      := ctrl_in.pc(31 downto 28) & address & "00";
                            var_new_pc_src  := ctrl_in.pc;
                            
                            use_new_pc_1    <= '1';
                            new_pc_1        <= var_new_pc;
                            use_new_pc_2    <= '1';
                            new_pc_2        <= std_logic_vector(unsigned(var_new_pc) + to_unsigned(4, 32));
                            
                        when i_jr =>
                            var_use_new_pc  := '1';
                            var_new_pc      := rs;
                            var_new_pc_src  := ctrl_in.pc;
                            
                            use_new_pc_1    <= '1';
                            new_pc_1        <= var_new_pc;
                            use_new_pc_2    <= '1';
                            new_pc_2        <= std_logic_vector(unsigned(var_new_pc) + to_unsigned(4, 32));
                            
                    end case;
                    
                    alu_in0                 <= var_alu_in0;
                    alu_in1                 <= var_alu_in1;
                    ctrl_out.mem_write_val  <= var_mem_write;
                    use_new_pc              <= var_use_new_pc;
                    new_pc                  <= var_new_pc;
                    new_pc_src_address      <= var_new_pc_src;
                    
                    --pass along the control signals
                    ctrl_out.pc                 <= ctrl_in.pc;
                    ctrl_out.instruction        <= ctrl_in.instruction;
                    ctrl_out.instruct_type      <= ctrl_in.instruct_type;
                    ctrl_out.alu_op             <= ctrl_in.alu_op;
                    ctrl_out.write_reg_num      <= ctrl_in.write_reg_num;
                    
                    alu_op <= ctrl_in.alu_op;
                
                end if;
                
            end if;
        end if;
    end process;
    
end stage_ex_arch;