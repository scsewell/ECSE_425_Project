library ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

entity testbench is
end testbench;

architecture testbench_arch of testbench is

    --Simulation constants
    constant clk_period : time := 1 ns;
    
    component processor is
        port (
            reset               : in std_logic;
            clock               : in std_logic;
            dump                : in std_logic;
            use_branch_predict  : in std_logic;
            program_name        : in string
        );
    end component;
    
    --The input signals with their initial values
    signal clock                : std_logic := '0';
    signal reset                : std_logic := '0';
    signal dump                 : std_logic := '0';
    signal use_branch_predict   : std_logic := '0';
    signal program_name         : string(1 to 12) := "program1.txt";
    
begin
    processor_instance: processor port map(
        clock => clock,
        reset => reset,
        dump => dump,
        use_branch_predict => use_branch_predict,
        program_name => program_name
    );

    --System clock
    clk_process : process
    begin
        clock <= '0';
        wait for clk_period / 2;
        clock <= '1';
        wait for clk_period / 2;
    end process;
     
    --Main simulation
    sim_process: process
    begin
        --Set the program to run. The name must be 12 characters long.
        program_name <= "program1.txt";
        
        --Enable the branch prediction optimization.
        use_branch_predict <= '1';
        
        --Reset the processor.
        reset <= '1';
        wait for 1250 ps;
        reset <= '0';
        wait for 750 ps;
        
        --Run the processor for 10000 clock cycles, as per the project specification.
        wait for 10000 * clk_period;
        
        --Run the program again with branch prediction disabled for comparison.
        use_branch_predict <= '0';
        
        --Reset the processor.
        reset <= '1';
        wait for 1250 ps;
        reset <= '0';
        wait for 750 ps;
        
        --Run the processor for 10000 clock cycles, as per the project specification.
        wait for 10000 * clk_period;
        
        --At the end of the simulation dump the memory and register files.
        dump <= '1';
        wait for clk_period;
        dump <= '0';
        
        wait;
    end process sim_process;
end;
