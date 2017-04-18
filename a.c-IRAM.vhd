library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;
--use WORK.all;
--use WORK.myTypes.all;
-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
entity IRAM is
  generic (
    RAM_DEPTH : integer := 2048;
    I_SIZE : integer := 32);
  port (
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end IRAM;

architecture IRam_Bhe of IRAM is
  type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(7 downto 0);
  signal IRAM_mem : RAMtype;

begin  -- IRam_Bhe

  Dout <= IRAM_mem(conv_integer(unsigned(Addr))) & IRAM_mem(conv_integer(unsigned(Addr)) +1 ) & 
	  IRAM_mem(conv_integer(unsigned(Addr))+2) & IRAM_mem(conv_integer(unsigned(Addr)) + 3);

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem
  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
    variable instructionIR: std_logic_vector(I_SIZE -1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '1') then
      index := 0;
      file_open(mem_fp,"Branch.asm.mem",READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        instructionIR :=  conv_std_logic_vector(unsigned(tmp_data_u),i_size);
        --I'm filling IRAM with one Byte at a time
	IRAM_mem(index) <= instructionIR(31 downto 24);
	index := index + 1;
	IRAM_mem(index) <= instructionIR(23 downto 16);
	index := index + 1;
	IRAM_mem(index) <= instructionIR(15 downto 8);
	index := index + 1;
	IRAM_mem(index) <= instructionIR(7 downto 0);
	index := index + 1;       
      end loop;
	file_close(mem_fp);
    end if;
  end process FILL_MEM_P;

end IRam_Bhe;
