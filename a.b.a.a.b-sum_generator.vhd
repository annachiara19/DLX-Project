library ieee; 
use ieee.std_logic_1164.all; 
use WORK.myTypes.all;
use work.all;
-----------------------------------------------------------------------
entity sum_generator is 
generic ( 	REG_SIZE: integer := 32;
 		N: integer := 4;
         	n_c: integer := 8);
port( A: IN std_logic_vector( REG_SIZE-1 downto 0);
      B: IN std_logic_vector( REG_SIZE-1 downto 0); 
      carry: IN std_logic_vector( n_c-1 downto 0);
      sum: OUT std_logic_vector( REG_SIZE-1 downto 0));
end sum_generator;

------------------------------------------------------------------------

architecture structural of sum_generator is
--carry select block
component  carry_select is 
generic ( N: integer := 4);
port ( A : IN std_logic_vector( N-1 downto 0);
       B : IN std_logic_vector( N-1 downto 0);
       c_in: IN std_logic;
       sum: OUT std_logic_vector( N-1 downto 0));
end component;


begin
           
G1:for I in 0 to n_c-1 generate
begin 
  e1: carry_select PORT MAP (A(((I*4)+3) downto (I*4)), B(((I*4)+3) downto (I*4)), carry(I), sum(((I*4)+3) downto (I*4)));
end generate G1;


end structural;

