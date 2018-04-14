library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the execution stage of the pipeline.
entity stage_ex is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        flush           : in std_logic;
        rs              : in std_logic_vector(31 downto 0);
        rt              : in std_logic_vector(31 downto 0);
        ctrl_in         : in CTRL_TYPE;
        use_new_pc      : out std_logic;
        new_pc          : out std_logic_vector(31 downto 0);
        ctrl_out        : out CTRL_TYPE
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
    main_proc: process(clock, ctrl_in)
    begin
        
        if falling_edge(clock) then
            if (reset = '1' or flush = '1' or ctrl_in.instruct_type = i_no_op) then
            
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
                
            else
                case ctrl_in.instruct_type is
                    when i_no_op|i_add|i_sub|i_mult|i_div|i_slt|i_and|i_or|i_nor|i_xor|i_mfhi|i_mflo =>
                        alu_in0                 <= rs;
                        alu_in1                 <= rt;
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_sll|i_srl|i_sra =>
                        alu_in0                 <= rt;
                        alu_in1                 <= std_logic_vector(resize(unsigned(shamt), 32));
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_andi|i_ori|i_xori => 
                        alu_in0                 <= rs;
                        alu_in1                 <= std_logic_vector(resize(unsigned(immediate), 32));
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_addi|i_slti|i_lw =>
                        alu_in0                 <= rs;
                        alu_in1                 <= std_logic_vector(resize(signed(immediate), 32));
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_sw =>
                        alu_in0                 <= rs;
                        alu_in1                 <= std_logic_vector(resize(signed(immediate), 32));
                        ctrl_out.mem_write_val  <= rt;
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_lui =>
                        alu_in0                 <= std_logic_vector(resize(signed(immediate), 32));
                        alu_in1                 <= x"00000000";
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '0';
                        new_pc                  <= x"00000000";
                        
                    when i_beq =>
                        alu_in0                 <= x"00000000";
                        alu_in1                 <= x"00000000";
                        ctrl_out.mem_write_val  <= x"00000000";
                        
                        if (rs = rt) then
                            use_new_pc  <= '1';
                            new_pc      <= std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + to_integer(signed(immediate & "00")), 32));
                        else
                            use_new_pc  <= '0';
                            new_pc      <= x"00000000";
                        end if;
                            
                    when i_bne =>
                        alu_in0                 <= x"00000000";
                        alu_in1                 <= x"00000000";
                        ctrl_out.mem_write_val  <= x"00000000";
                        
                        if (rs = rt) then
                            use_new_pc  <= '0';
                            new_pc      <= x"00000000";
                        else
                            use_new_pc  <= '1';
                            new_pc      <= std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + to_integer(signed(immediate & "00")), 32));
                        end if;
                        
                    when i_j|i_jal =>
                        alu_in0                 <= ctrl_in.pc; --output = pc + 8
                        alu_in1                 <= x"00000008";
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '1';
                        new_pc                  <= ctrl_in.pc(31 downto 28) & address & "00";
                        
                    when i_jr =>
                        alu_in0                 <= x"00000000";
                        alu_in1                 <= x"00000000";
                        ctrl_out.mem_write_val  <= x"00000000";
                        use_new_pc              <= '1';
                        new_pc                  <= rs;
                        
                end case;
                
                --pass along the control signals
                ctrl_out.pc                 <= ctrl_in.pc;
                ctrl_out.instruction        <= ctrl_in.instruction;
                ctrl_out.instruct_type      <= ctrl_in.instruct_type;
                ctrl_out.alu_op             <= ctrl_in.alu_op;
                ctrl_out.write_reg_num      <= ctrl_in.write_reg_num;
                
                alu_op <= ctrl_in.alu_op;
                
            end if;
        end if;
        
    end process;
    
end stage_ex_arch;