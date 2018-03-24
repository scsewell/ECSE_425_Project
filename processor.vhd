library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
    port (
        reset   : in std_logic;
        clock   : in std_logic;
        dump    : in std_logic;
        test    : out std_logic_vector (31 downto 0)
    );
end processor;

architecture processor_arch of processor is
    
    --import all components
    component mux is
        generic (
            bus_width : integer --the number of bits in the inputs and output
        );
        port (
            s   : in std_logic;
            i0  : in std_logic_vector (bus_width-1 downto 0);
            i1  : in std_logic_vector (bus_width-1 downto 0);
            o   : out std_logic_vector (bus_width-1 downto 0)
        );
    end component;
    
    component pc is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            next_address    : in std_logic_vector (31 downto 0);
            current_address : out std_logic_vector (31 downto 0)
        );
    end component;

    component registers
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            reg_dump        : in std_logic;
            reg_write       : in std_logic;
            reg_write_num   : in std_logic_vector (4 downto 0);
            reg_write_data  : in std_logic_vector (31 downto 0);
            reg_read_num0   : in std_logic_vector (4 downto 0);
            reg_read_num1   : in std_logic_vector (4 downto 0);
            reg_read_data0  : out std_logic_vector (31 downto 0);
            reg_read_data1  : out std_logic_vector (31 downto 0)
        );
    end component;
    
    component memory
        generic (
            is_instruction  : boolean; --declares if this memory hold instructions
            ram_size        : integer --the number of elements in the memory
        );
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            mem_dump        : in std_logic;
            mem_address     : in std_logic_vector (31 downto 0);
            mem_write       : in std_logic;
            mem_write_data  : in std_logic_vector (31 downto 0);
            mem_read_data   : out std_logic_vector (31 downto 0)
        );
    end component;
    
    --program counter signals
    signal pc_address       : std_logic_vector (31 downto 0);
    signal next_pc_address  : std_logic_vector (31 downto 0);
    
    --instruction signals
    signal instruction      : std_logic_vector (31 downto 0);
    signal i_opcode         : std_logic_vector (5 downto 0);
    signal i_rs             : std_logic_vector (4 downto 0);
    signal i_rt             : std_logic_vector (4 downto 0);
    signal i_rd             : std_logic_vector (4 downto 0);
    signal i_shamt          : std_logic_vector (4 downto 0);
    signal i_funct          : std_logic_vector (5 downto 0);
    signal i_immediate      : std_logic_vector (15 downto 0);
    signal i_address        : std_logic_vector (25 downto 0);
    
    --register signals
    signal r_rs   : std_logic_vector (31 downto 0);
    signal r_rt   : std_logic_vector (31 downto 0);
    
begin
    --program counter:
    pc0: pc port map (
        reset => reset,
        clock => clock,
        next_address => next_pc_address,
        current_address => pc_address
    );
    
    --instruction memory:
    --max program length is 1024 instructions
    instruction_memory: memory generic map(true, 1024) port map (
        reset => reset,
        clock => clock,
        mem_dump => dump,
        mem_address => pc_address,
        mem_write => '0',
        mem_write_data => std_logic_vector(to_unsigned(0, 32)),
        mem_read_data => instruction
    );
    
    test <= instruction;
    
    --extract the various parts of the instruction
    i_opcode <= instruction(31 downto 26);
    i_rs <= instruction(25 downto 21);
    i_rt <= instruction(20 downto 16);
    i_rd <= instruction(15 downto 11);
    i_shamt <= instruction(10 downto 6);
    i_funct <= instruction(5 downto 0);
    i_immediate <= instruction(15 downto 0);
    i_address <= instruction(25 downto 0);
    
    --registers:
    regs: registers port map (
        reset => reset,
        clock => clock,
        reg_dump => dump,
        reg_write => '0',
        reg_write_num => std_logic_vector(to_unsigned(0, 5)),
        reg_write_data => std_logic_vector(to_unsigned(0, 32)),
        reg_read_num0 => i_rs,
        reg_read_num1 => i_rt,
        reg_read_data0 => r_rs,
        reg_read_data1 => r_rt
    );
    
    --main memory:
    --8192 words * 4 bytes/word = 32768 bytes
    --main_memory: memory generic map(false, 8192) port map (
    --    reset => reset,
    --    clock => clock,
    --    mem_dump => dump,
    --    mem_address =>,
    --    mem_write =>,
    --    mem_write_data =>,
    --    mem_read_data =>
    --);
    
    main_proc: process (clock)
    begin
        if reset = '1' then
            next_pc_address <= std_logic_vector(to_unsigned(4, 32));
            
        elsif rising_edge(clock) then
            --increment pc to next instruction
            next_pc_address <= std_logic_vector(unsigned(next_pc_address) + to_unsigned(4, 32));
            
        end if;
    end process;
    
end processor_arch;