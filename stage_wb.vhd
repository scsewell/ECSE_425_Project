library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the write back stage of the pipeline.
entity stage_wb is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        flush           : in std_logic;
        ctrl_in         : in CTRL_TYPE;
        use_new_pc      : out std_logic;
        new_pc          : out std_logic_vector(31 downto 0);
        write_reg       : out std_logic;
        write_reg_num   : out std_logic_vector(4 downto 0);
        write_reg_data  : out std_logic_vector(31 downto 0)
    );
end stage_wb;

architecture stage_wb_arch of stage_wb is
begin

    --main behaviors
    main_proc: process(clock)
    begin
        if falling_edge(clock) then
            if (reset = '1' or flush = '1' or ctrl_in.instruct_type = i_no_op) then
                --initialize outputs
                use_new_pc <= '0';
                new_pc <= x"00000000";
                write_reg <= '0';
                write_reg_num <= "00000";
                write_reg_data <= x"00000000";
                
            else
                case ctrl_in.instruct_type is
                    when i_no_op|i_write_hi_low|i_write_mem =>
                        use_new_pc      <= '0';
                        new_pc          <= x"00000000";
                        write_reg       <= '0';
                        write_reg_num   <= "00000";
                        write_reg_data  <= x"00000000";
                        
                    when i_write_reg =>
                        use_new_pc      <= '0';
                        new_pc          <= x"00000000";
                        write_reg       <= '1';
                        write_reg_num   <= ctrl_in.write_reg_num;
                        write_reg_data  <= ctrl_in.alu_output;
                        
                    when i_read_mem =>
                        use_new_pc      <= '0';
                        new_pc          <= x"00000000";
                        write_reg       <= '1';
                        write_reg_num   <= ctrl_in.write_reg_num;
                        write_reg_data  <= ctrl_in.mem_output;
                        
                    when i_jump =>
                        use_new_pc      <= '1';
                        new_pc          <= ctrl_in.alu_passthrough;
                        write_reg       <= '0';
                        write_reg_num   <= "00000";
                        write_reg_data  <= x"00000000";
                        
                    when i_jump_link =>
                        use_new_pc      <= '1';
                        new_pc          <= ctrl_in.alu_passthrough;
                        write_reg       <= '1';
                        write_reg_num   <= "11111"; --link register is $31
                        write_reg_data  <= std_logic_vector(unsigned(ctrl_in.pc) + to_unsigned(8, 32));
                        
                    when i_branch_eq =>
                        if (ctrl_in.alu_output = x"00000000") then
                            use_new_pc  <= '1';
                            new_pc      <= ctrl_in.alu_passthrough;
                        else
                            use_new_pc  <= '0';
                            new_pc      <= x"00000000";
                        end if;
                        write_reg       <= '0';
                        write_reg_num   <= "00000";
                        write_reg_data  <= x"00000000";
                        
                    when i_branch_neq =>
                        if (ctrl_in.alu_output = x"00000000") then
                            use_new_pc  <= '0';
                            new_pc      <= x"00000000";
                        else
                            use_new_pc  <= '1';
                            new_pc      <= ctrl_in.alu_passthrough;
                        end if;
                        write_reg       <= '0';
                        write_reg_num   <= "00000";
                        write_reg_data  <= x"00000000";
                        
                end case;
            end if;
        end if;
    end process;

end stage_wb_arch;
