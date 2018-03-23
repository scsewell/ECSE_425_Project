library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port (
        reset   : in std_logic;
        clock   : in std_logic;
        dump    : in std_logic
    );
end processor;

architecture processor_arch of processor is
    
    signal reg_write        : std_logic;
    signal reg_write_num    : integer range 0 to 31;
    signal reg_write_data   : std_logic_vector (31 downto 0);
    signal reg_read_num0    : integer range 0 to 31;
    signal reg_read_num1    : integer range 0 to 31;
    signal reg_read_data0   : std_logic_vector (31 downto 0);
    signal reg_read_data1   : std_logic_vector (31 downto 0);
    
    signal mem_address      : integer range 0 to 31;
    signal mem_write        : std_logic;
    signal mem_write_data   : std_logic_vector (31 downto 0);
    signal mem_read_data    : std_logic_vector (31 downto 0);
    
	component registers
        generic
        (
            register_size   : integer := 32; --the size of each register in bits
            register_count  : integer := 32 --the number of registers
        );
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            reg_dump        : in std_logic;
            reg_write       : in std_logic;
            reg_write_num   : in integer range 0 to register_count-1;
            reg_write_data  : in std_logic_vector (register_size-1 downto 0);
            reg_read_num0   : in integer range 0 to register_count-1;
            reg_read_num1   : in integer range 0 to register_count-1;
            reg_read_data0  : out std_logic_vector (register_size-1 downto 0);
            reg_read_data1  : out std_logic_vector (register_size-1 downto 0)
        );
	end component;
    
	component memory
        generic
        (
            is_instruction  : boolean; --declares if this memory hold instructions
            element_size    : integer; --the size of each element in bits
            ram_size        : integer --the number of elements in the memory
        );
		port (
            reset           : in std_logic;
            clock           : in std_logic;
            mem_dump        : in std_logic;
            mem_address     : in integer range 0 to ram_size-1;
            mem_write       : in std_logic;
            mem_write_data  : in std_logic_vector (element_size-1 downto 0);
            mem_read_data   : out std_logic_vector (element_size-1 downto 0)
		);
	end component;
    
begin
    
    --registers:
	regs: registers port map (
		reset => reset,
		clock => clock,
		reg_dump => dump,
		reg_write => reg_write,
		reg_write_num => reg_write_num,
		reg_write_data => reg_write_data,
		reg_read_num0 => reg_read_num0,
		reg_read_num1 => reg_read_num1,
		reg_read_data0 => reg_read_data0,
		reg_read_data1 => reg_read_data1
	);
    
    --main memory:
    --8192 elements * 4 bytes/element = 32768 bytes
	main_memory: memory generic map(false, 32, 8192) port map (
		reset => reset,
		clock => clock,
		mem_dump => dump,
		mem_address => mem_address,
		mem_write => mem_write,
		mem_write_data => mem_write_data,
		mem_read_data => mem_read_data
	);
    
    --instruction memory:
    --each instruction is a word, max program length is 1024 instructions
	instruction_memory: memory generic map(true, 32, 1024) port map (
		reset => reset,
		clock => clock,
		mem_dump => dump,
		mem_address => mem_address,
		mem_write => mem_write,
		mem_write_data => mem_write_data,
		mem_read_data => mem_read_data
	);
    
    process (clock)
    begin
        if rising_edge(clock) then
        end if;
    end process;
end processor_arch;