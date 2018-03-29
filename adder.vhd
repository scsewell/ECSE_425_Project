library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port(
        counter     : in std_logic_vector(31 downto 0);
        increment   : in integer;
        adder_out   : out std_logic_vector(31 downto 0)
    );
end adder;

architecture adder_arch of adder is
begin

    adder_out <= std_logic_vector(to_unsigned(to_integer(unsigned(counter) + increment), adder_out'length));

end adder_arch;