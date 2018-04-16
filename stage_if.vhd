library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the instruction fetch stage of the pipeline.
--Uses a bimodal branch predictor to optimize the processor.
entity stage_if is
    port (
        reset               : in std_logic;
        clock               : in std_logic;
        dump                : in std_logic;
        use_branch_predict  : in std_logic;
        stall               : in std_logic;
        ignore_stall        : in std_logic;
        use_new_pc          : in std_logic;
        new_pc              : in std_logic_vector(31 downto 0);
        new_pc_src_address  : in std_logic_vector(31 downto 0);
        instruction         : out std_logic_vector(31 downto 0);
        pc                  : out std_logic_vector(31 downto 0)
    );
end stage_if;

architecture stage_if_arch of stage_if is

    --import memory
    component memory
        generic(
            is_instruction  : boolean; --declares if this memory holds instructions
            ram_size        : integer --the number of elements in the memory
        );
        port(
            reset           : in std_logic;
            clock           : in std_logic;
            mem_dump        : in std_logic;
            mem_address     : in std_logic_vector(31 downto 0);
            mem_write       : in std_logic;
            mem_write_data  : in std_logic_vector(31 downto 0);
            mem_read_data   : out std_logic_vector(31 downto 0)
        );
    end component;
    
    --Set the size of the branch prediction table. A larger table will perform better, but takes more space.
    --128 elements is a good number, enough to fit most predictions that are currently relevant.
    constant PREDICTION_TABLE_SIZE : integer := 128;
    
    --Define a bimodal branch prediction table with each element containing the following:
    --bits  0-29    : the address/4 of the branch instruction
    --bits  30-59   : the predicted address/4
    --bit   60      : the conviction bit indicating if the prediction is weak or strong
    --bit   61      : the bit that is set if the entry is valid
    type PREDICTION_TABLE_TYPE is array(PREDICTION_TABLE_SIZE-1 downto 0) of std_logic_vector(61 downto 0);
    
    --Create a table istance
    signal predictTable : PREDICTION_TABLE_TYPE;
    
    --the current program counter value
    signal current_pc   : std_logic_vector(31 downto 0);

begin
    
    pc <= current_pc;
    
    --Instantiate memory to hold programs.
    --max program length is 1024 instructions, so size memory appropriately
    instruction_mem: memory generic map(true, 1024) port map (
        reset => reset,
        clock => clock,
        mem_dump => dump,
        mem_address => current_pc,
        mem_write => '0',
        mem_write_data => x"00000000",
        mem_read_data => instruction
    );
    
    --main behaviors
    main_proc: process(clock)
        
        variable incrementCounter   : std_logic;
        variable entryIndex         : integer;
        variable predictEntry       : std_logic_vector(61 downto 0);
        
        --Get aliases for accessing and setting parts of a prediction table entry
        alias entrySrcAddress   : std_logic_vector(29 downto 0) is predictEntry(29 downto 0);
        alias entryPrediction   : std_logic_vector(29 downto 0) is predictEntry(59 downto 30);
        alias entryConviction   : std_logic is predictEntry(60);
        alias entryValid        : std_logic is predictEntry(61);
        
    begin
        if falling_edge(clock) then
            if (reset = '1') then
                --initialize the branch prediction table
                for i in 0 to PREDICTION_TABLE_SIZE-1 loop
                    predictTable(i) <= std_logic_vector(to_unsigned(0, 62));
                end loop;
                
                --initialize the output
                current_pc <= x"00000000";
                
            else
                if (use_branch_predict = '1') then
                
                    incrementCounter := '1';
                    
                    if (use_new_pc = '1') then
                        --access the entry in the branch prediction table associated with the branch instruction's address
                        entryIndex      := to_integer(unsigned(new_pc_src_address(8 downto 2)));
                        predictEntry    := predictTable(entryIndex);
                        
                        --now update or add the branch to the prediction table
                        if (entrySrcAddress = new_pc_src_address(31 downto 2)) then
                            
                            --load the new address if the prediction was wrong, otherwise increment the pc like usual
                            if (entryPrediction /= new_pc(31 downto 2)) then
                                current_pc <= new_pc;
                                incrementCounter := '0';
                            end if;
                            
                            --change the conviction bit and prediction as appropriate
                            if (entryPrediction = new_pc(31 downto 2) and entryConviction = '0') then
                                --The prediction was correct and weak, so the prediction is now strong
                                entryConviction := '1';
                                
                            elsif (entryPrediction /= new_pc(31 downto 2) and entryConviction = '1') then
                                --The prediction was wrong and strong, so the prediction is now weak
                                entryConviction := '0';
                                
                            elsif (entryPrediction /= new_pc(31 downto 2) and entryConviction = '0') then
                                --The prediction was wrong and weak, so change the prediction
                                entryConviction := '0';
                                entryPrediction := new_pc(31 downto 2);
                                
                            end if;
                            
                        else
                            --load the new address if the default behavior was wrong, otherwise increment the pc like usual
                            if (unsigned(current_pc(31 downto 2)) /= (unsigned(new_pc(31 downto 2)) + to_unsigned(4, 32))) then
                                current_pc <= new_pc;
                                incrementCounter := '0';
                            end if;
                            
                            --The entry in the table was not for this branch, so we replace it as a weak prediction
                            entrySrcAddress := new_pc_src_address(31 downto 2);
                            entryPrediction := new_pc(31 downto 2);
                            entryConviction := '0';
                            entryValid      := '1';
                            
                        end if;
                        
                        --update table entry
                        predictTable(entryIndex) <= predictEntry;
                    end if;
                    
                    --increment the counter to the next address and apply branch prediction if not stalling
                    if (incrementCounter = '1' and (stall /= '1' or ignore_stall = '1')) then
                        --access the entry in the branch prediction table associated with the last instruction's address
                        entryIndex      := to_integer(unsigned(current_pc(8 downto 2)));
                        predictEntry    := predictTable(entryIndex);
                    
                        --check if the branch prediction table entry is valid for the last instruction
                        if (entryValid = '1' and entrySrcAddress = current_pc(31 downto 2)) then
                        
                            --The entry contains a predicted branch address for the last instruction,
                            --so load the predicted address.
                            current_pc <= entryPrediction & "00";
                            
                        else
                            --the last instruction was not a branch with a prediction in the table,
                            --so increment the pc by 4 bytes by default.
                            current_pc <= std_logic_vector(unsigned(current_pc) + to_unsigned(4, 32));
                        
                        end if;
                    end if;
                
                else
                    --when branch prediction is disabled just to the obvious
                    if (use_new_pc = '1') then
                        current_pc <= new_pc;
                        
                    elsif (stall /= '1' or ignore_stall = '1') then
                        current_pc <= std_logic_vector(unsigned(current_pc) + to_unsigned(4, 32));
                        
                    end if;
                    
                end if;
            end if;
        end if;
    end process;
    
end stage_if_arch;
