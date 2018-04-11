library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the instruction decode stage of the pipeline.
--Interprets the current instruction and creates control signals
--that will execute the expected behaviours for that instruction.
entity stage_id is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        flush           : in std_logic;
        instruction     : in std_logic_vector(31 downto 0);
        pc              : in std_logic_vector(31 downto 0);
        ctrl            : out CTRL_TYPE
    );
end stage_id;

architecture stage_id_arch of stage_id is
    
    --extract the different parts of the instruction
    alias opcode      : std_logic_vector(5 downto 0) is instruction(31 downto 26);
    alias rs          : std_logic_vector(4 downto 0) is instruction(25 downto 21);
    alias rt          : std_logic_vector(4 downto 0) is instruction(20 downto 16);
    alias rd          : std_logic_vector(4 downto 0) is instruction(15 downto 11);
    alias shamt       : std_logic_vector(4 downto 0) is instruction(10 downto 6);
    alias funct       : std_logic_vector(5 downto 0) is instruction(5 downto 0);
    alias immediate   : std_logic_vector(15 downto 0) is instruction(15 downto 0);
    alias address     : std_logic_vector(25 downto 0) is instruction(25 downto 0);
    
begin

    --main behaviors
    main_proc: process(clock, reset, flush)
    begin
        if falling_edge(clock) then
            if (reset = '1' or flush = '1') then
                ctrl.pc                 <= x"00000000";
                ctrl.instruction        <= x"00000000";
                ctrl.instruct_type      <= i_no_op;
                ctrl.exec_source        <= es_rs_rt;
                ctrl.alu_op             <= alu_add;
                ctrl.alu_output         <= x"00000000";
                ctrl.alu_passthrough    <= x"00000000";
                ctrl.mem_output         <= x"00000000";
                ctrl.write_reg_num      <= "00000";
                
            else
                case opcode is
                    when "000000" => --R type instructions
                    
                        case funct is
                            when "100000" => --ADD
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_add;
                                ctrl.write_reg_num  <= rd;
                                
                            when "100010" => --SUB
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_sub;
                                ctrl.write_reg_num  <= rd;
                                
                            when "011000" => --MUL
                                ctrl.instruct_type  <= i_write_hi_low;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_mul;
                                ctrl.write_reg_num  <= "00000";
                                
                            when "011010" => --DIV
                                ctrl.instruct_type  <= i_write_hi_low;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_div;
                                ctrl.write_reg_num  <= "00000";
                                
                            when "101010" => --SLT
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_slt;
                                ctrl.write_reg_num  <= rd;
                                
                            when "100100" => --AND
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_and;
                                ctrl.write_reg_num  <= rd;
                                
                            when "100101" => --OR
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_or;
                                ctrl.write_reg_num  <= rd;
                                
                            when "100111" => --NOR
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_nor;
                                ctrl.write_reg_num  <= rd;
                                
                            when "101000" => --XOR
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_xor;
                                ctrl.write_reg_num  <= rd;
                                
                            when "001010" => --MFHI
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_hi;
                                ctrl.write_reg_num  <= rd;
                                
                            when "001100" => --MFLO
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_lo;
                                ctrl.write_reg_num  <= rd;
                                
                            when "000000" => --SLL
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rt_samnt;
                                ctrl.alu_op         <= alu_sll;
                                ctrl.write_reg_num  <= rd;
                                
                            when "000010" => --SRL
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rt_samnt;
                                ctrl.alu_op         <= alu_srl;
                                ctrl.write_reg_num  <= rd;
                                
                            when "000011" => --SRA
                                ctrl.instruct_type  <= i_write_reg;
                                ctrl.exec_source    <= es_rt_samnt;
                                ctrl.alu_op         <= alu_sra;
                                ctrl.write_reg_num  <= rd;
                                
                            when "001000" => --JR
                                ctrl.instruct_type  <= i_jump;
                                ctrl.exec_source    <= es_rs_rt;
                                ctrl.alu_op         <= alu_add;
                                ctrl.write_reg_num  <= "00000";
                                
                            when others =>
                                ctrl.instruct_type  <= i_no_op;
                        end case;
                    
                    when "001000" => --ADDI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_rs_imm_sign_extend;
                        ctrl.alu_op         <= alu_add;
                        ctrl.write_reg_num  <= rt;
                    
                    when "001010" => --SLTI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_rs_imm_sign_extend;
                        ctrl.alu_op         <= alu_slt;
                        ctrl.write_reg_num  <= rt;
                    
                    when "001100" => --ANDI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_rs_imm_zero_extend;
                        ctrl.alu_op         <= alu_and;
                        ctrl.write_reg_num  <= rt;
                    
                    when "001101" => --ORI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_rs_imm_zero_extend;
                        ctrl.alu_op         <= alu_or;
                        ctrl.write_reg_num  <= rt;
                    
                    when "001110" => --XORI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_rs_imm_zero_extend;
                        ctrl.alu_op         <= alu_xor;
                        ctrl.write_reg_num  <= rt;
                    
                    when "001111" => --LUI
                        ctrl.instruct_type  <= i_write_reg;
                        ctrl.exec_source    <= es_imm_sign_extend;
                        ctrl.alu_op         <= alu_lu;
                        ctrl.write_reg_num  <= rt;
                    
                    when "100011" => --LW
                        ctrl.instruct_type  <= i_read_mem;
                        ctrl.exec_source    <= es_rs_imm_sign_extend;
                        ctrl.alu_op         <= alu_add;
                        ctrl.write_reg_num  <= rt;
                    
                    when "101011" => --SW
                        ctrl.instruct_type  <= i_write_mem;
                        ctrl.exec_source    <= es_rs_imm_sign_extend;
                        ctrl.alu_op         <= alu_add;
                        ctrl.write_reg_num  <= "00000";
                    
                    when "000100" => --BEQ
                        ctrl.instruct_type  <= i_branch_eq;
                        ctrl.exec_source    <= es_rs_rt_pc_imm_sign_extend;
                        ctrl.alu_op         <= alu_sub;
                        ctrl.write_reg_num  <= "00000";
                    
                    when "000101" => --BNE
                        ctrl.instruct_type  <= i_branch_neq;
                        ctrl.exec_source    <= es_rs_rt_pc_imm_sign_extend;
                        ctrl.alu_op         <= alu_sub;
                        ctrl.write_reg_num  <= "00000";
                    
                    when "000010" => --J
                        ctrl.instruct_type  <= i_jump;
                        ctrl.exec_source    <= es_pc_address;
                        ctrl.write_reg_num  <= "00000";
                    
                    when "000011" => --JAL
                        ctrl.instruct_type  <= i_jump_link;
                        ctrl.exec_source    <= es_pc_address;
                        ctrl.write_reg_num  <= "00000";
                    
                    when others =>
                        ctrl.instruct_type  <= i_no_op;
                end case;
                
                --pass the source instruction and addresss of the instruction
                ctrl.pc <= pc;
                ctrl.instruction <= instruction;
                
            end if;
        end if;
    end process;

end stage_id_arch;
