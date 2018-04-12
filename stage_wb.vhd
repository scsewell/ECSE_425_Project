library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the write back stage of the pipeline.
entity stage_wb is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        ctrl_in         : in CTRL_TYPE;
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
            if (reset = '1' or ctrl_in.instruct_type = i_no_op) then
                write_reg <= '0';
                write_reg_num <= "00000";
                write_reg_data <= x"00000000";
                
            else
                case ctrl_in.instruct_type is
                    when i_no_op|i_mult|i_div|i_sw|i_beq|i_bne|i_j|i_jr =>
                        write_reg       <= '0';
                        write_reg_num   <= "00000";
                        write_reg_data  <= x"00000000";
                        
                    when i_add|i_sub|i_addi|i_slt|i_slti|i_and|i_or|i_nor|i_xor|i_andi|i_ori|i_xori|i_mfhi|i_mflo|i_lui|i_sll|i_srl|i_sra|i_jal =>
                        write_reg       <= '1';
                        write_reg_num   <= ctrl_in.write_reg_num;
                        write_reg_data  <= ctrl_in.alu_output;
                        
                    when i_lw =>
                        write_reg       <= '1';
                        write_reg_num   <= ctrl_in.write_reg_num;
                        write_reg_data  <= ctrl_in.mem_output;
                        
                end case;
            end if;
        end if;
    end process;

end stage_wb_arch;
