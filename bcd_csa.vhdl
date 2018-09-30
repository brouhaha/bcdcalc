-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_csa is
  port (bcd:      in  std_logic;
        subtract: in  std_logic;
        a:        in  std_logic_vector (3 downto 0);
        b:        in  std_logic_vector (3 downto 0);
        c_in:     in  std_logic;
        s:        out std_logic_vector (3 downto 0);
        g_out:    out std_logic;   -- generate
        p_out:    out std_logic);  -- propagate
end bcd_csa;

architecture behavioral of bcd_csa is
  signal s0:     std_logic_vector (3 downto 0);
  signal s1:     std_logic_vector (3 downto 0);
  signal c_out0: std_logic;
  signal c_out1: std_logic;
begin
  a0: entity work.bcd_alu(behavioral) port map(bcd, subtract, a, b, '0', s0, c_out0);
  a1: entity work.bcd_alu(behavioral) port map(bcd, subtract, a, b, '1', s1, c_out1);
  g_out <= c_out0;
  p_out <= c_out1;
  s <= s0 when c_in = '0' else s1;
  -- c_out <= c_out0 when c_in = '0' else c_out1;
end behavioral;
