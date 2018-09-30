-- BCD/Binary Adder/Subtractor
-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_alu is
    port (bcd:      in  std_logic;
	  subtract: in  std_logic;
	  a:        in  std_logic_vector (3 downto 0);
	  b:        in  std_logic_vector (3 downto 0);
	  c_in:     in  std_logic;
	  s:        out std_logic_vector (3 downto 0);
	  c_out:    out std_logic);
end bcd_alu;

architecture rtl of bcd_alu is

  signal r:      unsigned (3 downto 0);
  signal b_comp: unsigned (3 downto 0);
  signal a_ext:  unsigned (4 downto 0);
  signal b_ext:  unsigned (4 downto 0);
  signal c_ext:  unsigned (0 downto 0);
  signal sum1:   unsigned (4 downto 0);
  signal over_9: std_logic;
  signal d_ext:  unsigned (4 downto 0);
  signal sum2:   unsigned (4 downto 0);

begin
  r <= "1001" when bcd = '1'
  else "1111";

  b_comp <= unsigned (r) - unsigned (b);

  a_ext <= unsigned ("0" & a);

  b_ext <= unsigned ("0" & b) when subtract = '0'
      else unsigned ("0" & b_comp);

  c_ext (0) <= c_in;

  sum1 <= a_ext + b_ext + c_ext;

  over_9 <= (sum1 (4) or
             (sum1 (3) and sum1 (2)) or 
             (sum1 (3) and sum1 (1)));

  d_ext <= "00110" when (bcd and over_9) = '1' else "00000";

  sum2 <= sum1 + d_ext;

  s <= std_logic_vector (sum2 (3 downto 0));

  c_out <= sum2 (4);

end rtl;
