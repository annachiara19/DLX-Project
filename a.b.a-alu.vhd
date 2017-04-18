library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myTypes.all;


entity ALU is
  generic (REG_SIZE : integer := 32);
  port 	 ( FUNC: IN aluOp;
           DATA1, DATA2: IN std_logic_vector(REG_SIZE-1 downto 0);
           OUTALU: OUT std_logic_vector(REG_SIZE-1 downto 0));
end ALU;

architecture BEH of ALU is


--ADDITIONS AND SUBTRACTIONS
component P4adder is 
generic( REG_SIZE : integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       B: IN std_logic_vector( REG_SIZE-1 downto 0);
       c_in: IN std_logic;   --VERY IMPORTANT. IT DETERMINES IF THE OPERATION IS ADD OR SUB
       c_out: OUT std_logic;
       somma: OUT std_logic_vector( REG_SIZE-1 downto 0));
end component;

component SHIFTER_GENERIC is
	generic(REG_SIZE: integer := 32);
	port(	A: in std_logic_vector(REG_SIZE-1 downto 0);
		B: in std_logic_vector(4 downto 0);
		LOGIC_ARITH: in std_logic;	-- 1 = logic, 0 = arith
		LEFT_RIGHT: in std_logic;	-- 1 = left, 0 = right
		SHIFT_ROTATE: in std_logic;	-- 1 = shift, 0 = rotate
		OUTPUT: out std_logic_vector(REG_SIZE-1 downto 0)
	);
end component;


--COMPARATOR
component COMPARATOR is
generic (REG_SIZE : integer := 32);
port ( 	A: IN std_logic_vector(REG_SIZE-1 downto 0);
       	B: IN std_logic_vector(REG_SIZE-1 downto 0);
	greater: IN std_logic;    		 --SGE/ SGEI
	lower: IN std_logic;      		 --SLE/SLEI
	not_equal: IN std_logic;      		 --SNE/SNEI
	equal : IN std_logic;	                 --SEQ/ SEQI
	greater_sign : IN std_logic;
	greater_unsign: IN std_logic;
       	out_comp: OUT std_logic_vector( REG_SIZE-1 downto 0));
end component;


--LOGICOPERATIONS
component  LOGIC_UNIT is 
generic( REG_SIZE : integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       B: IN std_logic_vector(REG_SIZE-1 downto 0);
       FUNC : IN aluOp;
       OUT_LOGIC: OUT std_logic_vector(REG_SIZE-1 downto 0));
end  component;
----------------------------------------------------------------------------
signal B_TEMP : std_logic_vector( 31 downto 0);
signal cin: std_logic := '0';
signal cout : std_logic;
signal somma: std_logic_vector( 31 downto 0);      -- OUT P4 ADDER
signal OUT_LOGIC: std_logic_vector( 31 downto 0);  -- OUT LOGIC ELEMENT
signal great, less, not_equal, equal, greater_sign, greater_unsign: std_logic;
signal out_comp: std_logic_vector( 31 downto 0);
signal out_nop: std_logic_vector( 31 downto 0);
signal LOGIC_ARITH, LEFT_RIGHT, SHIFT_ROTATE: STD_LOGIC:='1';
signal OUTPUT : std_logic_vector( 31 downto 0);

begin 


--P4 ADDER
B_TEMP <= not DATA2 WHEN FUNC = ALU_SUB ELSE DATA2;
cin <= '1' WHEN FUNC = ALU_SUB ELSE '0';

--SIGNALS FOR THE SHIFTER
LOGIC_ARITH <= '0' WHEN FUNC = ALU_SRL ELSE '1';   --SRLI?  	-- 1 = logic, 0 = arith
LEFT_RIGHT <= '1' WHEN FUNC = ALU_SLL ELSE '0';    --SLLI??	-- 1 = left, 0 = right
SHIFT_ROTATE <= '1'; 						-- 1 = shift, 0 = rotate

great <= '1' WHEN (FUNC= ALU_SGE) ELSE '0';
less <= '1' WHEN (FUNC = ALU_SLE) ELSE '0';
not_equal <= '1' WHEN (FUNC = ALU_SNE) ELSE '0';
equal<= '1' WHEN (FUNC = ALU_SEQ) ELSE '0';
greater_sign <= '1' WHEN (FUNC = ALU_SGT) ELSE '0';
greater_unsign <= '1' WHEN (FUNC = ALU_SLT) ELSE '0';
out_nop <= DATA1 WHEN FUNC = NOP ;


-----------------------------------------------------------------------------------
P4: P4adder PORT MAP( DATA1, B_TEMP, cin, cout, somma); 
logic: LOGIC_UNIT PORT MAP( DATA1, DATA2, FUNC,  OUT_LOGIC);
shifter: SHIFTER_GENERIC port MAP( DATA1, DATA2(4 DOWNTO 0), LOGIC_ARITH, LEFT_RIGHT, SHIFT_ROTATE, OUTPUT);
comp: COMPARATOR PORT MAP( DATA1, DATA2, great, less, not_equal, equal, greater_sign,
				greater_unsign, out_comp);
-----------------------------------------------------------------------------------

OUTALU <=       somma 		when FUNC = ALU_ADD  else
		somma  		when FUNC = ALU_SUB  else
	  	OUT_LOGIC 	when FUNC = ALU_AND  else
		OUT_LOGIC 	when FUNC = ALU_OR   else
		OUT_LOGIC 	when FUNC = ALU_XOR  else 
		OUTPUT		when FUNC = ALU_SLL  else
		OUTPUT		when FUNC = ALU_SLLI else
		OUTPUT		when FUNC = ALU_SRL  else
		OUTPUT		when FUNC = ALU_SRLI else 
		out_comp	when FUNC = ALU_SNE  else
		out_comp	when FUNC = ALU_SGE  else
		out_comp	when FUNC = ALU_SLE  else
		out_comp	when FUNC = ALU_SEQ else	
		out_comp 	when FUNC = ALU_SGT else
		out_comp 	when FUNC = ALU_SLT else
		out_nop 	when FUNC = NOP  else
	        (OTHERS=> '0');
	
end BEH;

