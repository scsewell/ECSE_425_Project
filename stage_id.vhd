library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.signals.all;

--Implements the instruction decode stage of the pipeline.
--Interprets the current instruction and creates control signals
--that will execute the expected behaviours for that instruction.
entity stage_id is
    port (
        reset           : in std_logic;
        clock           : in std_logic;
        pc              : in std_logic_vector(31 downto 0);
        instruction     : in std_logic_vector(31 downto 0);
        stall_in        : in std_logic;
        ignore_stall    : in std_logic;
        use_new_pc      : in std_logic;
        new_pc          : in std_logic_vector(31 downto 0);
        ctrl_ex         : in CTRL_TYPE;
        ctrl_mem        : in CTRL_TYPE;
        ctrl_wb         : in CTRL_TYPE;
        rs_num          : out std_logic_vector(4 downto 0);
        rt_num          : out std_logic_vector(4 downto 0);
        stall           : out std_logic;
        ctrl            : out CTRL_TYPE
    );
end stage_id;

architecture stage_id_arch of stage_id is
    
    signal last_pc          : std_logic_vector(31 downto 0);
    signal last_instruct    : std_logic_vector(31 downto 0);
    
begin

    --main behaviors
    main_proc: process(clock)
        
        variable current_pc             : std_logic_vector(31 downto 0);
        variable current_instruction    : std_logic_vector(31 downto 0);
        
        --extract the different parts of the instruction
        alias opcode    : std_logic_vector(5 downto 0) is current_instruction(31 downto 26);
        alias rs        : std_logic_vector(4 downto 0) is current_instruction(25 downto 21);
        alias rt        : std_logic_vector(4 downto 0) is current_instruction(20 downto 16);
        alias rd        : std_logic_vector(4 downto 0) is current_instruction(15 downto 11);
        alias funct     : std_logic_vector(5 downto 0) is current_instruction(5 downto 0);
        
        variable var_pc         : std_logic_vector(31 downto 0);
        variable var_instruct   : std_logic_vector(31 downto 0);
        variable instruct_type  : INSTRUCTION_TYPE;
        variable alu_op         : ALU_OP_TYPE;
        variable write_reg_num  : std_logic_vector(4 downto 0);
        variable src_reg1       : std_logic_vector(4 downto 0);
        variable src_reg2       : std_logic_vector(4 downto 0);
        
    begin
        if falling_edge(clock) then
            if (reset = '1') then
                
                last_pc             <= x"00000000";
                last_instruct       <= x"00000000";
                stall               <= '0';
                rs_num              <= "00000";
                rt_num              <= "00000";
                
                ctrl.pc             <= x"00000000";
                ctrl.instruction    <= x"00000000";
                ctrl.instruct_type  <= i_no_op;
                ctrl.alu_op         <= alu_add;
                ctrl.alu_output     <= x"00000000";
                ctrl.mem_write_val  <= x"00000000";
                ctrl.write_reg_num  <= "00000";
                
            else
                --get the current instruction
                if (stall_in = '1' and ignore_stall /= '1') then
                    current_pc          := last_pc;
                    current_instruction := last_instruct;
                else 
                    current_pc          := pc;
                    current_instruction := instruction;
                end if;
                
                --if the instruction is zero empty make sure it will no-op using an invalid code
                --(since usually it will interpret a 0 instruction as a sll on $0 by 0)
                if (current_instruction = x"00000000") then
                    current_instruction := x"FFFFFFFF";
                end if;
                
                --decode the instruction and determine approprite control signals
                case opcode is
                    when "000000" => --R type instructions
                        case funct is
                            when "100000" => --ADD
                                instruct_type  := i_add;
                                alu_op         := alu_add;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "100010" => --SUB
                                instruct_type  := i_sub;
                                alu_op         := alu_sub;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "011000" => --MUL
                                instruct_type  := i_mult;
                                alu_op         := alu_mul;
                                write_reg_num  := "00000";
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "011010" => --DIV
                                instruct_type  := i_div;
                                alu_op         := alu_div;
                                write_reg_num  := "00000";
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "101010" => --SLT
                                instruct_type  := i_slt;
                                alu_op         := alu_slt;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "100100" => --AND
                                instruct_type  := i_and;
                                alu_op         := alu_and;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "100101" => --OR
                                instruct_type  := i_or;
                                alu_op         := alu_or;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "100111" => --NOR
                                instruct_type  := i_nor;
                                alu_op         := alu_nor;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "100110" => --XOR
                                instruct_type  := i_xor;
                                alu_op         := alu_xor;
                                write_reg_num  := rd;
                                src_reg1       := rs;
                                src_reg2       := rt;
                                
                            when "010000" => --MFHI
                                instruct_type  := i_mfhi;
                                alu_op         := alu_hi;
                                write_reg_num  := rd;
                                src_reg1       := "00000";
                                src_reg2       := "00000";
                                
                            when "010010" => --MFLO
                                instruct_type  := i_mflo;
                                alu_op         := alu_lo;
                                write_reg_num  := rd;
                                src_reg1       := "00000";
                                src_reg2       := "00000";
                                
                            when "000000" => --SLL
                                instruct_type  := i_sll;
                                alu_op         := alu_sll;
                                write_reg_num  := rd;
                                src_reg1       := rt;
                                src_reg2       := "00000";
                                
                            when "000010" => --SRL
                                instruct_type  := i_srl;
                                alu_op         := alu_srl;
                                write_reg_num  := rd;
                                src_reg1       := rt;
                                src_reg2       := "00000";
                                
                            when "000011" => --SRA
                                instruct_type  := i_sra;
                                alu_op         := alu_sra;
                                write_reg_num  := rd;
                                src_reg1       := rt;
                                src_reg2       := "00000";
                                
                            when "001000" => --JR
                                instruct_type  := i_jr;
                                alu_op         := alu_add;
                                write_reg_num  := "00000";
                                src_reg1       := rs;
                                src_reg2       := "00000";
                                
                            when others =>
                                instruct_type  := i_no_op;
                                alu_op         := alu_add;
                                write_reg_num  := "00000";
                                src_reg1       := "00000";
                                src_reg2       := "00000";
                        end case;
                    
                    when "001000" => --ADDI
                        instruct_type  := i_addi;
                        alu_op         := alu_add;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "001010" => --SLTI
                        instruct_type  := i_slti;
                        alu_op         := alu_slt;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "001100" => --ANDI
                        instruct_type  := i_andi;
                        alu_op         := alu_and;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "001101" => --ORI
                        instruct_type  := i_ori;
                        alu_op         := alu_or;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "001110" => --XORI
                        instruct_type  := i_xori;
                        alu_op         := alu_xor;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "001111" => --LUI
                        instruct_type  := i_lui;
                        alu_op         := alu_lu;
                        write_reg_num  := rt;
                        src_reg1       := "00000";
                        src_reg2       := "00000";
                    
                    when "100011" => --LW
                        instruct_type  := i_lw;
                        alu_op         := alu_add;
                        write_reg_num  := rt;
                        src_reg1       := rs;
                        src_reg2       := "00000";
                    
                    when "101011" => --SW
                        instruct_type  := i_sw;
                        alu_op         := alu_add;
                        write_reg_num  := "00000";
                        src_reg1       := rs;
                        src_reg2       := rt;
                    
                    when "000100" => --BEQ
                        instruct_type  := i_beq;
                        alu_op         := alu_sub;
                        write_reg_num  := "00000";
                        src_reg1       := rs;
                        src_reg2       := rt;
                    
                    when "000101" => --BNE
                        instruct_type  := i_bne;
                        alu_op         := alu_sub;
                        write_reg_num  := "00000";
                        src_reg1       := rs;
                        src_reg2       := rt;
                    
                    when "000010" => --J
                        instruct_type  := i_j;
                        alu_op         := alu_add;
                        write_reg_num  := "00000";
                        src_reg1       := "00000";
                        src_reg2       := "00000";
                    
                    when "000011" => --JAL
                        instruct_type  := i_jal;
                        alu_op         := alu_add;
                        write_reg_num  := "11111"; --link register is $31
                        src_reg1       := "00000";
                        src_reg2       := "00000";
                    
                    when others =>
                        instruct_type  := i_no_op;
                        alu_op         := alu_add;
                        write_reg_num  := "00000";
                        src_reg1       := "00000";
                        src_reg2       := "00000";
                end case;
                
                --Check for hazards and stall if appropirate. If the registers holding
                --required values are being modified by previous instructions, we must stall.
                if ((
                    (src_reg1 /= "00000" and (--is the first operand being set later in the pipeline?
                        src_reg1 = ctrl_ex.write_reg_num or
                        src_reg1 = ctrl_mem.write_reg_num
                    ))
                    or
                    (src_reg2 /= "00000" and (--is the second operand being set later in the pipeline?
                        src_reg2 = ctrl_ex.write_reg_num or
                        src_reg2 = ctrl_mem.write_reg_num
                    ))
                    --If the predicted branch was wrong we must not stall either on the instruction, since it will not execute
                    ) and ignore_stall /= '1') then-- and (use_new_pc = '0' or current_pc = new_pc) and ignore_stall /= '1') then
                    
                    stall           <= '1';
                    instruct_type   := i_no_op;
                    alu_op          := alu_add;
                    write_reg_num   := "00000";
                    var_pc          := x"00000000";
                    var_instruct    := x"00000000";
                else
                    stall           <= '0';
                    var_pc          := current_pc;
                    var_instruct    := current_instruction;
                end if;
                
                --output the registers to pass data from
                rs_num <= rs;
                rt_num <= rt;
                
                --assign signals for next stage
                ctrl.pc             <= var_pc;
                ctrl.instruction    <= var_instruct;
                ctrl.instruct_type  <= instruct_type;
                ctrl.alu_op         <= alu_op;
                ctrl.write_reg_num  <= write_reg_num;
                
                --keep track of the instruction just decoded in case it is stalled
                last_pc <= current_pc;
                last_instruct <= current_instruction;
                
            end if;
        end if;
    end process;

end stage_id_arch;
