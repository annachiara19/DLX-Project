library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.all;
use WORK.myTypes.all;

entity RCA is 
	--BEFORE IT WAS 8. RIGHT?????
	generic (N : integer := 4 );
	Port (	A:	In	std_logic_vector(N -1 downto 0);
		B:	In	std_logic_vector(N -1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(N -1 downto 0)
		--Co:	Out	std_logic
);
end RCA; 


architecture BEHAVIORAL of RCA is
signal SUMTEMP : std_logic_vector(N  downto 0) := (others=> '0');
begin
 
SUMTEMP<=  conv_std_logic_vector((conv_integer(A) + conv_integer(B) + conv_integer(Ci)),SUMTEMP'length);
--Co<= SUMTEMP(N );
S <= SUMTEMP(N -1 DOWNTO 0);

end BEHAVIORAL;

