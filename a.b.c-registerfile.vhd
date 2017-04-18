library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all; --for logarithm
use WORK.all;
use WORK.myTypes.all;
USE WORK.LOGFUNCTION.ALL;

entity register_file is
  generic ( REG_SIZE	   	:integer := 32;
	   RF_REGISTERS		: integer := 32);
 port (  CLK: IN std_logic;
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
end register_file;

architecture beh of register_file is
        -- suggested structures
        subtype REG_ADDR is natural range 0 to (REG_SIZE-1); -- using natural type
	--senza scrivere subtype potevo scrivere  "type REG_ARRAY is array(31 downto 0) of std_logic_vector(63 downto 0)"; 
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(REG_SIZE-1 downto 0); 	
	signal REGISTERS : REG_ARRAY; 	
begin 
--togli il clock

OUT1<=REGISTERS(conv_integer(ADD_RD1));
OUT2<=REGISTERS(conv_integer(ADD_RD2));

P1: PROCESS(RESET, WR, DATAIN, ADD_WR)
begin
    if(RESET = '1') then
	--clean all registers if reset is equal to 1
	REGISTERS <= (OTHERS => (OTHERS => '0'));    
	--start the operations if enable signal is active 
    else
	--if WR=1 write the datain into register selected by address_write
	if(WR ='1' and conv_integer(ADD_WR) /= 0) then 
		REGISTERS(conv_integer(ADD_WR)) <= DATAIN;
	
	 end if;
     end if;
end process P1; 

end beh;


