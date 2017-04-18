library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_ARITH.all;

package LOGFUNCTION is
    
   function log2( i : integer) return integer;
   
end package LOGFUNCTION;

package body LOGFUNCTION is
--MANU, CAMBIA
function log2( i : integer) return integer is
	variable temp    : integer := i;
	variable ret_val : integer := 1; --log2 of 0 should equal 1 because you still need 1 bit to represent 0
begin
	temp    := temp / 2;
	while temp > 1 loop
		ret_val := ret_val + 1;
		temp    := temp / 2;
	end loop;
	return ret_val;
end function log2;

end package body LOGFUNCTION;
