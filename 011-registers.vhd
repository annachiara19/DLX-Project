library IEEE;
use IEEE.std_logic_1164.all; 
use WORK.all;
use work.myTypes.ALL;

entity Reg is 
generic (REG_SIZE: integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       O: OUT std_logic_vector( REG_SIZE-1 downto 0);
      clk: IN std_logic;
      rst: IN std_logic;
      OE: IN std_logic);
end Reg;

architecture Behavioral of Reg is
begin
process(clk)
begin
if(clk = '1' and clk'EVENT) then
	if(rst = '1') then
		O <= (others => '0');
	elsif( OE = '1') then  
		O <= A;
	end if;
	end if;
end process;
end Behavioral;

