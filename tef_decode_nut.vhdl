-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tef_decode_nut is
  generic (digits:     integer := 14;
	   exp_digits: integer := 2);
  port (field_select:    in  std_logic_vector (2 downto 0);
	p:               in  unsigned (3 downto 0);
	q:               in  unsigned (3 downto 0);
	ptr_sel_q:       in  std_logic;
        rightmost_digit: out unsigned (3 downto 0);
        leftmost_digit:  out unsigned (3 downto 0);
	digit_enable:    out std_logic_vector (digits - 1 downto 0));
end tef_decode_nut;

architecture rtl of tef_decode_nut is
  signal pt: unsigned (3 downto 0);
  signal rd: unsigned (3 downto 0);
  signal ld: unsigned (3 downto 0);
begin

  pt <= q when ptr_sel_q = '1'
        else p;

  process (field_select, p, q, pt) is
  begin
    case field_select is
      when "000" =>  -- p
        rd <= pt;
        ld <= pt;
      when "001" =>  -- x
        rd <= "0000";
        ld <= to_unsigned (exp_digits - 1, 4);
      when "010" =>  -- wp
        rd <= "0000";
        ld <= pt;
      when "100" =>  -- pq
        rd <= p;
        if p <= q then
          ld <= q;
        else
          ld <= to_unsigned (digits - 1, 4);
        end if;
      when "101" =>  -- xs
         rd <= to_unsigned (exp_digits - 1, 4);
         ld <= to_unsigned (exp_digits - 1, 4);
      when "110" =>  -- m
         rd <= to_unsigned (exp_digits, 4);
         ld <= to_unsigned (digits - 2, 4);
      when "111" =>  -- s
         rd <= to_unsigned (digits - 1, 4);
         ld <= to_unsigned (digits - 1, 4);
      when others => -- w
        rd <= "0000";
        ld <= to_unsigned (digits - 1, 4);
    end case;
  end process;

  rightmost_digit <= rd;
  leftmost_digit <= ld;

  de_g: for i in 0 to digits - 1 generate
    digit_enable (i) <= '1' when i >= rd and ((i <= ld) or (ld < rd))
                   else '0';
  end generate;

end rtl;
