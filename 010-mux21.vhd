library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.all; -- libreria WORK user-defined
use WORK.myTypes.all;

entity MUX21 is
	generic (REG_SIZE: integer := 32);
	Port (	A:	In	std_logic_vector( REG_SIZE-1 downto 0);
		B:	In	std_logic_vector( REG_SIZE-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(REG_SIZE-1 downto 0));
end MUX21;


architecture BEHAVIORAL_1 of MUX21 is
signal UNDEFINED : std_logic_vector( REG_SIZE-1 downto 0):= ( others =>'X');
begin
Y <= A when S='0' else 
     B when S= '1' else
	UNDEFINED;
   
end BEHAVIORAL_1;


