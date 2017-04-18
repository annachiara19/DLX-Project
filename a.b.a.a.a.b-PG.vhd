library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PG is
port ( generalG: IN std_logic;
      generalP: IN std_logic;
      generalGminus: IN std_logic;
      generalPminus: IN std_logic;
      Gout: OUT std_logic;
      Pout: OUT std_logic);
end PG;

architecture behavioral of PG is
begin
Gout <= generalG or (generalP and generalGminus);
Pout <= generalP and generalPminus;
end behavioral;
