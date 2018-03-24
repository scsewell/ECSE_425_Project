library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
port(
	 operand : in integer;
	 counter : in std_logic_vector(31 downto 0);
	 adderOut : out std_logic_vector(31 downto 0)
	 );
end adder;

architecture adder_arch of adder is

signal add : integer;

begin

	add <= operand + to_integer(unsigned(counter)); 
	adderOut <= std_logic_vector(to_unsigned(add, adderOut'length));


	
end adder_arch;