library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

entity processor is
    port (
        reset               : in std_logic;
        clock               : in std_logic;
        dump                : in std_logic;
        use_branch_predict  : in std_logic --if true enables branch prediction
    );
end processor;

architecture processor_arch of processor is
    

    --fetch stage
    component stage_if is
        port (
            reset               : in std_logic;
            clock               : in std_logic;
            dump                : in std_logic;
            use_branch_predict  : in std_logic;
            stall               : in std_logic;
            use_new_pc          : in std_logic;
            new_pc              : in std_logic_vector(31 downto 0);
            new_pc_src_address  : in std_logic_vector(31 downto 0);
            instruction         : out std_logic_vector(31 downto 0);
            pc                  : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal instruction  : std_logic_vector(31 downto 0);
    signal pc           : std_logic_vector(31 downto 0);
    
    --registers
    component registers
        port (
            reset               : in std_logic;
            clock               : in std_logic;
            reg_dump            : in std_logic;
            reg_write_num       : in std_logic_vector(4 downto 0);
            reg_write_alu       : in std_logic;
            reg_write_alu_data  : in std_logic_vector(31 downto 0);
            reg_write_mem       : in std_logic;
            reg_write_mem_data  : in std_logic_vector(31 downto 0);
            reg_read_num0       : in std_logic_vector(4 downto 0);
            reg_read_num1       : in std_logic_vector(4 downto 0);
            reg_read_data0      : out std_logic_vector(31 downto 0);
            reg_read_data1      : out std_logic_vector(31 downto 0)
        );
    end component;
    
    signal rs_value     : std_logic_vector(31 downto 0);
    signal rt_value     : std_logic_vector(31 downto 0);
    
    --decode stage
    component stage_id is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            instruction     : in std_logic_vector(31 downto 0);
            pc              : in std_logic_vector(31 downto 0);
            stall_in        : in std_logic;
            ctrl_ex         : in CTRL_TYPE;
            ctrl_mem        : in CTRL_TYPE;
            ctrl_wb         : in CTRL_TYPE;
            rs_num          : out std_logic_vector(4 downto 0);
            rt_num          : out std_logic_vector(4 downto 0);
            stall           : out std_logic;
            ctrl            : out CTRL_TYPE
        );
    end component;
    
    signal rs_num   : std_logic_vector(4 downto 0);
    signal rt_num   : std_logic_vector(4 downto 0);
    signal stall    : std_logic;
    signal ctrl_ex  : CTRL_TYPE;
    
    --execution stage
    component stage_ex is
        port (
            reset               : in std_logic;
            clock               : in std_logic;
            use_branch_predict  : in std_logic;
            rs                  : in std_logic_vector(31 downto 0);
            rt                  : in std_logic_vector(31 downto 0);
            ctrl_in             : in CTRL_TYPE;
            use_new_pc          : out std_logic;
            new_pc              : out std_logic_vector(31 downto 0);
            new_pc_src_address  : out std_logic_vector(31 downto 0);
            ctrl_out            : out CTRL_TYPE
        );
    end component;
    
    signal use_new_pc           : std_logic;
    signal new_pc               : std_logic_vector(31 downto 0);
    signal new_pc_src_address   : std_logic_vector(31 downto 0);
    signal ctrl_mem             : CTRL_TYPE;
    
    --memory/write back stage
    component stage_mem is
        port (
            reset           : in std_logic;
            clock           : in std_logic;
            dump            : in std_logic;
            ctrl_in         : in CTRL_TYPE;
            write_reg_num   : out std_logic_vector(4 downto 0);
            write_alu_reg   : out std_logic;
            write_alu_data  : out std_logic_vector(31 downto 0);
            write_mem_reg   : out std_logic;
            write_mem_data  : out std_logic_vector(31 downto 0);
            ctrl_out        : out CTRL_TYPE
        );
    end component;
    
    signal write_reg_num    : std_logic_vector(4 downto 0);
    signal write_alu_reg    : std_logic;
    signal write_alu_data   : std_logic_vector(31 downto 0);
    signal write_mem_reg    : std_logic;
    signal write_mem_data   : std_logic_vector(31 downto 0);
    signal ctrl_wb          : CTRL_TYPE;
    
begin

    --instruction fetch stage
    stage_if_inst: stage_if port map (
        reset => reset,
        clock => clock,
        dump => dump,
        use_branch_predict => use_branch_predict,
        stall => stall,
        use_new_pc => use_new_pc,
        new_pc => new_pc,
        new_pc_src_address => new_pc_src_address,
        instruction => instruction,
        pc => pc
    );
    
    --instruction decode stage
    stage_id_inst: stage_id port map (
        reset => reset,
        clock => clock,
        pc => pc,
        instruction => instruction,
        stall_in => stall,
        ctrl_ex => ctrl_ex,
        ctrl_mem => ctrl_mem,
        ctrl_wb => ctrl_wb,
        rs_num => rs_num,
        rt_num => rt_num,
        stall => stall,
        ctrl => ctrl_ex
    );
    
    --registers
    regs: registers port map (
        reset => reset,
        clock => clock,
        reg_dump => dump,
        reg_write_num => write_reg_num,
        reg_write_alu => write_alu_reg,
        reg_write_alu_data => write_alu_data,
        reg_write_mem => write_mem_reg,
        reg_write_mem_data => write_mem_data,
        reg_read_num0 => rs_num,
        reg_read_num1 => rt_num,
        reg_read_data0 => rs_value,
        reg_read_data1 => rt_value
    );
    
    --execution stage
    stage_ex_inst: stage_ex port map (
        reset => reset,
        clock => clock,
        use_branch_predict => use_branch_predict,
        rs => rs_value,
        rt => rt_value,
        ctrl_in => ctrl_ex,
        use_new_pc => use_new_pc,
        new_pc_src_address => new_pc_src_address,
        new_pc => new_pc,
        ctrl_out => ctrl_mem
    );
    
    --memory/write back stage
    stage_mem_inst: stage_mem port map (
        reset => reset,
        clock => clock,
        dump => dump,
        ctrl_in => ctrl_mem,
        write_reg_num => write_reg_num,
        write_alu_reg => write_alu_reg,
        write_alu_data => write_alu_data,
        write_mem_reg => write_mem_reg,
        write_mem_data => write_mem_data,
        ctrl_out => ctrl_wb
    );
    
end processor_arch;