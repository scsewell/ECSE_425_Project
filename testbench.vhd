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
            reset   : in std_logic;
            clock   : in std_logic;
            dump    : in std_logic;
            test    : out std_logic_vector (31 downto 0)
        );
    end component;

    --The input signals with their initial values
    signal clock: std_logic := '0';
    signal reset: std_logic := '0';
    signal dump: std_logic := '0';
    signal test: std_logic_vector (31 downto 0) := std_logic_vector(to_unsigned(0, 32));

begin
    processor_instance: processor port map(
        clock => clock,
        reset => reset,
        dump => dump,
        test => test
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
        wait for clk_period;
        reset <= '0';
    
        --at the end of the simulation dump the memory
        wait for 9990 * clk_period;
        dump <= '1';
        wait for clk_period;
        dump <= '0';
        
        wait;
    end process sim_process;
end;
