LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY signextender IS
    PORT (
        sign_in: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        sign_out: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END signextender;

ARCHITECTURE Behavioral OF signextender IS

BEGIN
process (sign_in)
begin
	--One sign extend at a time--
	if sign_in(15) = '1' then
		sign_out(31 downto 16) <= "1000000000000000";
	else
		sign_out(31 downto 16) <= "0000000000000000";
	end if;
	sign_out(15 downto 0) <= sign_in;
end process;
END Behavioral;
