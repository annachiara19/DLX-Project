library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use WORK.myTypes.all;

entity COMPARATOR is
generic (REG_SIZE : integer := 32);
port ( 	A: IN std_logic_vector(REG_SIZE-1 downto 0);
       	B: IN std_logic_vector(REG_SIZE-1 downto 0);
	greater: IN std_logic;    		 --SGE/ SGEI
	lower: IN std_logic;      		 --SLE/SLEI
	not_equal: IN std_logic;      		 --SNE/SNEI	
	equal: IN std_logic;
	greater_sign : IN std_logic;
	greater_unsign: IN std_logic;
       	out_comp: OUT std_logic_vector( REG_SIZE-1 downto 0));
end COMPARATOR;

architecture behavior of COMPARATOR is

signal UNO : std_logic_vector(31 downto 0) := X"00000001";
signal ZERO: std_logic_vector(31 downto 0) := X"00000000";


begin
process(greater, lower, equal, not_equal, greater_sign, greater_unsign)
begin
--SGE/SGEI
if( greater = '1') then			
	if( signed(A) > signed(B) or signed(A) = signed(B)) then 
		out_comp <= UNO;
	else 
		out_comp <= ZERO;
	end if;
--SLE/SLEI
else
	if( lower = '1') then			
		if( signed(A) < signed(B) or signed(A) = signed(B)) then 
			out_comp <= UNO;
		else 
			out_comp <= ZERO;
		end if;	
	--SNE/SNEI
	else
			if( not_equal = '1') then			
				if( signed(A) /= signed(B)) then 
					out_comp <= UNO;
				else 
					out_comp <= ZERO;
				end if;
			else --SEQ/SEQI
				if( equal = '1') then			
					if( signed(A) = signed(B)) then 
					out_comp <= UNO;
					else 
					out_comp <= ZERO;
					end if;
				else
					if(greater_sign ='1') then 
						if(signed(A) > signed(B)) then
						out_comp <= UNO;
						else 
						out_comp <= ZERO;
						end if;
					else
						if( greater_unsign = '1') then 
							if( unsigned(A) > unsigned(B)) then
							out_comp <= UNO;
							else 
							out_comp <= ZERO;
							end if;
						end if;
							
					end if;
				end if;
			end if;
	end if;
end if;
end process;

end behavior;


