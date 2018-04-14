library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

entity processor is
    port (
        reset   : in std_logic;
        clock   : in std_logic;
        dump    : in std_logic
    );
end processor;

architecture processor_arch of processor is
    
    --fetch stage
    component stage_if is
        port (
            reset       : in std_logic;
            clock       : in std_logic;
            dump        : in std_logic;
            stall       : in std_logic;
            use_new_pc  : in std_logic;
            new_pc      : in std_logic_vector(31 downto 0);
            instruction : out std_logic_vector(31 downto 0);
            pc          : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal instruction  : std_logic_vector(31 downto 0);
    signal pc           : std_logic_vector(31 downto 0);
    
    alias i_rs          : std_logic_vector(4 downto 0) is instruction(25 downto 21);
    alias i_rt          : std_logic_vector(4 downto 0) is instruction(20 downto 16);
    
    --registers
    component registers
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            reg_dump        : in std_logic;
            reg_write       : in std_logic;
            reg_write_num   : in std_logic_vector(4 downto 0);
            reg_write_data  : in std_logic_vector(31 downto 0);
            reg_read_num0   : in std_logic_vector(4 downto 0);
            reg_read_num1   : in std_logic_vector(4 downto 0);
            reg_read_data0  : out std_logic_vector(31 downto 0);
            reg_read_data1  : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal r_rs   : std_logic_vector(31 downto 0);
    signal r_rt   : std_logic_vector(31 downto 0);
    
    --decode stage
    component stage_id is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
			flush           : in std_logic;
            instruction     : in std_logic_vector(31 downto 0);
            pc              : in std_logic_vector(31 downto 0);
            stall_in        : in std_logic;
            ctrl_ex         : in CTRL_TYPE;
            ctrl_mem        : in CTRL_TYPE;
            ctrl_wb         : in CTRL_TYPE;
            stall           : out std_logic;
            ctrl            : out CTRL_TYPE
        );
    end component;
    
    signal stall    : std_logic;
    signal ctrl_ex  : CTRL_TYPE;
    
    --execution stage
    component stage_ex is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
			flush       	: in std_logic;
            rs              : in std_logic_vector(31 downto 0);
            rt              : in std_logic_vector(31 downto 0);
            ctrl_in         : in CTRL_TYPE;
            use_new_pc      : out std_logic;
            new_pc          : out std_logic_vector(31 downto 0);
            ctrl_out        : out CTRL_TYPE
        );
    end component;
    
    signal use_new_pc       : std_logic;
    signal new_pc           : std_logic_vector(31 downto 0);
    signal ctrl_mem         : CTRL_TYPE;
    
    --memory stage
    component stage_mem is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            dump            : in std_logic;
            ctrl_in         : in CTRL_TYPE;
            ctrl_out        : out CTRL_TYPE
        );
    end component;
    
    signal ctrl_wb         : CTRL_TYPE;
    
    --write back stage
    component stage_wb is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            ctrl_in         : in CTRL_TYPE;
            write_reg       : out std_logic;
            write_reg_num   : out std_logic_vector(4 downto 0);
            write_reg_data  : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal write_reg        : std_logic;
    signal write_reg_num    : std_logic_vector(4 downto 0);
    signal write_reg_data   : std_logic_vector(31 downto 0);
    
begin

    --instruction fetch stage
    stage_if_inst: stage_if port map (
        reset => reset,
        clock => clock,
        dump => dump,
        stall => stall,
        use_new_pc => use_new_pc,
        new_pc => new_pc,
        instruction => instruction,
        pc => pc
    );
    
    --registers
    regs: registers port map (
        reset => reset,
        clock => clock,
        reg_dump => dump,
        reg_write => write_reg,
        reg_write_num => write_reg_num,
        reg_write_data => write_reg_data,
        reg_read_num0 => i_rs,
        reg_read_num1 => i_rt,
        reg_read_data0 => r_rs,
        reg_read_data1 => r_rt
    );
    
    --instruction decode stage
    stage_id_inst: stage_id port map (
        reset => reset,
        clock => clock,
		flush => use_new_pc,
        pc => pc,
        instruction => instruction,
        stall_in => stall,
        ctrl_ex => ctrl_ex,
        ctrl_mem => ctrl_mem,
        ctrl_wb => ctrl_wb,
        stall => stall,
        ctrl => ctrl_ex
    );
    
    --execution stage
    stage_ex_inst: stage_ex port map (
        reset => reset,
        clock => clock,
		flush => use_new_pc,
        rs => r_rs,
        rt => r_rt,
        ctrl_in => ctrl_ex,
        use_new_pc => use_new_pc,
        new_pc => new_pc,
        ctrl_out => ctrl_mem
    );
    
    --memory stage
    stage_mem_inst: stage_mem port map (
        reset => reset,
        clock => clock,
        dump => dump,
        ctrl_in => ctrl_mem,
        ctrl_out => ctrl_wb
    );
    
    --write back stage
    stage_wb_inst: stage_wb port map (
        reset => reset,
        clock => clock,
        ctrl_in => ctrl_wb,
        write_reg => write_reg,
        write_reg_num => write_reg_num,
        write_reg_data => write_reg_data
    );
    
end processor_arch;