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
    	CW_SIZE            :     integer := 16);  -- Control Word Size

  port (
 	--INPUT 
    	OPCODE             : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    	FUNC               : in  std_logic_vector(FUNC_SIZE - 1 downto 0);  	
    	Clk                : in  std_logic;  -- Clock
   	Rst                : in  std_logic;  -- Reset:Active-Low
  
  	-- Prefetch Signal
    	EN_PC              : out std_logic; --ABILITA IL PROGRAMM COUNTER
  
	-- Instruction Register    
    	--IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
    	--PC_OUT             : out std_logic_vector(IR_SIZE - 1 downto 0); 
   
    	-- IF Control Signal
    	IR_EN              : out std_logic;  -- Instruction Register Latch Enable
    	EN_NPC1            : out std_logic;  -- NextProgramCounter Register Latch Enable

--CONTROL UNIT STARTS ACTIVITIES HERE  
-- ID Control Signals
-----------------------------------------------------------------------------------------------
--FIRST STAGE PIPELINE
    	EN_RF              : out std_logic;
    	RD1                : out std_logic;
    	RD2                : out std_logic;
    
    	BRANCH_EN          : out std_logic;
    	BRANCH_TYPE        : out std_logic;
	TAKEN		   : in  std_logic;
   
    	JTYPE              : out std_logic;
    	EXT_UNSIGNED       : out std_logic;
    	EN_SIGN            : out std_logic;

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
	EN_NPC3            : out std_logic;  -- NPC3 enable
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
	EN_NPC4            : out std_logic;  -- NPC4 enable
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

  type mem_array is array (integer range MICROCODE_MEM_SIZE - 1 downto 0) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := 
			       ("1100000110100011", -- R type      		0
 				"0000000100000000", --				1
 				"1100101011100011", -- J     (0x02)		2 
 				"1100101000000011", -- JAL   (0x03) 		3
 				"1111001100000011", -- BEQZ  (0x04)		4
 				"1110001100000011", -- BNEZ  (0x05)		5
 				"0000000000000000", -- BFPT  (0x06)  NOT IMPLEMENTED    6
 				"0000000000000000", -- BFPT  (0x07)  NOT IMPLEMENTED	7
 				"1100001111000011", -- ADDI  (0X08)			8
 				"0000000000000000", -- ADDUI (0x09)  NOT IMPLEMENTED	9
				"1100001111000011", -- SUBI  (0x0A)  			10
 				"0000000000000000", -- SUBUI  (0x0B)  NOT IMPLEMENTED	11
 				"1100011111000011", -- ANDI  (0x0C)  			12	
 				"1100011111000011", -- ORI  (0x0D)  			13
 				"1100011111000011", -- XORI  (0x0E)  			14
 				"0000000000000000", -- LHI  (0x0F)  NOT IMPLEMENTED	15
 				"0000000000000000", -- RFE  (0x10)  NOT IMPLEMENTED	16
 				"0000000000000000", -- TRAP  (0x11)  NOT IMPLEMENTED	17
 				"0000000000000000", -- JR  (0x12)  NOT IMPLEMENTED	18
 				"0000000000000000", -- JALR  (0x13)  NOT IMPLEMENTED	19
 				"1100011111000011", -- SLLI  (0x14)  			20
 				"0000000000000000", -- NOP  (0x15)  			21
 				"1100011111000011", -- SRLI  (0x16)  			22
 				"0000000000000000", -- SRAI  (0x17)  NOT IMPLEMENTED	23
 				"0000000000000000", -- SEQI  (0x18)  NOT IMPLEMENTED	24
 				"1100001111000011", -- SNEI  (0x19)  			25
 				"0000000000000000", -- SLTI  (0x1A)  NOT IMPLEMENTED	26
 				"0000000000000000", -- SGTI  (0x1B)  NOT IMPLEMENTED	27
 				"1100001111000011", -- SLEI  (0x1C)  			28
 				"1100001111000011", -- SGEI  (0x1D)  			29
				"0000000000000000", --       (0x1E)			30
 				"0000000000000000", --       (0x1F)			31
 				"0000000000000000", -- LB  (0x20)  NOT IMPLEMENTED	32
 				"0000000000000000", -- LH  (0x21)  NOT IMPLEMENTED	33
				"0000000000000000", --     (0x22)			34
 				"1100001111011011", -- LW  (0x23)  			35
 				"0000000000000000", -- LBU  (0x24)  NOT IMPLEMENTED	36
 				"0000000000000000", -- LHU  (0x25)  NOT IMPLEMENTED	37
 				"0000000000000000", -- LF  (0x26)  NOT IMPLEMENTED	38
		 		"0000000000000000", -- LD  (0x27)  NOT IMPLEMENTED	39
 				"0000000000000000", -- SB  (0x28)  NOT IMPLEMENTED	40
 				"0000000000000000", -- SH  (0x29)  NOT IMPLEMENTED	41
 				"0000000000000000", --       (0x2A)			42
 				"1100001111010111", -- SW  (0x2B) 			43
 				"0000000000000000", --       (0x2C)			44
 				"0000000000000000", --       (0x2D) 			45
 				"0000000000000000", -- SF  (0x2E)  NOT IMPLEMENTED	46
 				"0000000000000000", -- SD  (0x2F)  NOT IMPLEMENTED	47
 				"0000000000000000", --       (0x30)			48
 				"0000000000000000", --       (0x31)			49
 				"0000000000000000", --       (0x32)			50
 				"0000000000000000", --       (0x33)			51
 				"0000000000000000", --       (0x34)			52
 				"0000000000000000", --       (0x35)			53
 				"0000000000000000", --       (0x36)			54
 				"0000000000000000", --       (0x37)			55
 				"0000000000000000", -- ITLB  (0x38)  NOT IMPLEMENTED	56	
 				"0000000000000000", --       (0x39)			57
 				"0000000000000000", -- SLTUI  (0x3A)  NOT IMPLEMENTED	58
 				"0000000000000000", -- SGTUI  (0x3B)  NOT IMPLEMENTED	59
 				"0000000000000000", -- SLEUI  (0x3C)  NOT IMPLEMENTED	60
 				"0000000000000000", -- SGEUI  (0x3D)  NOT IMPLEMENTED	61
 				"0000000000000000", --        (0x3E)			62
 				"0000000000000000"); --       (0x3F)			63

				
                                
  signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- first stage 16 BIT
  signal cw2 : std_logic_vector(CW_SIZE - 1 - 8 downto 0); -- second stage
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 8 - 3 downto 0); -- third stage
  signal cw4 : std_logic_vector(CW_SIZE - 1 - 8 - 3 - 3 downto 0); -- fourth stage
 

  signal aluOpcode_i: aluOp := NOP; -- ALUOP defined in package
  signal aluOpcode1: aluOp := NOP;
 
begin  -- dlx_cu_rtl

--IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
--IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

cw <= cw_mem(conv_integer(IR_opcode));

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
EN_NPC3 	<=	'1';
EN_RW2 		<=	'1';
EN_NPC4 	<=	'1';
LMD_LATCH_EN 	<= 	'1';
ALU_OUT2 	<=	'1';
EN_RW3 		<= 	'1';
SEL_MUX_PC	<= 	TAKEN;               

-- Stage two control signals
 --cw
RD1 		<= 	cw(CW_SIZE-1);   --bit 15
RD2 		<= 	cw(CW_SIZE-2);	--14
BRANCH_EN 	<= 	cw(CW_SIZE-3); --13
BRANCH_TYPE 	<=	cw(CW_SIZE-4); --12
JTYPE 		<= 	cw(CW_SIZE-5);  --11
EXT_UNSIGNED 	<= 	cw(CW_SIZE-6);  --10
EN_SIGN 	<= 	cw(CW_SIZE-7);  --9
SEL_J		<=	cw(CW_SIZE-8); --8

  
-- stage three control signals
MUXA_SEL      	<= 	cw1(CW_SIZE - 9);  --7
MUXB_SEL      	<= 	cw1(CW_SIZE - 10); --6
SEL_TYPE 	<=	cw1(CW_SIZE - 11); --5
  
-- stage four control signals
DRAM_OE 	<=	cw2(CW_SIZE - 12); ---4
DRAM_RE 	<=	cw2(CW_SIZE - 13);  --3
DRAM_WE 	<= 	cw2(CW_SIZE - 14);  --2
  
-- stage five control signals
WB_MUX_SEL 	<= 	cw3(CW_SIZE - 15); --1
RF_WE      	<= 	cw3(CW_SIZE - 16); --0

-------------------------------------------------------------------------------------------------------------------------
  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '1' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
      aluOpcode1 <= NOP;

    elsif Clk'event and Clk = '1' then  -- rising clock edge
      cw1 <= cw;
      cw2 <= cw1(CW_SIZE - 1 - 8 downto 0);
      cw3 <= cw2(CW_SIZE - 1 - 11 downto 0);
      cw4 <= cw3(CW_SIZE - 1 - 14 downto 0);
 
      aluOpcode1 <= aluOpcode_i;
  --    aluOpcode2 <= aluOpcode1;
  --    aluOpcode3 <= aluOpcode2;
    end if;
  end process CW_PIPE;

   ALUOPCODE <= aluOpcode1;
-- ALU_OPCODE <= aluOpcode3;
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
				when 34 => aluOpcode_i <= ALU_SUB;    --P4ADDER
				when 36 => aluOpcode_i <= ALU_AND;    --LOGIC_UNIT
				when 37 => aluOpcode_i <= ALU_OR;     --LOGIC_UNIT
				when 38 => aluOpcode_i <= ALU_XOR;    --LOGIC_UNIT
				when 41 => aluOpcode_i <= ALU_SNE;    --MAGNITUDE
				when 44 => aluOpcode_i <= ALU_SLE;    --MAGNITUDE
				when 45 => aluOpcode_i <= ALU_SGE;    --MAGNITUDE
				when others => aluOpcode_i <= NOP;
			end case;
		when 2 => aluOpcode_i <= NOP; -- j
		when 3 => aluOpcode_i <= NOP; -- jal
		when 4 => aluOpcode_i <= NOP; -- beqz
		when 5 => aluOpcode_i <= NOP; -- bnez
		when 8 => aluOpcode_i <= ALU_ADD; -- addi
		when 10 => aluOpcode_i <= ALU_SUB; -- subi
		when 12 => aluOpcode_i <= ALU_AND; -- andi
		when 13 => aluOpcode_i <= ALU_OR; -- ori
		when 14 => aluOpcode_i <= ALU_XOR; -- xori
		when 20 => aluOpcode_i <= ALU_SLLI; -- slli
		when 21 => aluOpcode_i <= NOP; -- nop
		when 22 => aluOpcode_i <= ALU_SRLI; -- srli
		when 25 => aluOpcode_i <= ALU_SNEI; -- snei
		when 28 => aluOpcode_i <= ALU_SLEI; -- slei
		when 29 => aluOpcode_i <= ALU_SGEI; -- sgei
		when 35 => aluOpcode_i <= ALU_ADD; -- lw
		when 43 => aluOpcode_i <= ALU_ADD; -- sw
		when others => aluOpcode_i <= NOP;
	 end case;
	end process ALU_OP_CODE_P;
---------------------------------------------------------------------------------------------------------------------------

end dlx_cu_hw;
