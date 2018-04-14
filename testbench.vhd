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
            use_branch_predict  : in std_logic
        );
    end component;
    
    --The input signals with their initial values
    signal clock                : std_logic := '0';
    signal reset                : std_logic := '0';
    signal dump                 : std_logic := '0';
    signal use_branch_predict   : std_logic := '0';
    
begin
    processor_instance: processor port map(
        clock => clock,
        reset => reset,
        dump => dump,
        use_branch_predict => use_branch_predict
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
        --reset the processor and enable branch prediction
        use_branch_predict <= '1';
        reset <= '1';
        wait for 1250 ps;
        reset <= '0';
        wait for 750 ps;
        
        --wait for the program to finish execution
        wait for 998 * clk_period;
        
        --reset the processor and disable branch prediction
        use_branch_predict <= '0';
        reset <= '1';
        wait for 1250 ps;
        reset <= '0';
        wait for 750 ps;
        
        --wait for the program to finish execution
        wait for 998 * clk_period;
        
        --at the end of the simulation dump the memory and register files
        dump <= '1';
        wait for clk_period;
        dump <= '0';
        
        wait;
    end process sim_process;
end;
