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
            reset   : in std_logic;
            clock   : in std_logic;
            dump    : in std_logic
        );
    end component;

    --The input signals with their initial values
    signal clock: std_logic := '0';
    signal reset: std_logic := '0';
    signal dump: std_logic := '0';

begin
    processor_instance: processor port map(
        clock => clock,
        reset => reset,
        dump => dump
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
        --start the simulation with a reset
        reset <= '1';
        wait for 4250 ps;
        reset <= '0';
        wait for 750 ps;
    
        --at the end of the simulation dump the memory
        wait for 9990 * clk_period;
        dump <= '1';
        wait for clk_period;
        dump <= '0';
        
        wait;
    end process sim_process;
end;
