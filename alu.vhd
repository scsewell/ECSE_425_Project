library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implememnts the arithmatic logic unit.
entity alu is
    port (
        reset   : in std_logic;
        op      : in ALU_OP_TYPE;
        input0  : in std_logic_vector(31 downto 0);
        input1  : in std_logic_vector(31 downto 0);
        output  : out std_logic_vector(31 downto 0)
    );
end alu;

architecture alu_arch of alu is

    --the Hi and Lo registers store the outputs of division and multiplication
    signal r_hi     : std_logic_vector(31 downto 0);
    signal r_lo     : std_logic_vector(31 downto 0);
    
begin

    --main behaviors
    main_proc: process(reset, op, input0, input1)
    
        variable result : std_logic_vector(31 downto 0);
        
    begin
        if reset = '1' then
            --initialize signals
            r_hi <= x"00000000";
            r_lo <= x"00000000";
            output <= x"00000000";
            
        else
            case op is
                --arithmatic
                when alu_add => result := std_logic_vector(signed(input0) + signed(input1));
                when alu_sub => result := std_logic_vector(signed(input0) - signed(input1));
                
                when alu_mul =>
                    r_hi <= std_logic_vector(resize(shift_right(signed(input0) * signed(input1), 32), r_hi'length));
                    r_lo <= std_logic_vector(resize(signed(input0) * signed(input1), r_lo'length));
                
                when alu_div =>
                    r_hi <= std_logic_vector(signed(input0) rem signed(input1));
                    r_lo <= std_logic_vector(signed(input0) / signed(input1));
                    
                when alu_slt =>
                    if (signed(input0) < signed(input1)) then  
                        result := x"00000001";
                    else
                        result := x"00000000";
                    end if;
                
                --logical
                when alu_and => result := input0 and input1;
                when alu_or  => result := input0 or  input1;
                when alu_nor => result := input0 nor input1;
                when alu_xor => result := input0 xor input1;
                
                --transfer
                when alu_hi => result := r_hi;
                when alu_lo => result := r_lo;
                when alu_lu => result := std_logic_vector(shift_left(unsigned(input0), 16));
                
                --shift
                when alu_sll => result := std_logic_vector(shift_left(unsigned(input0), to_integer(unsigned(input1))));
                when alu_srl => result := std_logic_vector(shift_right(unsigned(input0), to_integer(unsigned(input1))));
                when alu_sra => result := std_logic_vector(shift_right(signed(input0), to_integer(unsigned(input1))));
            end case;
            
            --set operation output
            output <= result;
            
        end if;
    end process;
    
end alu_arch;