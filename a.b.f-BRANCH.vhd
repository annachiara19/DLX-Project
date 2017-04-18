library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.all;
use WORK.myTypes.all;

entity branch is
generic (REG_SIZE: integer := 32);
port (  A: IN std_logic_vector( REG_SIZE-1 downto 0 );
	B: IN std_logic_vector( REG_SIZE-1 downto 0 );
	BRANCH_EN: IN std_logic;	
	BRANCH_TYPE: IN std_logic; --if TYPE is equal to 1 , BEQZ, regA= 0, TAKEN= 1
	TAKEN: OUT std_logic);
end branch;


architecture behavioral of branch is

begin

process(BRANCH_EN,BRANCH_TYPE)
begin
if(BRANCH_EN = '1') then
	if( BRANCH_TYPE = '1') then --BEQZ
		
			if( A = B ) then
				TAKEN <= '1';
			else 
				TAKEN <= '0';
			end if;

	else --BNEZ

			if ( A = B) then 
				TAKEN <= '0';
			else 
				TAKEN <= '1';
			end if;
		
	end if; -- BRANCH_TYPE
elsif( BRANCH_EN = '0') then
		TAKEN <= '0';
	end if;	
end process;
end behavioral;
	 
