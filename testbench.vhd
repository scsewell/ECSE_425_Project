library ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end testbench;

architecture testbench_arch of testbench is

    --Simulation constants
    constant clk_period : time := 1 ns;
    
    component processor is
        port (
            reset : in std_logic;
            clock : in std_logic
        );
    end component;

    --The input signals with their initial values
    signal clock: std_logic := '0';
    signal reset: std_logic := '0';

begin
    inst0: processor port map(
        clock => clock,
        reset => reset
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
        reset <= '1';
        wait for 1 * clk_period;
        reset <= '0';
    
        wait;
    end process sim_process;
end;
