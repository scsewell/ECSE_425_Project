library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the instruction fetch stage of the pipeline.
entity stage_if is
    port (
        reset       : in std_logic;
        clock       : in std_logic;
        dump        : in std_logic;
        stall       : in std_logic;
        use_new_pc  : in std_logic;
        new_pc      : in std_logic_vector(31 downto 0);
        instruction : out std_logic_vector(31 downto 0);
        pc          : out std_logic_vector(31 downto 0)
    );
end stage_if;

architecture stage_if_arch of stage_if is

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
    
    --signals
    signal current_pc   : std_logic_vector(31 downto 0);

begin
    
    pc <= current_pc;
    --instruction <= current_instruct;
    
    --max program length is 1024 instructions, so size memory appropriately
    instruction_mem: memory generic map(true, 1024) port map (
        reset => reset,
        clock => clock,
        mem_dump => dump,
        mem_address => current_pc,
        mem_write => '0',
        mem_write_data => std_logic_vector(to_unsigned(0, 32)),
        mem_read_data => instruction
    );
    
    --main behaviors
    main_proc: process(clock)
    begin
        if falling_edge(clock) then
            if (reset = '1') then
                --initialze program to first instruction on reset
                current_pc  <= x"00000000";
                
            elsif (stall = '1') then
                --do not increment pc
                
            elsif (use_new_pc = '1') then
                --load a new address if given
                current_pc  <= new_pc;
                
            else
                --by default increment by pc by 4 bytes
                current_pc  <= std_logic_vector(unsigned(current_pc) + to_unsigned(4, 32));
                
            end if;
        end if;
    end process;
    
end stage_if_arch;
