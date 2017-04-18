library IEEE;
use IEEE.std_logic_1164.all; 
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.LOGFUNCTION.ALL;
use work.myTypes.ALL;
use work.all;


entity DATAPATH is
 generic (  	
	
	RF_REGISTERS	   :     integer := 32;
    	FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    	OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    	ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    	IR_SIZE            :     integer := 32);  -- Instruction Register Size    
port (
	OPCODE             : out  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    	FUNC               : out  std_logic_vector(FUNC_SIZE - 1 downto 0);  	
    	Clk                : in  std_logic;  -- Clock
   	Rst                : in  std_logic;  -- Reset:Active-Low
    	EN_PC              : in std_logic; --ABILITA IL PROGRAMM COUNTER
	-- Instruction Register    
	PC_OUT             : out std_logic_vector(IR_SIZE - 1 downto 0); 
    	IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    	
    	-- IF Control Signal
    	IR_EN              : in std_logic;  -- Instruction Register Latch Enable
    	EN_NPC1            : in std_logic;  -- NextProgramCounter Register Latch Enable
	-- ID Control Signal
    	EN_RF              : in std_logic;
    	RD1                : in std_logic;
    	RD2                : in std_logic;
    	BRANCH_EN          : in std_logic;
    	BRANCH_TYPE        : in std_logic;
	TAKEN		   : out std_logic;
   	JTYPE              : in std_logic;
    	EXT_UNSIGNED       : in std_logic;
    	EN_SIGN            : in std_logic;
	SEL_J		   : in std_logic;
    	EN_IMM             : in std_logic;  -- Immediate Register Latch Enable
    	EN_NPC2            : in std_logic;
    	EN_A               : in std_logic;  -- Register A Latch Enable
    	EN_B               : in std_logic;  -- Register B Latch Enable
 	EN_RW1	           : in std_logic;  -- register for write 1
	ALUOPCODE          : in aluOp;	
	-- EX Control Signals
	MUXA_SEL	   : in std_logic;
    	MUXB_SEL           : in std_logic;  -- MUX-B Sel
    	ALU_OUT1           : out std_logic;  -- ALU Output Register Enable
    	EN_REGB2	   : in std_logic;  -- B2 enable
	EN_NPC3            : in std_logic;  -- NPC3 enable
	SEL_TYPE           : in std_logic;  -- Select if R-Type or I-type
    	EN_RW2	           : in std_logic;  -- register for write 2
	-- MEM Control Signals 
	IN_DRAM		   : out std_logic_vector( 9 downto 0);
	DATA_DRAM	   : out std_logic_vector( IR_SIZE-1 downto 0);
	IN_LMD		   : in std_logic_vector( IR_SIZE-1 downto 0);

	EN_NPC4            : in std_logic;  -- NPC4 enable
    	LMD_LATCH_EN       : in std_logic;  -- LMD Register Latch Enable
   	ALU_OUT2           : in std_logic;  -- Register that contains output of the Alu
	EN_RW3	           : in std_logic;  -- register for write 3
	-- WB Control signals
    	WB_MUX_SEL         : in std_logic;  -- Write Back MUX Sel
    	RF_WE              : in std_logic;  -- Register File Write Enable
	SEL_MUX_PC	   : in std_logic); -- It selects branch or not
end DATAPATH;


architecture structural of DATAPATH is

---------REGISTER-------------
component  Reg is 
generic ( REG_SIZE	   :integer := 32);
port ( A: IN std_logic_vector( REG_SIZE -1  downto 0);
       O: OUT std_logic_vector( REG_SIZE -1 downto 0);
      clk: IN std_logic; 
      rst: IN std_logic;
      OE: IN std_logic);
end component;

--------ADDER---------------
component adder is
generic ( REG_SIZE	   :integer := 32);
port ( A : IN std_logic_vector( REG_SIZE -1 downto 0);
       B : IN std_logic_vector( REG_SIZE -1 downto 0);
       C : OUT std_logic_vector( REG_SIZE -1 downto 0);
      clk: IN std_logic;
      rst: IN std_logic);
end  component;

----------REGISTER_FILE--------
component register_file is
 generic ( REG_SIZE	   :integer := 32;
	   RF_REGISTERS: integer := 32);
 port (  CLK:           IN std_logic;
         RESET: 	IN std_logic;
	 ENABLE: 	IN std_logic;
	 RD1: 		IN std_logic;
	 RD2: 		IN std_logic;
	 WR: 		IN std_logic;
	 ADD_WR: 	IN std_logic_vector( LOG2(RF_REGISTERS)-1 downto 0);                                                            
	 ADD_RD1: 	IN std_logic_vector(LOG2(RF_REGISTERS)-1 downto 0);
	 ADD_RD2: 	IN std_logic_vector(LOG2(RF_REGISTERS)-1 downto 0);
	 DATAIN: 	IN std_logic_vector(REG_SIZE -1 downto 0);
   	 OUT1: 		OUT std_logic_vector(REG_SIZE -1 downto 0);
	 OUT2: 		OUT std_logic_vector(REG_SIZE -1 downto 0));
end component;

-----------MUX-----------------
component MUX21 is
	generic (REG_SIZE : integer := 32);
	Port (	A:	In	std_logic_vector( REG_SIZE -1 downto 0);
		B:	In	std_logic_vector(REG_SIZE -1 downto 0);
		S:	In	std_logic;
		Y:	Out	std_logic_vector( REG_SIZE -1 downto 0);
		CLK:    IN      std_logic);
end component;

---------ALU------------------
component ALU is
generic ( REG_SIZE: integer := 32);
port( FUNC: IN aluOp;
      DATA1, DATA2: IN std_logic_vector(REG_SIZE -1 downto 0);
      OUTALU: OUT std_logic_vector(REG_SIZE -1 downto 0));
end component;

--------SIGNEXTEND--------------------------------
component SIGNEXT is 
generic ( REG_SIZE : integer := 32);
port (  clk : IN std_logic;
        rst : IN std_logic;
        input : IN std_logic_vector(REG_SIZE -1 downto 0); --31 downto 0
        output : OUT std_logic_vector( REG_SIZE -1 downto 0);  --31 downto 0
        J_TYPE:IN std_logic ; 
	EXT_UNSIGNED: IN std_logic;       
	EN_SIGN: IN std_logic );
end  component;

---------CONDITIONAL BRANCH-----------------------------------
component branch is
generic (REG_SIZE: integer := 32);
port (  A: IN std_logic_vector( REG_SIZE -1 downto 0 );
	B: IN std_logic_vector( REG_SIZE -1 downto 0 );
	clk: IN std_logic;
	rst: IN std_logic;
	BRANCH_EN: IN std_logic;	
	BRANCH_TYPE: IN std_logic; --if TYPE is equal to 1 , BEQZ, regA= 0, TAKEN= 1
	TAKEN: OUT std_logic);
end component;



----------REGISTER OF WRITE IN REGISTER FILE---------
component RegW is
generic ( REG_SIZE: integer := 32);
port ( A: IN std_logic_vector( REG_SIZE -1 downto 0);
       B: OUT std_logic_vector(REG_SIZE -1 downto 0);
       C: OUT std_logic_vector( REG_SIZE -1 downto 0);
       clk: IN std_logic;
       rst: IN std_logic;
       OE: IN std_logic);
end component;

--SIGNAL PREFETCH
signal sel_PC: std_logic;
signal EN_MUX_PC: std_logic;

--SIGNAL FETCH
signal address_in_PC: std_logic_vector( 31 downto 0);
signal address_out_PC: std_logic_vector(31 downto 0);
signal data_out_IRAM : std_logic_vector( 31 downto 0);
signal data_out_IR: std_logic_vector ( 31 downto 0);
signal data_in_RW1: std_logic_vector( 31 downto 0);
signal s_31: std_logic_vector(31 downto 0) := (others => '1');
signal EN_IR: std_logic;
signal increment : std_logic_vector(31 downto 0) := "00000000000000000000000000000100";  
signal adder_out : std_logic_vector( 31 downto 0 );
signal npc1: std_logic_vector( 31 downto 0);

--SIGNAL DECODE
signal addr_R1: std_logic_vector( 4 downto 0);
signal addr_R2: std_logic_vector( 4 downto 0);
signal addr_W: std_logic_vector( 4 downto 0);    
signal data_IN_RF: std_logic_vector( 31 downto 0);
signal out_RF_A: std_logic_vector( 31 downto 0);
signal out_RF_B: std_logic_vector( 31 downto 0);
signal out_A: std_logic_vector( 31 downto 0);
signal out_B: std_logic_vector( 31 downto 0);
signal npc2: std_logic_vector( 31 downto 0);
signal inputSIGN: std_logic_vector( 31 downto 0);
signal outputSIGN: std_logic_vector( 31 downto 0);
signal IType, RType: std_logic_vector ( 31 downto 0);
signal out_adder_branch: std_logic_vector( 31 downto 0);
signal my_taken : std_logic;

---SIGNAL EXECUTE
signal out_muxa: std_logic_vector( 31 downto 0);
signal out_muxb: std_logic_vector( 31 downto 0);
signal output_IMM: std_logic_vector( 31 downto 0);
signal outalu: std_logic_vector( 31 downto 0);
signal npc3: std_logic_vector( 31 downto 0);
signal out_write1: std_logic_vector( 31 downto 0);

---SIGNAL MEMORY
signal in_addr_dram: std_logic_vector( 31 downto 0);
signal EN_ALUREG1, EN_LMD, EN_ALUREG2 : std_logic;
signal in_data_dram: std_logic_vector ( 31 downto 0);
signal my_out_dram: std_logic_vector ( 31 downto 0);
signal npc4: std_logic_vector( 31 downto 0);
signal out_lmd, out_alu2:  std_logic_vector( 31 downto 0);
signal out_write2: std_logic_vector( 31 downto 0);

--SIGNAL WRITE BACK
signal out_WB : std_logic_vector( 31 downto 0);
signal sel_wb, EN_WB: std_logic;
signal out_write3: std_logic_vector( 31 downto 0);

begin
--PREFETCH---------------------------------------------------

mux_pc: MUX21 PORT MAP (out_adder_branch, npc4, sel_PC, address_in_PC, clk);

--FETCH------------------------------------------------------
PC: Reg PORT MAP( address_in_PC, address_out_PC, clk, rst, EN_PC);
PC_OUT <= address_out_PC;
IR: Reg PORT MAP (IR_IN , data_out_IR, clk, rst, EN_IR); 
ADD: adder PORT MAP ( address_out_PC, increment, adder_out, clk, rst);
NPC_1 : Reg PORT MAP ( adder_out, npc1, clk, rst, EN_NPC1) ;
--DECODE------------------------------------------------------
addr_R1 <= data_out_IR(25 downto 21);
addr_R2 <= data_out_IR(20 downto 16);
inputSIGN <= data_out_IR;
opcode <= data_out_IR( 31 downto 26);

REGISTERFILE: register_file PORT MAP ( clk, rst, EN_RF, RD1, RD2, RF_WE, addr_W, addr_R1, addr_R2, 
					data_IN_RF, out_RF_A, out_RF_B);
REG_A: Reg PORT MAP ( out_RF_A, out_A, clk, rst, EN_A);
REG_B: Reg PORT MAP ( out_RF_B, out_B, clk, rst, EN_B);
SIGN : SIGNEXT PORT MAP (clk, rst, inputSIGN, outputSIGN, JTYPE, EXT_UNSIGNED, EN_SIGN); 
IMM : Reg PORT MAP ( outputSIGN, output_IMM, clk, rst, EN_IMM); 
MUX_J : MUX21 PORT MAP( s_31, data_out_IR, SEL_J, data_in_RW1, clk);
NPC_2: Reg PORT MAP ( npc1, npc2, clk, rst, EN_NPC2);
RW1: RegW PORT MAP ( data_in_RW1, IType, RType, clk, rst, EN_RW1);
ADD_FOR_JUMP: adder PORT MAP ( npc1, outputSIGN, out_adder_branch, clk, rst);
ZC: branch PORT MAP ( out_RF_A, out_RF_B, clk, rst,BRANCH_EN, BRANCH_TYPE, my_taken);
TAKEN <= my_taken;

--EXECUTE-------------------------------------------------------
MUX_A : MUX21 PORT MAP ( out_A, npc1, MUXA_SEL, out_muxa, clk);
MUX_B : MUX21 PORT MAP ( out_B, output_IMM, MUXB_SEL, out_muxb, clk);
MY_ALU: ALU PORT MAP ( ALUOPCODE , out_muxa, out_muxb, outalu); 
NPC_3: Reg PORT MAP ( npc2, npc3, clk, rst, EN_NPC3);
ALUREG1: Reg PORT MAP ( outalu, in_addr_dram, clk, rst, EN_ALUREG1);
MUX_RW: MUX21 PORT MAP ( IType, RType, sel_type, out_write1, clk);
REG_B2: Reg PORT MAP ( out_B, in_data_dram, clk, rst, EN_REGB2);
RW2: Reg PORT MAP ( out_write1, out_write2, clk, rst, EN_RW2);

--OUT OF DATAPATH
IN_DRAM <= in_addr_dram( 9 downto 0);
DATA_DRAM <= in_data_dram;

--MEMORY----------------------------------------------------------

NPC_4: Reg PORT MAP ( npc3, npc4, clk, rst, EN_NPC4);
LMD: Reg PORT MAP ( IN_LMD , out_lmd, clk, rst, EN_LMD);
ALUREG2: Reg PORT MAP (in_addr_dram, out_alu2, clk, rst, EN_ALUREG2);
RW3: Reg PORT MAP ( out_write2, out_write3, clk, rst, EN_RW3);
addr_w <= out_write3(4 downto 0);

--WRITEBACK-------------------------------------------------------------
MUXWB: MUX21 PORT MAP ( out_lmd, out_alu2, sel_wb, out_WB,clk);
data_IN_RF <= out_WB;


end structural;