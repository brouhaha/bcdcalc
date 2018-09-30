-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wide_bcd_alu is
    generic (digits: integer := 14);
    port (bcd:            in  std_logic;
	  subtract:       in  std_logic;
	  a:              in  std_logic_vector (digits * 4 - 1 downto 0);
	  b:              in  std_logic_vector (digits * 4 - 1 downto 0);
	  c_in:           in  std_logic;
	  s:              out std_logic_vector (digits * 4 - 1 downto 0);
	  c_out:          out std_logic;
          leftmost_digit: in  std_logic_vector (3 downto 0);
          digit_enable:   in  std_logic_vector (digits - 1 downto 0));
end wide_bcd_alu;

architecture rtl of wide_bcd_alu is
	signal c_in_v: std_logic_vector (digits downto 0);
	signal g_out_v: std_logic_vector (digits - 1 downto 0);
	signal p_out_v: std_logic_vector (digits - 1 downto 0);
	signal g_out_v_masked: std_logic_vector (digits - 1 downto 0);
	signal p_out_v_masked: std_logic_vector (digits - 1 downto 0);

begin
  c_in_v (0) <= c_in;

  process (g_out_v, p_out_v, digit_enable, c_in) is
  begin
    for i in digits - 1 downto 0 loop
      if digit_enable (i) = '1' then
        g_out_v_masked (i) <= g_out_v (i);
        p_out_v_masked (i) <= p_out_v (i);
      else
        g_out_v_masked (i) <= c_in;
        p_out_v_masked (i) <= '0';
      end if;
    end loop;
  end process;                                                  

  clu0: entity work.carry_lookahead_unit(rtl)
    generic map (width => digits)
    port map (c_in => c_in,
              g_in => g_out_v_masked,
              p_in => p_out_v_masked,
              c_out => c_in_v (digits downto 1));

  g: for i in digits - 1 downto 0 generate
    csa_n: entity work.bcd_csa(rtl)
      port map (bcd => bcd,
                subtract => subtract,
                a        => a (i * 4 + 3 downto i * 4),
                b        => b (i * 4 + 3 downto i * 4),
                c_in     => c_in_v (i),
                s        => s (i * 4 + 3 downto i * 4),
                g_out    => g_out_v (i),
                p_out    => p_out_v (i));
  end generate;

  c_out <= c_in_v (to_integer (unsigned (leftmost_digit)) + 1);

end rtl;
