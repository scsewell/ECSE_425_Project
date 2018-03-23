library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Implememnts the program counter.
entity pc is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        next_address    : in std_logic_vector (31 downto 0);
        current_address : out std_logic_vector (31 downto 0)
    );
end pc;

architecture pc_arch of pc is
begin
    --main behaviors
    main_proc: process(clock)
    begin
        if reset = '1' then
            current_address <= std_logic_vector(to_unsigned(0, 32));
        elsif rising_edge(clock) then
            current_address <= next_address;
        end if;
    end process;
    
end pc_arch;