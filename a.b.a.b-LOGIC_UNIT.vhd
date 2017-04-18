library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
use WORK.myTypes.all;


entity LOGIC_UNIT is 
generic( REG_SIZE : integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       B: IN std_logic_vector(REG_SIZE-1 downto 0);
       FUNC : IN aluOp;
       OUT_LOGIC: OUT std_logic_vector(REG_SIZE-1 downto 0));
end LOGIC_UNIT;

architecture BEH of LOGIC_UNIT is

begin
OUT_LOGIC <= 		A AND B WHEN FUNC = ALU_AND ELSE
			A XOR B WHEN FUNC = ALU_OR ELSE
			A OR B WHEN FUNC =ALU_XOR ELSE
			 (OTHERS=> '0');

end BEH;






