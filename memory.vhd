library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--The memory model used by our processor. For simplicity we use a word array as opposed to a 
--byte array. We only need to support the load word and store word instructions, so this makes
--things easier. Additionally, memory delay is removed, with all operations completing in one 
--cycle.
entity memory is
    generic
    (
        element_size    : integer := 32; --the size of each element in bits
        ram_size        : integer := 8192 --8192 elements * 4 bytes/element = 32768 bytes
    );
    port
    (
        reset       : in std_logic;
        clock       : in std_logic;
        address     : in integer range 0 to ram_size-1;
        mem_write   : in std_logic;
        mem_read    : in std_logic;
        write_data  : in std_logic_vector (element_size-1 downto 0);
        read_data   : out std_logic_vector (element_size-1 downto 0)
    );
end memory;

architecture memory_arch of memory is
    type Mem is array(ram_size-1 downto 0) of std_logic_vector(element_size-1 downto 0);
    
    signal ram_block: Mem;
begin
    process(clock)
    begin
        if reset = '1' then
            --initialize all memory to zero
            for i in 0 to ram_size-1 loop
                ram_block(i) <= std_logic_vector(to_unsigned(0, element_size));
            end loop;
            
        elsif rising_edge(clock) then
            --if writing store the word at the given address
            if (mem_write = '1') then
                ram_block(address) <= write_data;
            end if;
            
            --if reading get the word at the given address
            if (mem_read = '1') then
                read_data <= ram_block(address);
            end if;
        end if;
        
    end process;
end memory_arch;
