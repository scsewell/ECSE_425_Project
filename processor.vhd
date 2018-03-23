library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port (
        reset : in std_logic;
        clock : in std_logic
    );
end processor;

architecture processor_arch of processor is

begin
    process (clock)
    begin
        if reset = '1' then
            
        elsif rising_edge(clock) then
        end if;
    end process;
end processor_arch;