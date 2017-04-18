library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.myTypes.all;


entity dlx_cu is
  generic (
    	MICROCODE_MEM_SIZE :     integer := 64;  -- Microcode Memory Size
    	FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    	OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    	ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    	IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    	CW_SIZE            :     integer := 15;  -- Control Word Size
	CW1_SIZE	   :	 integer := 8;
	CW2_SIZE	   :     integer := 5;
	CW3_SIZE	   :     integer := 2);
	
  port (
 	--INPUT 
    	OPCODE             : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    	FUNC               : in  std_logic_vector(FUNC_SIZE - 1 downto 0);  	
    	Clk                : in  std_logic;  
   	Rst                : in  std_logic;  
    	EN_PC              : out std_logic;
    	IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    	IR_EN              : out std_logic;  -- Instruction Register Latch Enable
    	EN_NPC1            : out std_logic;  -- NextProgramCounter Register Latch Enable

--CONTROL UNIT STARTS ACTIVITIES HERE  
-- ID Control Signals
-----------------------------------------------------------------------------------------------
--FIRST STAGE PIPELINE
    	EN_RF              : out std_logic;
    	RD1                : out std_logic;
    	RD2                : out std_logic;
	--WE		   : out std_logic;
    
    	BRANCH_EN          : out std_logic;
    	BRANCH_TYPE        : out std_logic;
	TAKEN		   : in  std_logic;
   
    	JTYPE              : out std_logic;
    	EXT_UNSIGNED       : out std_logic;
    	--EN_SIGN            : out std_logic;

	SEL_J		   : out std_logic;
    
	EN_IMM             : out std_logic;  -- Immediate Register Latch Enable
    	EN_NPC2            : out std_logic;
    	EN_A	           : out std_logic;  -- Register A Latch Enable
    	EN_B	           : out std_logic;  -- Register B Latch Enable
 	EN_RW1	           : out std_logic;  -- register for write 1

-- EX Control Signals
-------------------------------------------------------------------------------------------------
-- SECOND STAGE PIPELINE
	MUXA_SEL	   : out std_logic;  -- MUX-A Sel
    	MUXB_SEL           : out std_logic;  -- MUX-B Sel
    	ALU_OUT1           : out std_logic;  -- ALU Output Register Enable
    	EN_REGB2	   : out std_logic;  -- B2 enable
	SEL_TYPE           : out std_logic;  -- Select if R-Type or I-type
    	EN_RW2	           : out std_logic;  -- register for write 2

    -- ALU Operation Code
    	ALUOPCODE         : out aluOp; 

-- MEM Control Signals 
-------------------------------------------------------------------------------------------------
--THIRD STAGE PIPELINE
   
 	DRAM_OE            : out std_logic;  -- Data RAM Output Enable
	DRAM_RE            : out std_logic;  -- Data RAM Read Enable
    	DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    	LMD_LATCH_EN       : out std_logic;  -- LMD Register Latch Enable
   	ALU_OUT2           : out std_logic;  -- Register that contains output of the Alu
	EN_RW3	           : out std_logic;  -- register for write 3
	
-- WB Control signals
--------------------------------------------------------------------------------------------------
--FOURTH STAGE PIPELINE

    	WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    	RF_WE              : out std_logic;  -- Register File Write Enable
	SEL_MUX_PC	   : out std_logic); -- It selects branch or not

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

  type mem_array is array (integer range 0 TO MICROCODE_MEM_SIZE - 1 ) of std_logic_vector(CW_SIZE - 1 downto 0);
  CONSTANT cw_mem : mem_array := 
			       ("110000110100011", -- R type      			0
 				"000000100000000", --					1
 				"110010011100011", -- J     (0x02)			2 
 				"110010000000011", -- JAL   (0x03) 			3
 				"111100100000011", -- BEQZ  (0x04)			4
 				"111000100000011", -- BNEZ  (0x05)			5
 				"000000000000000", -- BFPT  (0x06)  NOT IMPLEMENTED    6
 				"000000000000000", -- BFPT  (0x07)  NOT IMPLEMENTED	7
 				"110000111000011", -- ADDI  (0X08)			8
 				"110001111000011", -- ADDUI (0x09)  			9
				"110000111000011", -- SUBI  (0x0A)  			10
 				"110001111000011", -- SUBUI  (0x0B)  			11
 				"110001111000011", -- ANDI  (0x0C)  			12	
 				"110001111000011", -- ORI  (0x0D)  			13
 				"110001111000011", -- XORI  (0x0E)  			14
 				"000000000000000", -- LHI  (0x0F)  NOT IMPLEMENTED	15
 				"000000000000000", -- RFE  (0x10)  NOT IMPLEMENTED	16
 				"000000000000000", -- TRAP  (0x11)  NOT IMPLEMENTED	17
 				"000000000000000", -- JR  (0x12)  NOT IMPLEMENTED	18
 				"000000000000000", -- JALR  (0x13)  NOT IMPLEMENTED	19
 				"110001111000011", -- SLLI  (0x14)  			20
 				"000000000000000", -- NOP  (0x15)  			21
 				"110001111000011", -- SRLI  (0x16)  			22
 				"000000000000000", -- SRAI  (0x17)  NOT IMPLEMENTED	23
 				"110000111000011", -- SEQI  (0x18)  NOT IMPLEMENTED	24
 				"110000111000011", -- SNEI  (0x19)  			25
 				"110000111000011", -- SLTI  (0x1A)  			26
 				"110000111000011", -- SGTI  (0x1B)  			27
 				"110000111000011", -- SLEI  (0x1C)  			28
 				"110000111000011", -- SGEI  (0x1D)  			29
				"000000000000000", --       (0x1E)			30
 				"000000000000000", --       (0x1F)			31
 				"000000000000000", -- LB  (0x20)  NOT IMPLEMENTED	32
 				"000000000000000", -- LH  (0x21)  NOT IMPLEMENTED	33
				"000000000000000", --     (0x22)			34
 				"110000111011011", -- LW  (0x23)  			35
 				"000000000000000", -- LBU  (0x24)  NOT IMPLEMENTED	36
 				"000000000000000", -- LHU  (0x25)  NOT IMPLEMENTED	37
 				"000000000000000", -- LF  (0x26)  NOT IMPLEMENTED	38
		 		"000000000000000", -- LD  (0x27)  NOT IMPLEMENTED	39
 				"000000000000000", -- SB  (0x28)  NOT IMPLEMENTED	40
 				"000000000000000", -- SH  (0x29)  NOT IMPLEMENTED	41
 				"000000000000000", --       (0x2A)			42
 				"110000111010111", -- SW  (0x2B) 			43
 				"000000000000000", --       (0x2C)			44
 				"000000000000000", --       (0x2D) 			45
 				"000000000000000", -- SF  (0x2E)  NOT IMPLEMENTED	46
 				"000000000000000", -- SD  (0x2F)  NOT IMPLEMENTED	47
 				"000000000000000", --       (0x30)			48
 				"000000000000000", --       (0x31)			49
 				"000000000000000", --       (0x32)			50
 				"000000000000000", --       (0x33)			51
 				"000000000000000", --       (0x34)			52
 				"000000000000000", --       (0x35)			53
 				"000000000000000", --       (0x36)			54
 				"000000000000000", --       (0x37)			55
 				"000000000000000", -- ITLB  (0x38)  NOT IMPLEMENTED	56	
 				"000000000000000", --       (0x39)			57
 				"110001111000011", -- SLTUI  (0x3A)  			58
 				"110001111000011", -- SGTUI  (0x3B)  			59
 				"110001111000011", -- SLEUI  (0x3C)  			60
 				"110001111000011", -- SGEUI  (0x3D)  			61
 				"000000000000000", --        (0x3E)			62
 				"000000000000000"); --       (0x3F)			63

				
                                
  signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE-1 downto 0);   -- Func part of IR when Rtype

  signal cw0  : std_logic_vector(CW_SIZE - 1 downto 0) := (others => '0'); -- full control word read from cw_mem
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0):= (others => '0'); -- full control word read from cw_mem
  signal cw1 : std_logic_vector(CW1_SIZE -1 downto 0):= (others => '0'); -- first stage 16 BIT
  signal cw2 : std_logic_vector(CW2_SIZE - 1 downto 0):= (others => '0'); -- second stage
  signal cw3 : std_logic_vector(CW3_SIZE - 1 downto 0):= (others => '0'); -- third stage
 
 

  signal aluOpcode_i: aluOp := NOP; 
  signal aluOpcode1: aluOp := NOP;

 
begin  -- dlx_cu_rtl

IR_opcode(5 DOWNTO 0) <= IR_IN(31 downto 26);
IR_func <= IR_IN(10 downto 0);

cw0 <= cw_mem(conv_integer(IR_opcode)) ;

-- Stage one control signals
-- All registers are always activated, in order not to block the pipeline

EN_PC  		<= 	'1';
IR_EN  		<= 	'1'; 
EN_NPC1		<= 	'1'; 
EN_RF 		<= 	'1'; 
EN_IMM 		<=  	'1';
EN_NPC2 	<=  	'1';
EN_A		<= 	'1';
EN_B		<= 	'1';
EN_RW1 		<= 	'1';
ALU_OUT1 	<= 	'1';
EN_REGB2 	<=	'1';
EN_RW2 		<=	'1';
LMD_LATCH_EN 	<= 	'1';
ALU_OUT2 	<=	'1';
EN_RW3		<=	'1';
SEL_MUX_PC	<= 	TAKEN;               

-- Stage one
 --cw
RD1 		<= 	cw0(CW_SIZE-1);  --14
RD2 		<= 	cw0(CW_SIZE-2);	--13
BRANCH_EN 	<= 	cw0(CW_SIZE-3);   --12
BRANCH_TYPE 	<=	cw0(CW_SIZE-4); --11
JTYPE 		<= 	cw0(CW_SIZE-5); --10
EXT_UNSIGNED 	<= 	cw0(CW_SIZE-6); --9
SEL_J		<=	cw0(CW_SIZE-7);  --8

  
-- stage two
MUXA_SEL      	<= 	cw1(CW_SIZE - 8);  --7
MUXB_SEL      	<= 	cw1(CW_SIZE - 9); --6
SEL_TYPE 	<=	cw1(CW_SIZE - 10); --5
  
-- stage three
DRAM_OE 	<=	cw2(CW_SIZE - 11);  --4
DRAM_RE 	<=	cw2(CW_SIZE - 12);  --3
DRAM_WE 	<= 	cw2(CW_SIZE - 13);  --2
 
-- stage four
WB_MUX_SEL 	<= 	cw3(CW_SIZE - 14); --1
RF_WE      	<= 	cw3(CW_SIZE - 15); --0

-------------------------------------------------------------------------------------------------------------------------
  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '1' then  
      ---cw  <= (others => '0');              
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      aluOpcode1 <= NOP;
   
    elsif Clk= '1' and Clk'EVENT then  -- rising clock edge
      cw1 <= cw0(CW1_SIZE -1 downto 0);
      cw2 <= cw1(CW2_SIZE - 1 downto 0);
      cw3 <= cw2(CW3_SIZE - 1 downto 0);
      aluOpcode1 <= aluOpcode_i;
      end if;
  end process CW_PIPE;

   ALUOPCODE <= aluOpcode1;

-----------------------------------------------------------------------------------------------------------------------
--GIUSTO, FINITO
  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
	case conv_integer(unsigned(IR_opcode)) is
	        -- case of R type requires analysis of FUNC
		when 0 => 
			case conv_integer(unsigned(IR_func)) is
				when 4 => aluOpcode_i <= ALU_SLL;     --SHIFTER
				when 6 => aluOpcode_i <= ALU_SRL;     --SHIFTER
				when 32 => aluOpcode_i <= ALU_ADD;    --P4ADDER
				when 33 => aluOpcode_i <= ALU_ADD;    --P4ADDER addu
				when 34 => aluOpcode_i <= ALU_SUB;    --P4ADDER
				when 35 => aluOpcode_i <= ALU_SUB;    --P4ADDER subu
				when 36 => aluOpcode_i <= ALU_AND;    --LOGIC_UNIT
				when 37 => aluOpcode_i <= ALU_OR;     --LOGIC_UNIT
				when 38 => aluOpcode_i <= ALU_XOR;    --LOGIC_UNIT
				when 40 => aluOpcode_i <= ALU_SEQ;    --MAGNITUDE
				when 41 => aluOpcode_i <= ALU_SNE;    --MAGNITUDE
				when 42 => aluOpcode_i <= ALU_SLT;    --MAGNITUDE
				when 43 => aluOpcode_i <= ALU_SGT;    --MAGNITUDE
				when 44 => aluOpcode_i <= ALU_SLE;    --MAGNITUDE
				when 45 => aluOpcode_i <= ALU_SGE;    --MAGNITUDE
				when 58 => aluOpcode_i <= ALU_SLT;	--SLTU
				when 59 => aluOpcode_i <= ALU_SGT;	--SGTU
				when 60 => aluOpcode_i <= ALU_SLE;	--SLEU
				when 61 => aluOpcode_i <= ALU_SGE;	--SGEU
				when others => aluOpcode_i <= NOP;
			end case;
		when 2 => aluOpcode_i <= NOP; -- j
		when 3 => aluOpcode_i <= NOP; -- jal
		when 4 => aluOpcode_i <= NOP; -- beqz
		when 5 => aluOpcode_i <= NOP; -- bnez
		when 8 => aluOpcode_i <= ALU_ADD; -- addi
		when 9 => aluOpcode_i <= ALU_ADD; -- addui
		when 10 => aluOpcode_i <= ALU_SUB; -- subi
		when 11 => aluOpcode_i <= ALU_SUB; -- subi
		when 12 => aluOpcode_i <= ALU_AND; -- andi
		when 13 => aluOpcode_i <= ALU_OR; -- ori
		when 14 => aluOpcode_i <= ALU_XOR; -- xori
		when 20 => aluOpcode_i <= ALU_SLLI; -- slli
		when 21 => aluOpcode_i <= NOP; -- nop
		when 22 => aluOpcode_i <= ALU_SRLI; -- srli
		when 24 => aluOpcode_i <= ALU_SEQ; --SEQI
		when 25 => aluOpcode_i <= ALU_SNE; -- snei
		when 26 => aluOpcode_i <= ALU_SLT; --slti
		when 27 => aluOpcode_i <= ALU_SGT; --sgti
		when 28 => aluOpcode_i <= ALU_SLE; -- slei
		when 29 => aluOpcode_i <= ALU_SGE; -- sgei
		when 35 => aluOpcode_i <= ALU_ADD; -- lw
		when 43 => aluOpcode_i <= ALU_ADD; -- sw
		when 58 => aluOpcode_i <= ALU_SLT; --SLTUI
		when 59 => aluOpcode_i <= ALU_SGT; --SGTUI
		when 60 => aluOpcode_i <= ALU_SLE; --sleui
		when 61 => aluOpcode_i <= ALU_SGE; --sgeui
		when others => aluOpcode_i <= NOP;
	 end case;
	end process ALU_OP_CODE_P;
---------------------------------------------------------------------------------------------------------------------------

end dlx_cu_hw;
