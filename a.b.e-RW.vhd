library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all; --for logarithm
use WORK.all;
use WORK.myTypes.all;


--entity che riceve in ingresso un indirizzo su 32 bit e restituisce due parti differenti 
--del dato, che poi verranno muxati


entity RegW is
generic ( REG_SIZE: integer := 32);
port ( A: IN std_logic_vector(REG_SIZE-1 downto 0);
       B: OUT std_logic_vector(REG_SIZE-1 downto 0);
       C: OUT std_logic_vector( REG_SIZE-1 downto 0);
       clk: IN std_logic;
       rst: IN std_logic;
       OE: IN std_logic);
end RegW;


architecture behavioral of RegW is

begin
process(OE, clk, rst, A)
begin
if( clk ='1' and clk'EVENT) then 
	if( rst = '1') then
		B  <=( others => '0');
		C <= (others => '0');
		elsif( OE = '1') then
			--I type
			B <= "000000000000000000000000000" & A( 20 downto 16);
			--R type
			C <="000000000000000000000000000" & A( 15 downto 11);
		end if;
	end if;

end process;
end behavioral;








