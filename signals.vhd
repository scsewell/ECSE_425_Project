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
        i_no_op,        --the instruction has no effect
        i_write_reg,    --the instruction sets a register value using alu output
        i_write_hi_low, --the instruction sets the hi/lo register values in the alu
        i_write_mem,    --the instruction sets a memory value
        i_read_mem,     --the instruction reads a memory value and sets a register
        i_jump,         --the instruction sets the program counter value
        i_jump_link,    --the instruction sets the program counter value and sets the link register value
        i_branch_eq,    --the instruction sets the program counter value
        i_branch_neq    --the instruction sets the program counter value
    );
    
    --the type used to pass control and data signals between various stages of the pipeline
    type CTRL_TYPE is
        record
            pc              : std_logic_vector(31 downto 0); --the program counter address when this instruction was fetched
            instruction     : std_logic_vector(31 downto 0); --the instruction associated with the control signals
            instruct_type   : INSTRUCTION_TYPE;              --the type of instruction
            exec_source     : EXEC_SOURCE_TYPE;              --the inputs needed for the alu operation
            alu_op          : ALU_OP_TYPE;                   --the alu operation used for this instruction
            alu_output      : std_logic_vector(31 downto 0); --the output of the alu
            alu_passthrough : std_logic_vector(31 downto 0); --a value passed from the exe stage
            mem_output      : std_logic_vector(31 downto 0); --the output of the memory stage
            write_reg_num   : std_logic_vector(4 downto 0);  --the register to store the result of this operation
        end record;
    
end signals;