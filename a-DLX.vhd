library ieee;
use ieee.std_logic_1164.all;
use WORK.all;
use work.myTypes.all;

--DRAM E IRAM VANNO FUORI AL DLX

entity DLX is
  generic (
    IR_SIZE      : integer := 32;        -- Instruction Register Size
    FUNC_SIZE          :     integer := 11;
    PC_SIZE      : integer := 32         -- Program Counter Size
    );      				 -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk 		: in std_logic;
    Rst 		: in std_logic;
   --IRAM SIGNALS
    PC 			: out std_logic_vector(PC_SIZE - 1 downto 0);
    IRam_DOut 		: in std_logic_vector(IR_SIZE - 1 downto 0);

   --DRAM SIGNALS
    IN_DRAM		: out std_logic_vector( 9 downto 0);
    DATA_DRAM	   	: out std_logic_vector( IR_SIZE-1 downto 0);
    IN_LMD		: in std_logic_vector( IR_SIZE-1 downto 0);
    DRAM_OE            	: out std_logic;  
    DRAM_RE            	: out std_logic;  
    DRAM_WE	        : out std_logic
);               
end DLX;


-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
--
architecture dlx_rtl of DLX is
---------------------------------------------------------------------------------------------
-- Components Declaration
---------------------------------------------------------------------------------------------

--DATAPATH

 component DATAPATH is
 generic (  	
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
end component;
-----------------------------------------------------------------------------------------------------------
--CONTROL UNIT

  component dlx_cu is
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
    	EN_PC              : out std_logic;      
    --	IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);
  --  	PC_OUT             : out std_logic_vector(IR_SIZE - 1 downto 0); 
    	IR_EN              : out std_logic;  -- Instruction Register Latch Enable
    	EN_NPC1            : out std_logic;  -- NextProgramCounter Register Latch Enable
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
	EN_IMM             : out std_logic;  
    	EN_NPC2            : out std_logic;
    	EN_A	           : out std_logic;  
    	EN_B               : out std_logic;  
 	EN_RW1	           : out std_logic;  
	MUXA_SEL	   : out std_logic;  
    	MUXB_SEL           : out std_logic;  
    	ALU_OUT1           : out std_logic;  
    	EN_REGB2	   : out std_logic; 
	EN_NPC3            : out std_logic;  
	SEL_TYPE           : out std_logic; 
    	EN_RW2	           : out std_logic; 
    	ALUOPCODE          : out aluOp; 
 	DRAM_OE            : out std_logic;  
	DRAM_RE            : out std_logic;  
    	DRAM_WE            : out std_logic; 
	EN_NPC4            : out std_logic;  
    	LMD_LATCH_EN       : out std_logic; 
   	ALU_OUT2           : out std_logic; 
	EN_RW3	           : out std_logic;  
    	WB_MUX_SEL         : out std_logic;  
    	RF_WE              : out std_logic; 
	SEL_MUX_PC	   : out std_logic); 

end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
--  signal PC : std_logic_vector(PC_SIZE - 1 downto 0);

  -- Instruction Ram Bus signals
--  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals (QUELLO CHE IL DP METTE SUL BUS)
  signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);
  signal ADDR_DRAM_BUS: std_logic_vector( 9 DOWNTO 0);
  signal DATA_DRAM_BUS: std_logic_vector( IR_SIZE -1 downto 0);
  signal DRAM_OE_BUS: std_logic;
  signal DRAM_RE_BUS: std_logic;
  signal DRAM_WE_BUS: std_logic; 

  -- Control Unit Bus signals
  signal OPCODE_i : std_logic_vector(5 downto 0);
  signal FUNC_i: std_logic_vector( 10 downto 0);
  signal EN_PC_i : std_logic;
  signal IR_EN_i : std_logic;
  signal EN_NPC1_i : std_logic;
  signal EN_RF_i: std_logic;
  signal EN_RD1_i : std_logic;
  signal EN_RD2_i: std_logic;
  signal BRANCH_EN_i: std_logic;
  signal ALUOPCODE_i : aluOp;
  signal BRANCH_TYPE_i : std_logic;
  signal TAKEN_i: std_logic;
  signal JTYPE_i : std_logic;
  signal EXT_UNSIGNED_i : std_logic;
  signal EN_SIGN_i: std_logic;
  signal SEL_J_i: std_logic;
  signal EN_IMM_i : std_logic;
  signal EN_NPC2_i : std_logic;
  signal EN_A_i,  EN_B_i: std_logic;
  signal EN_RW_i : std_logic;
  signal MUXA_SEL_i, MUXB_SEL_i : std_logic;
  signal ALU_OUT1_i: std_logic;
  signal EN_REGB2_i : std_logic;
  signal EN_NPC3_i: std_logic;
  signal SEL_TYPE_i: std_logic;
  signal EN_RW2_i : std_logic;
  signal IN_DRAM_i: std_logic_vector( 9 downto 0);
  signal DATA_DRAM_i: std_logic_vector( 31 downto 0);
  signal IN_LMD_i : std_logic_vector( 31 downto 0);
  signal DRAM_OE_i : std_logic;
  signal DRAM_RE_i : std_logic;
  signal DRAM_WE_i: std_logic;
  signal EN_NPC4_i: std_logic;
  signal LMD_LATCH_EN_i : std_logic;
  signal ALU_OUT2_i: std_logic;
  signal EN_RW3_i: std_logic;
  signal WB_MUX_SEL_i: std_logic;
  signal RF_WE_i : std_logic;
  signal SEL_MUX_PC_i : std_logic;
  signal RD1_i, RD2_i, EN_A, EN_B : std_logic;

  -- Data Ram Bus signals
  signal DRAM_OUT_BUS : std_logic_vector( 31 downto 0);

  begin  -- DLX

    -- This is the input to program counter: currently zero 
    -- so no uptade of PC happens
    -- TO BE REMOVED AS SOON AS THE DATAPATH IS INSERTED!!!!!
    -- a proper connection must be made here if more than one
    -- instruction must be executed
    -- PC_BUS <= PC_OUT; 


    -- purpose: Instruction Register Process
    -- type   : sequential
    -- inputs : Clk, Rst, IRam_DOut, IR_LATCH_EN_i
    -- outputs: IR_IN_i
--    IR_P: process (Clk, Rst)
--    begin  -- process IR_P
--      if Rst = '1' then                 -- asynchronous reset (active low)
--        IR <= (others => '0');
--      elsif Clk'event and Clk = '1' then  -- rising clock edge
--        if (IR_EN_i = '1') then
--          IR <= IRam_DOut;
--	  OPCODE_i <= IR( 31 downto 26);  --IR or IRam_DOut?
--	  FUNC_i <= IR( 10 downto 0);
--        end if;
--      end if;
--    end process IR_P;

    -- purpose: DRAM Process
    -- type   : sequential
    -- inputs : Clk, Rst, DRAM_OE_i, ADDR_DRAM_BUS, DATA_DRAM_BUS, DRAM_OUT_BUS
    -- outputs: IN_DRAM_i,  DATA_DRAM_i, IN_LMD_i 
--    DRAM_P : process(Clk, Rst)
--    begin
--	if Clk'event and Clk = '1' then
--	 	if(  DRAM_OE_i = '1') then
-- 		   IN_DRAM_i <=  ADDR_DRAM_BUS;
--		   DATA_DRAM_i <= DATA_DRAM_BUS;
--		   IN_LMD_i <= DRAM_OUT_BUS;
--		end if;
--	end if;
--    end process DRAM_P ;

    -- purpose: Program Counter Process
    -- type   : sequential
    -- inputs : Clk, Rst, PC_BUS
    -- outputs: IRam_Addr
--    PC_P: process (Clk, Rst)
--    begin  -- process PC_P
--      if Rst = '1' then                 -- asynchronous reset (active low)
--        PC <= (others => '0');
--      elsif Clk'event and Clk = '1' then  -- rising clock edge
--        if (EN_PC_i = '1') then
--          PC <= PC_BUS;
--        end if;
--      end if;
--    end process PC_P;

--  pc <= pc_bus;

  DATAPATH_I : DATAPATH port map (
		OPCODE          => OPCODE_i, 
    		FUNC            => FUNC_i,   
    		Clk             => Clk,
        	Rst             => Rst,
    		EN_PC           => EN_PC_i,
		PC_OUT          => PC_BUS,	 --PC?
    		IR_IN           => IR,           --IR?
    		IR_EN           => IR_EN_i,
    		EN_NPC1         => EN_NPC1_i,
    		EN_RF           => EN_RF_i,
    		RD1             => EN_RD1_i,
    		RD2             => EN_RD2_i,
    		BRANCH_EN       => BRANCH_EN_i,
    		BRANCH_TYPE     => BRANCH_TYPE_i,
		TAKEN		=> TAKEN_i,
   		JTYPE           => JTYPE_i,
    		EXT_UNSIGNED    => EXT_UNSIGNED_i,
    		EN_SIGN         => EN_SIGN_i,
		SEL_J		=> SEL_J_i,
    		EN_IMM          => EN_IMM_i,
    		EN_NPC2         => EN_NPC2_i,
    		EN_A            => EN_A_i,
    		EN_B            => EN_B_i,
 		EN_RW1	        => EN_RW_i,
		ALUOPCODE       => ALUOPCODE_i,
		MUXA_SEL	=> MUXA_SEL_i,
    		MUXB_SEL        => MUXB_SEL_i,
    		ALU_OUT1        => ALU_OUT1_i,
    		EN_REGB2	=> EN_REGB2_i,
		EN_NPC3         => EN_NPC3_i,
		SEL_TYPE        => SEL_TYPE_i,
    		EN_RW2	        => EN_RW2_i,
		IN_DRAM		=> ADDR_DRAM_BUS,
		DATA_DRAM	=> DATA_DRAM_BUS,
		IN_LMD		=> IN_LMD_i,
		EN_NPC4          => EN_NPC4_i,
    		LMD_LATCH_EN     => LMD_LATCH_EN_i,
   		ALU_OUT2         => ALU_OUT2_i,
		EN_RW3	         => EN_RW3_i,
    		WB_MUX_SEL       => WB_MUX_SEL_i,
    		RF_WE            => RF_WE_i,
		SEL_MUX_PC	 => SEL_MUX_PC_i);
	
	CU_I : dlx_cu PORT MAP(   	
		OPCODE   	=> IR(31 downto 26),
    		FUNC         	=> IR(FUNC_SIZE - 1 downto 0), 
    		Clk        	=> Clk,
   		Rst           	=> Rst,
    		EN_PC           => EN_PC_i,
    		--IR_IN          	=> IR, --------------------
    		--PC_OUT          => PC, ----------------------
    		IR_EN           => IR_EN_i,
    		EN_NPC1       	=> EN_NPC1_i,	
    		EN_RF      	=> EN_RF_i,
    		RD1            	=> RD1_i,
    		RD2          	=> RD2_i,
    		BRANCH_EN       => BRANCH_EN_i,
    		BRANCH_TYPE    	=> BRANCH_TYPE_i, 
		TAKEN		=> TAKEN_i, 
    		JTYPE           => JTYPE_i,
    		EXT_UNSIGNED    => EXT_UNSIGNED_i,
    		EN_SIGN         => EN_SIGN_i,
	 	SEL_J		=>  SEL_J_i,
    		EN_IMM          => EN_IMM_i,
    		EN_NPC2         => EN_NPC2_i,
    		EN_A            => EN_A_i,
    		EN_B            => EN_B_i,
 		EN_RW1	        => EN_RW_i,
		ALUOPCODE       => ALUOPCODE_i,
		MUXA_SEL	=> MUXA_SEL_i,
    		MUXB_SEL        => MUXB_SEL_i,
    		ALU_OUT1        => ALU_OUT1_i,
    		EN_REGB2	=> EN_REGB2_i,
		EN_NPC3         => EN_NPC3_i,
		SEL_TYPE        => SEL_TYPE_i,
    		EN_RW2	        => EN_RW2_i,
 		DRAM_OE         => DRAM_OE_i,
		DRAM_RE         => DRAM_RE_i,
    		DRAM_WE         => DRAM_WE_i,
		EN_NPC4          => EN_NPC4_i,
    		LMD_LATCH_EN     => LMD_LATCH_EN_i,
   		ALU_OUT2         => ALU_OUT2_i,
		EN_RW3	         => EN_RW3_i,
    		WB_MUX_SEL       => WB_MUX_SEL_i,
    		RF_WE            => RF_WE_i,
		SEL_MUX_PC	 => SEL_MUX_PC_i);

	PC <= PC_BUS;
    
    
end dlx_rtl;
