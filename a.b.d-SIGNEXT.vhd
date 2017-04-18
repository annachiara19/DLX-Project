library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all; --for logarithm
use WORK.all;
use WORK.myTypes.all;



entity SIGNEXT is 
generic ( REG_SIZE : integer := 32);
port (  input : IN std_logic_vector(REG_SIZE -1 downto 0); --31 downto 0
        output : OUT std_logic_vector( REG_SIZE-1 downto 0);  --31 downto 0
        J_TYPE:IN std_logic ; 
	EXT_UNSIGNED: IN std_logic);       
end SIGNEXT;


architecture behavioral of SIGNEXT is
begin
process(input, EXT_UNSIGNED, J_TYPE)
begin
		if( J_TYPE = '1') then 
		    if( EXT_UNSIGNED = '1') then
			output <= (others => '0');
		    else 
			output <= (others => input(25));
		    end if;
			output ( 25 downto 0) <= input ( 25 downto 0);
		else 
		   if(EXT_UNSIGNED = '1') then
			output <= (others => '0');
		   else
			output <= (others => input(15));
		   end if;
			output( 15 downto 0) <= input( 15 downto 0);
		end if;
end process;


end behavioral;

	