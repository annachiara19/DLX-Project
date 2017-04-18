library IEEE;
use IEEE.std_logic_1164.all; 
USE ieee.std_logic_arith.all ;
USE IEEE.STD_LOGIC_SIGNED.ALL; 
use WORK.myTypes.all;


entity adder is
generic ( REG_SIZE	   :integer := 32);
port ( A : IN std_logic_vector(REG_SIZE-1 downto 0);
       B : IN std_logic_vector(REG_SIZE-1 downto 0);
       C : OUT std_logic_vector(REG_SIZE-1 downto 0));
    --  clk: IN std_logic;
--      rst: IN std_logic);
end adder;


architecture beh of adder is

begin 
		C <= A + B;  

end beh; 