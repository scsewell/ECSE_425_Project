library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

--Manages access and modification of register values.
--R0 is always zero, even after attempting to write to it. 
entity registers is
    port (
        reset               : in std_logic;
        clock               : in std_logic;
        reg_dump            : in std_logic;
        reg_write_num       : in std_logic_vector(4 downto 0);
        reg_write_alu       : in std_logic;
        reg_write_alu_data  : in std_logic_vector(31 downto 0);
        reg_write_mem       : in std_logic;
        reg_write_mem_data  : in std_logic_vector(31 downto 0);
        reg_read_num0       : in std_logic_vector(4 downto 0);
        reg_read_num1       : in std_logic_vector(4 downto 0);
        reg_read_data0      : out std_logic_vector(31 downto 0);
        reg_read_data1      : out std_logic_vector(31 downto 0)
    );
end registers;

architecture registers_arch of registers is

    type Regs is array(31 downto 0) of std_logic_vector(31 downto 0);
    
    signal reg_block: Regs;
    
begin

    --main behaviors
    write_proc: process(clock)
    begin
        if rising_edge(clock) then
            if (reset = '1') then
                --initialize all registers to zero
                for i in 0 to 31 loop
                    reg_block(i) <= x"00000000";
                end loop;
                
                --initialize output
                reg_read_data0 <= x"00000000";
                reg_read_data1 <= x"00000000";
                
            else
                --if writing store the word at the given register, unless the register is $0
                if (reg_write_alu = '1' and reg_write_num /= "00000") then
                    reg_block(to_integer(unsigned(reg_write_num))) <= reg_write_alu_data;
                end if;
                
                if (reg_write_mem = '1' and reg_write_num /= "00000") then
                    reg_block(to_integer(unsigned(reg_write_num))) <= reg_write_mem_data;
                end if;
                
                --read the registers at the read addresses
                reg_read_data0 <= reg_block(to_integer(unsigned(reg_read_num0)));
                reg_read_data1 <= reg_block(to_integer(unsigned(reg_read_num1)));
                
            end if;
        end if;
    end process;
    
    --register dump behaviors
    dump_proc: process(reg_dump)
    
        file f_out      : text;
        variable f_line : line;
    
    begin
        if falling_edge(reg_dump) then
        
            --open file to write the register contents to
            file_open(f_out, "register_file.txt", write_mode);
            
            --write the registers to the file
            for i in 0 to 31 loop
                write(f_line, to_bitvector(reg_block(i)), right, 31);
                writeline(f_out, f_line);
            end loop;
            
            --close the file
            file_close(f_out);
            
        end if;
    end process;
    
end registers_arch;