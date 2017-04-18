library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use WORK.all;
use WORK.myTypes.all;


--I'm choosing a 10-bit addressable memory. 1024 addresses

entity DRAM is
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
end DRAM;


architecture behavioral of DRAM is

--structure of DRAM
type DRAM_S is array(  0 to NLine-1) of std_logic_vector( 7 downto 0) ; --BYTE ADDRESSABLE
signal MY_DRAM : DRAM_S ;


begin 

process(clk)
begin
if(clk = '1' and clk'EVENT)  then  --Synchronous reset
	if ( rst = '1') then 
		MY_DRAM <= ( others => (others => '0') );
	else
		if( RE = '1') then 
			if( OE = '1') then
			data_out <= MY_DRAM( conv_integer(in_address)) & MY_DRAM( conv_integer(in_address) + 1) & 
				MY_DRAM( conv_integer(in_address) + 2) & MY_DRAM( conv_integer(in_address) +3) ;
			end if;
		else 
			if( WE = '1') then 
			--BIG ENDIAN, dal MSB al LSB
			MY_DRAM(conv_integer( in_address))    <= data_in( 31 downto 24);
			MY_DRAM(conv_integer( in_address) +1) <= data_in( 23 downto 16);
			MY_DRAM(conv_integer( in_address) +2) <= data_in( 15 downto 8);
			MY_DRAM(conv_integer( in_address) +3) <= data_in( 7 downto 0);
			end if;
		end if;
	end if;
end if;
end process;

end behavioral;