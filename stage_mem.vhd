library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the memory stage of the pipeline.
entity stage_mem is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        dump            : in std_logic;
        ctrl_in         : in CTRL_TYPE;
        ctrl_out        : out CTRL_TYPE
    );
end stage_mem;

architecture stage_mem_arch of stage_mem is

    --import memory
    component memory
        generic(
            is_instruction  : boolean; --declares if this memory holds instructions
            ram_size        : integer --the number of elements in the memory
        );
        port(
            reset           : in std_logic;
            clock           : in std_logic;
            mem_dump        : in std_logic;
            mem_address     : in std_logic_vector(31 downto 0);
            mem_write       : in std_logic;
            mem_write_data  : in std_logic_vector(31 downto 0);
            mem_read_data   : out std_logic_vector(31 downto 0)
        );
    end component;

    signal mem_write : std_logic;
    
begin
    
    mem_write <= '1' when ctrl_in.instruct_type = i_sw else '0';
    
    --8192 words * 4 bytes/word = 32768 bytes
    main_memory_inst: memory generic map(false, 8192) port map (
        reset => reset,
        clock => clock,
        mem_dump => dump,
        mem_address => ctrl_in.alu_output,
        mem_write => mem_write,
        mem_write_data => ctrl_in.mem_write_val,
        mem_read_data => ctrl_out.mem_output
    );
    
    --main behaviors
    main_proc: process(clock)
    begin
        if falling_edge(clock) then
            if (reset = '1' or ctrl_in.instruct_type = i_no_op) then
                ctrl_out.pc             <= x"00000000";
                ctrl_out.instruction    <= x"00000000";
                ctrl_out.instruct_type  <= i_no_op;
                ctrl_out.alu_op         <= alu_add;
                ctrl_out.alu_output     <= x"00000000";
                ctrl_out.mem_write_val  <= x"00000000";
                ctrl_out.write_reg_num  <= "00000";
                
            else
                --pass along the control signals
                ctrl_out.pc             <= ctrl_in.pc;
                ctrl_out.instruction    <= ctrl_in.instruction;
                ctrl_out.instruct_type  <= ctrl_in.instruct_type;
                ctrl_out.alu_op         <= ctrl_in.alu_op;
                ctrl_out.alu_output     <= ctrl_in.alu_output;
                ctrl_out.mem_write_val  <= ctrl_in.mem_write_val;
                ctrl_out.write_reg_num  <= ctrl_in.write_reg_num;
                
            end if;
        end if;
    end process;

end stage_mem_arch;
