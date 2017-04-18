library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Gblock is
port( generalG: IN std_logic;
      generalP: IN std_logic;
      generalGminus: IN std_logic;
      Gout: OUT std_logic);
end Gblock;

architecture behavioral of Gblock is
begin
Gout <= generalG or (generalP and generalGminus);
end behavioral;
