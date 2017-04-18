library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myTypes.all;


entity SHIFTER is
generic (REG_SIZE : integer := 32);
port ( 	A: IN std_logic_vector( REG_SIZE-1 downto 0);
       	direction: IN std_logic;                --RIGHT = 1, LEFT = 0
       	amount : IN integer;
	final_value: OUT std_logic_vector(REG_SIZE-1 downto 0));
end SHIFTER;

architecture beh of SHIFTER is

signal i : integer;
signal up : std_logic_vector( 31 downto 0);
begin

process(direction, amount)
begin
if( direction = '1' ) then 		--SHIFT LEFT LOGICAL
	up <= (others => '0');	
	for i in 0 to 31-amount loop
		up(i + amount) <= A(i);
	end loop;
	--A <= up;
else  					--SHIFT RIGHT ARITHMETICAL
	up <= (others => A(31));	--sign extended
	for i in 31 to amount loop
		up(i-amount) <= A(i);
	end loop;
	--A <= up;
end if;
end process;
--A <= up;
final_value <= up;
--oppure final_value <= up;
end beh;
