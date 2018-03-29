library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signExtender is
    port (
        sign_in     : in std_logic_vector(15 downto 0);
        sign_out    : out std_logic_vector(31 downto 0)
    );
end signExtender;

architecture signExtender_arch OF signExtender IS
begin
    sign_out <= std_logic_vector(resize(signed(sign_in), sign_out'length));
    
end signExtender_arch;
