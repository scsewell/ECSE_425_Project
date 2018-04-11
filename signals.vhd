library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Defines types containing many related signals
package signals is
    
    --enumeration defining possible executions stage input sources
    type EXEC_SOURCE_TYPE is (
        es_rs_rt,
        es_rt_samnt,
        es_rs_imm_zero_extend,
        es_rs_imm_sign_extend,
        es_imm_sign_extend,
        es_rs_rt_pc_imm_sign_extend,
        es_pc_address
    );
    
    --enumeration defining supported alu operations
    type ALU_OP_TYPE is (
        --arithmatic
        alu_add,
        alu_sub,
        alu_mul,
        alu_div,
        alu_slt,
        
        --logical
        alu_and,
        alu_or,
        alu_nor,
        alu_xor,
        
        --transfer
        alu_hi,
        alu_lo,
        alu_lu,
        
        --shift
        alu_sll,
        alu_srl,
        alu_sra
    );
    
    --enumeration defining possible intruction types
    type INSTRUCTION_TYPE is (
        i_no_op,
        i_write_reg,
        i_write_hi_low,
        i_write_mem,
        i_read_mem,
        i_jump,
        i_jump_link,
        i_branch_eq,
        i_branch_neq
    );
    
    --the type used to pass control and data signals between various stages of the pipeline
    type CTRL_TYPE is
        record
            pc              : std_logic_vector(31 downto 0); --the program counter address when this instruction was fetched
            instruction     : std_logic_vector(31 downto 0); --the instruction associated with the control signals
            instruct_type   : INSTRUCTION_TYPE;              --the type of instruction
            exec_source     : EXEC_SOURCE_TYPE;
            alu_op          : ALU_OP_TYPE;                   --the alu operation used for this instruction
            write_reg_num   : std_logic_vector(4 downto 0);  --the register to store the result of this operation
        end record;
    
    --the type used to pass execution stage output
    type RESULTS_EX_TYPE is
        record
            output      : std_logic_vector(31 downto 0);
            zero        : std_logic;
            passthrough : std_logic_vector(31 downto 0);
        end record;
        
    --the type used to pass memory stage output
    type RESULTS_MEM_TYPE is
        record
            output      : std_logic_vector(31 downto 0);
        end record;
	
end signals;