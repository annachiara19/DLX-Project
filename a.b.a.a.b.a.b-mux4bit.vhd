library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.all;
use WORK.myTypes.all;


entity mux4bit is
	generic (N: integer := 4);
	Port (	A:	In	std_logic_vector( N-1 downto 0);
		B:	In	std_logic_vector( N-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(N-1 downto 0));
end mux4bit;


architecture BEHAVIORAL of mux4bit is
begin
Y <= A when S='0' else B;
end BEHAVIORAL;


