library ieee; 
use ieee.std_logic_1164.all; 
use WORK.myTypes.all;
use work.all;

entity P4adder is 
generic( REG_SIZE : integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       B: IN std_logic_vector( REG_SIZE-1 downto 0);
       c_in: IN std_logic;         --VERY IMPORTANT. IT DETERMINES IF THE OPERATION IS ADD OR SUB
       c_out: OUT std_logic;
       somma: OUT std_logic_vector( REG_SIZE-1 downto 0));
end P4adder;

architecture structural of P4adder is

component sparse_tree is
generic( REG_SIZE : integer := 32;
	n_c : integer := 8);
port ( A : IN std_logic_vector( REG_SIZE-1 downto 0);
       B : IN std_logic_vector( REG_SIZE-1 downto 0);
       carry: OUT std_logic_vector( n_c-1 downto 0));
end  component;

component sum_generator is 
generic ( REG_SIZE: integer := 32;
	 N: integer := 4;
         n_c: integer := 8);
port( A: IN std_logic_vector( REG_SIZE-1 downto 0);
      B: IN std_logic_vector( REG_SIZE-1 downto 0); 
      carry: IN std_logic_vector( n_c-1 downto 0);
      sum: OUT std_logic_vector( REG_SIZE-1 downto 0));
end component;

signal carrysignal : std_logic_vector(7 downto 0);
signal carrysignal_temp : std_logic_vector(7 downto 0);
--signal B_TEMP : std_logic_vector( 31 downto 0);

begin

ST: sparse_tree PORT MAP(A, B, carrysignal);
carrysignal_temp <= carrysignal(6 downto 0) & c_in;

--SG: sum_generator PORT MAP(A, B_TEMP, carrysignal_temp, somma);

SG: sum_generator PORT MAP(A, B, carrysignal_temp, somma);


end structural;
