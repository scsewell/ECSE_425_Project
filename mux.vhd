library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Implememnts a generic multiplexer.
entity mux is
    generic (
        bus_width : integer --the number of bits in the inputs and output
    );
    port (
        s   : in std_logic;
        i0  : in std_logic_vector(bus_width-1 downto 0);
        i1  : in std_logic_vector(bus_width-1 downto 0);
        o   : out std_logic_vector(bus_width-1 downto 0)
    );
end mux;

architecture mux_arch of mux is
begin
    o <= i1 when s = '1' else i0;
end mux_arch;