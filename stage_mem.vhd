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
        flush           : in std_logic;
        ctrl_in         : in CTRL_TYPE;
        ctrl_out        : out CTRL_TYPE;
        results_ex_in   : in RESULTS_EX_TYPE;
        results_ex_out  : out RESULTS_EX_TYPE;
        results_mem_out : out RESULTS_MEM_TYPE
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
    
    mem_write <= '1' when ctrl_in.instruct_type = i_write_mem else '0';
    
    --8192 words * 4 bytes/word = 32768 bytes
    main_memory_inst: memory generic map(false, 8192) port map (
        reset => reset,
        clock => clock,
        mem_dump => dump,
        mem_address => results_ex_in.output,
        mem_write => mem_write,
        mem_write_data => results_ex_in.passthrough,
        mem_read_data => results_mem_out.output
    );
    
    --main behaviors
    main_proc: process(clock)
    begin
        if falling_edge(clock) then
            if (reset = '1' or flush = '1' or ctrl_in.instruct_type = i_no_op) then
                results_mem_out.output <= x"00000000";
                ctrl_out.instruct_type <= i_no_op;
            else
                --pass along the signals
                ctrl_out <= ctrl_in;
                results_ex_out <= results_ex_in;
            end if;
        end if;
        
    end process;

end stage_mem_arch;
