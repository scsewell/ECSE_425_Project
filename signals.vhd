library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Defines types used throughout the code.
package signals is
    
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
        i_no_op,    --the instruction has no effect
        
        --arithmatic
        i_add,
        i_sub,
        i_addi,
        i_mult,
        i_div,
        i_slt,
        i_slti,
        
        --logical
        i_and,
        i_or,
        i_nor,
        i_xor,
        i_andi,
        i_ori,
        i_xori,
        
        --transfer
        i_mfhi,
        i_mflo,
        i_lui,
        
        --shift
        i_sll,
        i_srl,
        i_sra,
        
        --memory
        i_lw,
        i_sw,
        
        --control flow
        i_beq,
        i_bne,
        i_j,
        i_jr,
        i_jal
    );
    
    --the type used to pass control and data signals between various stages of the pipeline
    type CTRL_TYPE is
        record
            pc              : std_logic_vector(31 downto 0); --the program counter address when this instruction was fetched
            instruction     : std_logic_vector(31 downto 0); --the instruction associated with the control signals
            instruct_type   : INSTRUCTION_TYPE;              --the type of instruction
            alu_op          : ALU_OP_TYPE;                   --the alu operation used for this instruction
            alu_output      : std_logic_vector(31 downto 0); --the output of the alu
            mem_write_val   : std_logic_vector(31 downto 0); --the value to write to memory
            write_reg_num   : std_logic_vector(4 downto 0);  --the register to store the result of this operation
        end record;
    
end signals;