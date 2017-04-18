library ieee;
use ieee.std_logic_1164.all;

package myTypes is

	constant Nbit 			: integer := 32;
    	constant OP_CODE_SIZE 		: integer :=  6;                                              -- OPCODE field size
    	constant FUNC_SIZE    		: integer :=  11;                                             -- FUNC field size
   	constant Naddr 	  		: integer  := 5;
    	constant RAM_DEPTH 		: integer := 48;
    	constant IR_SIZE 		: integer := 32;
    	constant I_SIZE 		: integer := 32;
	constant Nbit_address		: integer := 10;
	constant NLine			: integer := 1024 ;   
	constant PC_SIZE      		: integer := 32 ;
	constant REG_SIZE		: integer := 32;
 	constant n_c			: integer := 8;
	constant N			: integer := 4;
	constant BYTE_N 		: integer := 8;

type aluOp is ( NOP, ALU_ADD, ALU_SUB, ALU_SLL, ALU_SLLI, ALU_SRLI, ALU_SRL, ALU_AND, ALU_OR,
		ALU_XOR, ALU_SEQ,ALU_SGT, ALU_SLT, ALU_SNE,ALU_SLE, ALU_SGE);

end myTypes;

