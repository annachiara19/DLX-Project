library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
------------------------------------------------------------------------------------------------------
entity acc is 
generic (N : integer := 32);
port ( A: IN std_logic_vector(N-1 downto 0);
       B: IN std_logic_vector(N-1 downto 0);
       clk: IN std_logic;
       rst_n: IN std_logic;
       accumulate: IN std_logic;  
       Y: OUT std_logic_vector(N-1 downto 0));
end acc;
-------------------------------------------------------------------------------------------------------
architecture structural of acc is
    
--multiplexer
component MUX21 is
	generic (N : integer := 32;
            DELAY_MUX: Time:= TP_MUX);
	Port (	A:	In	std_logic_vector( N-1 downto 0);
		    B:	In	std_logic_vector( N-1 downto 0);
		    S:	In	std_logic;
		    Y:	Out	std_logic_vector( N-1 downto 0)
		    );
end component;

--rca(adder)
component  RCA is 
	generic (N : integer := 32;
	         DRCAS : 	Time := 0 ns;
            DRCAC : 	Time := 0 ns);
	Port (	  A:	In	std_logic_vector(N-1 downto 0);
		      B:	In	std_logic_vector(N-1 downto 0);
		      Ci:	In	std_logic;
		      S:	Out	std_logic_vector(N-1 downto 0);
		      Co:	Out	std_logic
		      );
end component; 

--register
component Reg is 
generic (N: integer := 32);
port (   A: IN std_logic_vector( N-1 downto 0);
         O: OUT std_logic_vector( N-1 downto 0);
         clk: IN std_logic;
         rst: IN std_logic);
end component;

signal u_mux, out_add: std_logic_vector (N-1 downto 0);
signal c_in: std_logic := '0';
signal c_out: std_logic;
signal feedback: std_logic_vector ( N-1 downto 0);


begin

mux1: MUX21 PORT MAP( B, feedback, accumulate, u_mux); 
adder1: RCA PORT MAP( A, u_mux, c_in,out_add,c_out);
reg1: Reg PORT MAP( out_add,  feedback, clk, rst_n);

Y<= feedback;

end structural;
-----------------------------------------------------------------------------------------------
architecture behavioral of ACC is
signal u_mux, out_add: std_logic_vector (N-1 downto 0);
signal feedback: std_logic_vector ( N-1 downto 0);



begin
--process mux
process(B, feedback, accumulate)
begin
if( accumulate = '0') then 
u_mux <= B;
else u_mux <= feedback;
end if;
end process;

--process add
process(A, u_mux)
begin
out_add <= A + u_mux;
end process;

--process register
process(clk)
begin
if(clk = '1' and clk'EVENT) then
	if(rst_n = '1') then
		feedback <= ( others => '0');
	else 
		feedback <= out_add;
end if;
end if;
end process;

Y<= feedback;

end behavioral;




-----------------------------------------------------------------------------------------------
configuration CFG_ACC_STRUCTURAL of ACC is
    for structural
end for;
end configuration;


configuration CFG_ACC_BEHAVIORAL of ACC is
for behavioral
end for;
end configuration;
