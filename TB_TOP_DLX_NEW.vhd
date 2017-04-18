library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use WORK.all;
use WORK.myTypes.all;

entity DLX_TestBench is
end DLX_TestBench;

architecture tb of DLX_TestBench is


--IRAM	
component IRAM is
  generic (
    RAM_DEPTH : integer := 2048;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
end component;

--DRAM
component DRAM is
generic(Nbit_address: integer := 11;
	Nbit : integer := 32;
	NLine: integer := 2048 ) ;   
port (  clk: IN std_logic;
        rst: IN std_logic;
        in_address: IN std_logic_vector( Nbit_address-1 downto 0);
        data_in: IN std_logic_vector( Nbit-1 downto 0);
        data_out: OUT std_logic_vector( Nbit-1 downto 0);
      	RE: IN std_logic;
	WE: IN std_logic;
	OE: IN std_logic);
end  component;


--DLX
component DLX is
  generic (
    IR_SIZE      : integer := 32;        -- Instruction Register Size
    FUNC_SIZE    : integer := 11;
    PC_SIZE      : integer := 32         -- Program Counter Size
    );      				 -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk 		: in std_logic;
    Rst 		: in std_logic;--IRAM SIGNALS
    TO_IRAM              : out std_logic_vector(IR_SIZE - 1 downto 0); 
    FROM_IRAM            : IN std_logic_vector(IR_SIZE - 1 downto 0);
--DRAM SIGNALS
    IN_DRAM		: out std_logic_vector( 10 downto 0);
    DATA_DRAM	   	: out std_logic_vector( IR_SIZE-1 downto 0);
    IN_LMD		: in std_logic_vector( IR_SIZE-1 downto 0);
    DRAM_OE            	: out std_logic;  
    DRAM_RE            	: out std_logic;  
    DRAM_WE	        : out std_logic
);               
end component;

	signal CLK :				std_logic := '0';		
	signal RST :				std_logic := '0';		
	signal TO_IRAM_I : 			std_logic_vector( 31 downto 0);
	signal FROM_IRAM_I : 			std_logic_vector( 31 downto 0);
	signal IN_DRAM_I :			std_logic_vector(10 downto 0);
	signal DATA_DRAM_I:			std_logic_vector(31 downto 0);
	signal IN_LMD_I	  :			std_logic_vector(31 downto 0);		
	signal DRAM_OE_I :			std_logic;
	signal DRAM_RE_I :			std_logic;
  	signal DRAM_WE_I : 			std_logic;
	

begin

	
	
	-- IRAM
	MyIRAM : IRAM
		--generic map ("/home/gandalf/Desktop/dlx/rocache/hex.txt")
		port map (RST, TO_IRAM_I, FROM_IRAM_I);
	-- DRAM
	MyDRAM : DRAM
		--generic map ("/home/gandalf/Desktop/dlx/rwcache/hex_init.txt","/home/gandalf/Desktop/dlx/rwcache/hex.txt")
		port map (CLK, RST, IN_DRAM_I, DATA_DRAM_I, IN_LMD_I, DRAM_WE_I, DRAM_RE_I, DRAM_OE_I);

	-- DLX
	My_DLX : DLX
		port map ( CLK, RST, TO_IRAM_I, FROM_IRAM_I,IN_DRAM_I, DATA_DRAM_I, IN_LMD_I, DRAM_OE_I, DRAM_RE_I, DRAM_WE_I);

  	PCLO: process(Clk)
	begin
		Clk <= not(Clk) after 0.5 ns;	
	end process;
	--Clk <= not Clk after 10 ns;
	Rst <= '1', '0' after 3.7 ns;
end tb;

