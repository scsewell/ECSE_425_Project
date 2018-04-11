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
    signal alu_in0      : std_logic_vector(31 downto 0);
    signal alu_in1      : std_logic_vector(31 downto 0);
    
begin
    
    --alu instance
    alu_inst: alu port map (
        reset => reset,
        op => ctrl_in.alu_op,
        input0 => alu_in0,
        input1 => alu_in1,
        output => ctrl_out.alu_output
    );
    
    --main behaviors
    main_proc: process(clock, ctrl_in)
    begin
        
        if falling_edge(clock) then
            if (reset = '1' or flush = '1' or ctrl_in.instruct_type = i_no_op) then
                alu_in0 <= x"00000000";
                alu_in1 <= x"00000000";
                
                ctrl_out.pc                 <= x"00000000";
                ctrl_out.instruction        <= x"00000000";
                ctrl_out.instruct_type      <= i_no_op;
                ctrl_out.exec_source        <= es_rs_rt;
                ctrl_out.alu_op             <= alu_add;
                ctrl_out.alu_passthrough    <= x"00000000";
                ctrl_out.mem_output         <= x"00000000";
                ctrl_out.write_reg_num      <= "00000";
                
            else
                --set inputs and outputs
                case ctrl_in.exec_source is
                    when es_rs_rt =>
                        alu_in0                     <= rs;
                        alu_in1                     <= rt;
                        ctrl_out.alu_passthrough    <= x"00000000";
                        
                    when es_rt_samnt =>
                        alu_in0                     <= rt;
                        alu_in1                     <= std_logic_vector(resize(unsigned(shamt), 32));
                        ctrl_out.alu_passthrough    <= x"00000000";
                        
                    when es_rs_imm_zero_extend =>
                        alu_in0                     <= rs;
                        alu_in1                     <= std_logic_vector(resize(unsigned(immediate), 32));
                        ctrl_out.alu_passthrough    <= x"00000000";
                        
                    when es_rs_imm_sign_extend =>
                        alu_in0                     <= rs;
                        alu_in1                     <= std_logic_vector(resize(signed(immediate), 32));
                        ctrl_out.alu_passthrough    <= rt;
                        
                    when es_imm_sign_extend =>
                        alu_in0                     <= std_logic_vector(resize(signed(immediate), 32));
                        alu_in1                     <= x"00000000";
                        ctrl_out.alu_passthrough    <= x"00000000";
                        
                    when es_rs_rt_pc_imm_sign_extend =>
                        --output the branch address, compute the difference of rs and rt
                        alu_in0                     <= rs;
                        alu_in1                     <= rt;
                        ctrl_out.alu_passthrough    <= std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_in.pc)) + to_integer(signed(immediate & "00")), 32));
                        
                    when es_pc_address =>
                        --output the jump address
                        alu_in0                     <= x"00000000";
                        alu_in1                     <= x"00000000";
                        ctrl_out.alu_passthrough    <= ctrl_in.pc(31 downto 28) & address & "00";
                end case;
                
                --pass along the control signals
                ctrl_out.pc                 <= ctrl_in.pc;
                ctrl_out.instruction        <= ctrl_in.instruction;
                ctrl_out.instruct_type      <= ctrl_in.instruct_type;
                ctrl_out.exec_source        <= ctrl_in.exec_source;
                ctrl_out.alu_op             <= ctrl_in.alu_op;
                ctrl_out.mem_output         <= ctrl_in.mem_output;
                ctrl_out.write_reg_num      <= ctrl_in.write_reg_num;
                
            end if;
        end if;
        
    end process;
    
end stage_ex_arch;