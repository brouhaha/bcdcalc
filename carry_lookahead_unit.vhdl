-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;

entity carry_lookahead_unit is
  generic (width: integer);
  port (c_in:  in  std_logic;
        g_in:  in  std_logic_vector (width-1 downto 0);
        p_in:  in  std_logic_vector (width-1 downto 0);
        c_out: out std_logic_vector (width downto 1));
end carry_lookahead_unit;

architecture behavioral of carry_lookahead_unit is
  function all_ones(val: in std_logic_vector) return std_logic is
  begin
    if val = (val'range => '1')	then
      return '1';
    else
      return '0';
    end if;
  end all_ones;
begin
  process (c_in, p_in, g_in)					
    variable val: std_logic;
  begin
    for i in 0 to width - 1 loop
      val := g_in (i);
      if i >= 1 then
        for j in i downto 1 loop
          val := val or (all_ones (p_in (i downto j)) and g_in (j - 1));
        end loop;
      end if;
      val := val or (all_ones (p_in (i downto 0)) and c_in);
      c_out (i + 1) <= val; 
    end loop;
  end process;
end behavioral;
