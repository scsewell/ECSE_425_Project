library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

--The memory model used by our processor, implementing both instruction and program meory.
--For simplicity we use a word array as opposed to a byte array. We only need to support
--the load word and store word instructions, so this makes things easier. Additionally,
--latency is removed, with all operations completing in one cycle.
entity memory is
    generic (
        is_instruction  : boolean; --declares if this memory holds instructions
        ram_size        : integer --the number of elements in the memory
    );
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        mem_dump        : in std_logic;
        mem_address     : in std_logic_vector(31 downto 0);
        mem_write       : in std_logic;
        mem_write_data  : in std_logic_vector(31 downto 0);
        mem_read_data   : out std_logic_vector(31 downto 0)
    );
end memory;

architecture memory_arch of memory is

    type Mem is array(ram_size-1 downto 0) of std_logic_vector(31 downto 0);
    
    signal ram_block        : Mem;
    signal address_index    : unsigned(31 downto 0);
    
begin
    --The memory address to look up is provided in bytes, but we index our memory array by words
    --so we need to divide the address by 4 to get the correct index in the memory array;
    address_index <= shift_right(unsigned(mem_address), 2);
    
    --main behaviors
    main_proc: process(clock)
    
        file f_in           : text;
        variable f_line     : line;
        variable f_lineVal  : bit_vector(31 downto 0);
        
    begin
        if reset = '1' then
        
            --if this is instruction memory open the program file and read the instructions
            if is_instruction then
                --open the program file
                file_open(f_in, "program.txt", read_mode);
                
                for i in 0 to ram_size-1 loop
                    --while there is a new line in the program load it into memory, otherwise initialize to 0
                    if not endfile(f_in) then
                        readline(f_in, f_line);
                        read(f_line, f_lineVal);
                        ram_block(i) <= to_stdlogicvector(f_lineVal);
                    else
                        ram_block(i) <= x"00000000";
                    end if;
                end loop;
                --close the program file
                file_close(f_in);
                
            else
                --initialize all entries to zero in main memory
                for i in 0 to ram_size-1 loop
                    ram_block(i) <= x"00000000";
                end loop;
            end if;
            
            --initizlize the output
            mem_read_data <= x"00000000";
            
        elsif falling_edge(clock) then
            
            --if writing store the word at the current address
            if mem_write = '1' then
                ram_block(to_integer(address_index)) <= mem_write_data;
            end if;
            
            --read the word at the current address if the address is valid
            if to_integer(address_index) < ram_size then
                mem_read_data <= ram_block(to_integer(address_index));
            end if;
        end if;
    end process;
    
    --memory dump behaviors
    dump_proc: process(mem_dump)
    
        file f_out              : text;
        variable f_line         : line;
    
    begin
        if falling_edge(mem_dump) then
        
            --open file to write the memory contents to with a different
            --name for main memory and instruction memory files
            if is_instruction then
                file_open(f_out, "instructionMemory.txt", write_mode);
            else
                file_open(f_out, "memory.txt", write_mode);
            end if;
            
            --write the memory contents to the file
            for i in 0 to ram_size-1 loop
                write(f_line, to_bitvector(ram_block(i)), right, 31);
                writeline(f_out, f_line);
            end loop;
            
            file_close(f_out);
            
        end if;
    end process;
    
end memory_arch;
