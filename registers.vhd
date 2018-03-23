library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Manages access and modification of 32 registers that can contain a word.
--R0 is always zero, even after attempting to write to it. 
entity registers is
    generic
    (
        register_size   : integer := 32; --the size of each register in bits
        register_count  : integer := 32 --the number of registers
    );
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        
        reg_write       : in std_logic;
        reg_write_num   : in integer range 0 to register_count-1;
        reg_write_data  : in std_logic_vector (register_size-1 downto 0);
        
        reg_read_num0   : in integer range 0 to register_count-1;
        reg_read_num1   : in integer range 0 to register_count-1;
        reg_read_data0  : out std_logic_vector (register_size-1 downto 0);
        reg_read_data1  : out std_logic_vector (register_size-1 downto 0)
    );
end registers;

architecture registers_arch of registers is
    type Regs is array(register_count-1 downto 0) of std_logic_vector(register_size-1 downto 0);
    
    signal reg_block: Regs;
begin
    process (clock)
    begin
        if reset = '1' then
            --initialize all registers to zero
            for i in 0 to register_count-1 loop
                reg_block(i) <= std_logic_vector(to_unsigned(0, register_size));
            end loop;
            
        elsif rising_edge(clock) then
            --if writing store the word at the given register
            if (reg_write = '1') then
                reg_block(reg_write_num) <= reg_write_data;
            end if;
            
            --make sure that R0 is always 0
            reg_block(0) <= std_logic_vector(to_unsigned(0, register_size));
            
            --read the registers at the read addresses
            reg_read_data0 <= reg_block(reg_read_num0);
            reg_read_data1 <= reg_block(reg_read_num1);
        end if;
    end process;
end registers_arch;