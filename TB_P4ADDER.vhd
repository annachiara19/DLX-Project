library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use WORK.all;
use WORK.myTypes.all;

entity TB_P4ADDER IS
END TB_P4ADDER;

ARCHITECTURE TB1 OF TB_P4ADDER IS

COMPONENT P4adder is 
generic( REG_SIZE : integer := 32);
port ( A: IN std_logic_vector( REG_SIZE-1 downto 0);
       B: IN std_logic_vector( REG_SIZE-1 downto 0);
       c_in: IN std_logic;         --VERY IMPORTANT. IT DETERMINES IF THE OPERATION IS ADD OR SUB
       c_out: OUT std_logic;
       somma: OUT std_logic_vector( REG_SIZE-1 downto 0));
end COMPONENT;

SIGNAL AS, BS, SS: STD_LOGIC_VECTOR( 31 DOWNTO 0);
SIGNAL CAR_IN: STD_LOGIC := '0';
SIGNAL CAR_OUT: STD_LOGIC;


BEGIN

MYP4 : P4adder PORT MAP (AS, BS, CAR_IN, CAR_OUT, SS);


AS <= X"00000002";
BS <= X"00000004";

 END TB1;
