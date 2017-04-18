library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use WORK.all;
use WORK.myTypes.all;

entity TB_ALU1 is
end TB_ALU1;

architecture myTB of TB_ALU1 is

component ALU is
  generic (REG_SIZE : integer := 32);
  port 	 ( FUNC: IN aluOp;
           DATA1, DATA2: IN std_logic_vector(REG_SIZE-1 downto 0);
           OUTALU: OUT std_logic_vector(REG_SIZE-1 downto 0));
end component;

signal F: aluOp;
signal D1, D2 : std_logic_vector(31 downto 0);
signal OUTALU : std_logic_vector(31 downto 0);

begin

MYALU : ALU PORT MAP( F, D1, D2, OUTALU);

process
begin
F <= ALU_ADD;
D1 <= x"00000002";
D2 <= x"00000004";
wait for 10 ns;

F <= ALU_SUB;
D1 <= x"00000005";
D2 <= x"00000004";
wait for 10 ns;
wait;
end process;

end myTB;