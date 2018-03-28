library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity writeBack is
port (memToReg_in: in std_logic;
	regWrite_in: in std_logic;
	regWrite_out: out std_logic;
	
	alu_in : in std_logic_vector (31 downto 0);
	mem_in: in std_logic_vector (31 downto 0);
	mux_out : out std_logic_vector (31 downto 0);
	write_addr_in: in std_logic_vector (4 downto 0);
	write_addr_out: out std_logic_vector (4 downto 0)
  );
end writeBack;

architecture behavioral of writeBack is

begin
process(alu_in, mem_in, memtoreg_in, regwrite_in)
begin
	write_addr_out <= write_addr_in;
	regWrite_out <= regWrite_in;

	case memToReg_in is
		--ALU--
		when '0' => 
			mux_out <= alu_in;
		--MEM--
		when '1' => 
			mux_out <= mem_in;
		when others => 
			mux_out <= "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
	end case;
end process;

end behavioral;
