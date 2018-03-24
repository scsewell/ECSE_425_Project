library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Implememnts the arithmatic logic unit.
entity alu is
    port (
        reset   : in std_logic;
        clock   : in std_logic;
        op      : in std_logic_vector (3 downto 0);
        input0  : in std_logic_vector (31 downto 0);
        input1  : in std_logic_vector (31 downto 0);
        output  : out std_logic_vector (31 downto 0)
    );
end alu;

architecture alu_arch of alu is

    --the Hi and Lo registers store the outputs of division and multiplication
    signal r_hi     : std_logic_vector (31 downto 0);
    signal r_lo     : std_logic_vector (31 downto 0);

begin
    --main behaviors
    main_proc: process(clock)
    begin
        if reset = '1' then
            --initialize the hi/low registers to 0
            r_hi <= std_logic_vector(to_unsigned(0, 32));
            r_lo <= std_logic_vector(to_unsigned(0, 32));
        
        elsif rising_edge(clock) then
            
            case op is
                when "0000" => --bitwise and
                    output <= std_logic_vector(input0 and input1);
                    
                when "0001" => --bitwise or
                    output <= std_logic_vector(input0 or input1);
                    
                when "0010" => --bitwise nor
                    output <= std_logic_vector(signed(input0) nor signed(input1));
                    
                when "0011" => --bitwise xor
                    output <= std_logic_vector(signed(input0) xor signed(input1));
                    
                when "0100" => --shift left logical
                    output <= std_logic_vector(shift_left(unsigned(input0), to_integer(unsigned(input1))));
                    
                when "0101" => --shift right logical
                    output <= std_logic_vector(shift_right(unsigned(input0), to_integer(unsigned(input1))));
                    
                when "0110" => --shift right arithmetic
                    output <= std_logic_vector(shift_right(signed(input0), to_integer(unsigned(input1))));
                    
                when "1000" => --addition
                    output <= std_logic_vector(signed(input0) + signed(input1));
                    
                when "1001" => --subtraction
                    output <= std_logic_vector(signed(input0) - signed(input1));
                    
                when "1010" => --multiplication
                    r_hi <= std_logic_vector(shift_right(signed(input0) * signed(input1), 32));
                    r_lo <= std_logic_vector(signed(input0) * signed(input1));
                    
                when "1011" => --division
                    r_hi <= std_logic_vector(signed(input0) rem signed(input1));
                    r_lo <= std_logic_vector(signed(input0) / signed(input1));
                
                when "1100" => --get hi
                    output <= r_hi;
                    
                when "1101" => --get lo
                    output <= r_lo;
                
                when others =>
                    
            end case;
        
        end if;
    end process;
    
end alu_arch;