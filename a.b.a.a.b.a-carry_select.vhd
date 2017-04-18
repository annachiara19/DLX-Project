library ieee; 
use ieee.std_logic_1164.all; 
use work.all;
use WORK.myTypes.all;
------------------------------------------------------------------
entity carry_select is 
generic (N: integer := 4);
port ( A : IN std_logic_vector( N-1 downto 0);
       B : IN std_logic_vector( N-1 downto 0);
       c_in: IN std_logic;
       sum: OUT std_logic_vector( N-1 downto 0));
end carry_select;
-------------------------------------------------------------------
architecture structural of carry_select is
--rca
component RCA is 
	generic (N : integer := 4);
	Port (	A:	In	std_logic_vector(N-1 downto 0);
		B:	In	std_logic_vector(N-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N-1 downto 0));
		--Co:	Out	std_logic);
end component; 
--mux
component  mux4bit is
	generic (N: integer := 4);
	Port (	A:	In	std_logic_vector( N-1 downto 0);
		B:	In	std_logic_vector( N-1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector(N-1 downto 0));
end component;

--signal clk: std_logic;
signal c_zero: std_logic := '0';
signal c_uno:std_logic := '1';
signal s_zero, s_uno: std_logic_vector( 3 downto 0);
--signal c_o1, c_o2: std_logic;

begin

rca_zero: RCA PORT MAP (A, B, c_zero, s_zero);
rca_uno: RCA PORT MAP ( A, B, c_uno, s_uno);
--mux_somma: mux4bit PORT MAP( s_uno, s_zero, c_in, sum);
mux_somma: mux4bit PORT MAP( s_zero, s_uno , c_in, sum);
end structural;

