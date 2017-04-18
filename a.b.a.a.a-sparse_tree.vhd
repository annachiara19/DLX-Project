library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.myTypes.all;
use work.all;

entity sparse_tree is
generic( REG_SIZE : integer := 32;
	n_c : integer := 8);
port ( A : IN std_logic_vector( REG_SIZE-1 downto 0);
       B : IN std_logic_vector( REG_SIZE-1 downto 0);
       carry: OUT std_logic_vector( n_c-1 downto 0));
end sparse_tree;

architecture structural of sparse_tree is

component Gblock is
port( generalG: IN std_logic;
      generalP: IN std_logic;
      generalGminus: IN std_logic;
      Gout: OUT std_logic);
end component;

component PG is
port ( generalG: IN std_logic;
      generalP: IN std_logic;
      generalGminus: IN std_logic;
      generalPminus: IN std_logic;
      Gout: OUT std_logic;
      Pout: OUT std_logic);
end component;

component  PGnetwork is
port( a, b :IN std_logic;
      p, g :OUT std_logic);
end component;

signal p_row0: std_logic_vector(31 downto 0);
signal g_row0: std_logic_vector(31 downto 0);

signal p_row1: std_logic_vector(15 downto 0);
signal g_row1: std_logic_vector(15 downto 0);

signal p_row2: std_logic_vector( 7 downto 0);
signal g_row2: std_logic_vector( 7 downto 0);

signal g_row3: std_logic_vector( 3 downto 0);
signal p_row3: std_logic_vector( 3 downto 0);

signal p_row4: std_logic_vector( 3 downto 0);
signal g_row4: std_logic_vector( 3 downto 0);

signal p_row5: std_logic_vector( 3 downto 0);
signal g_row5: std_logic_vector( 3 downto 0);
begin
----------------------------------pg block
row0: for I in 0 to 31 generate
		pg_row0: PGnetwork PORT MAP ( A(I), B(I), p_row0(I), g_row0(I));
end generate row0 ;
----------------------------------g block first row
GG_row1: Gblock PORT MAP (g_row0(1), p_row0(1), g_row0(0), g_row1(0));
----------------------------------PG block first row

row1: for I in 1 to 15 generate
pg_row1: PG PORT MAP(g_row0(I*2+1), p_row0(I*2+1), g_row0(I*2), p_row0(I*2), g_row1(I), p_row1(I));
end generate row1 ;
-----------------------------------
GG_row2: Gblock PORT MAP( g_row1(1), p_row1(1), g_row1(0), g_row2(0));
carry(0) <= g_row2(0);
-------------------------------------
row2: for I in 1 to 7 generate
pg_row2: PG PORT MAP ( g_row1(I*2+1), p_row1(I*2+1), g_row1(I*2), p_row1(I*2), g_row2(I), p_row2(I));
end generate row2;
--------------------------------------
GG_row3: Gblock PORT MAP( g_row2(1), p_row2(1), g_row2(0), g_row3(0));
carry(1) <= g_row3(0);
--------------------------------------------
row3: for I in 1 to 3 generate
pg_row2: PG PORT MAP ( g_row2(I*2+1), p_row2(I*2+1), g_row2(I*2), p_row2(I*2), g_row3(I), p_row3(I));
end generate row3;

--------------------------------------------

GG_row4_1:  Gblock PORT MAP( g_row2(2), p_row2(2), g_row3(0), g_row4(0));
carry(2) <= g_row4(0);

--------------------------
GG_row4_2: Gblock PORT MAP( g_row3(1), p_row3(1), g_row3(0), g_row4(1));
carry(3) <= g_row4(1);
-------------------------------------------
PG_row4_1: PG PORT MAP(  g_row2(6), p_row2(6),  g_row3(2), p_row3(2), g_row4(2), p_row4(2));
----------------------------------------------
PG_row4_2: PG PORT MAP( g_row3(3), p_row3(3),  g_row3(2), p_row3(2), g_row4(3), p_row4(3));
---------------------------------
GG_row5_1: Gblock PORT MAP( g_row2(4), p_row2(4), g_row4(1), g_row5(0));
carry(4) <= g_row5(0);
---------------------------------
GG_row5_2: Gblock PORT MAP( g_row3(2), p_row3(2), g_row4(1), g_row5(1));
carry(5) <= g_row5(1);
----------------------------------
GG_row5_3: Gblock PORT MAP( g_row4(2), p_row4(2), g_row4(1), g_row5(2));
carry(6) <= g_row5(2);
-----------------------------------
GG_row5_4: Gblock PORT MAP( g_row4(3), p_row4(3), g_row4(1), g_row5(3));
carry(7) <= g_row5(3);
	
end structural;

