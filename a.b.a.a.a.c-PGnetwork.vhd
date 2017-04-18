library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PGnetwork is
port( a, b :IN std_logic;
      p, g :OUT std_logic);
end PGnetwork;

architecture behavioral of PGnetwork is
begin
p<= a xor b;
g <= a and b;
end behavioral;
