-- calculator datapath
-- Copyright 2005-2018 Eric Smith <spacewar@gmail.com>

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calc_datapath is
  generic (digits: integer := 14);
  port (clk:          in  std_logic;
        bcd:          in  std_logic;
        subtract:     in  std_logic;
        field_select: in  std_logic_vector (2 downto 0);
        d_in:         in  std_logic_vector (digits * 4 - 1 downto 0);
        load_a:       in  std_logic;
        load_b:       in  std_logic;
        c_in:         in  std_logic;
        s_output:     out std_logic_vector (digits * 4 - 1 downto 0);
        c_output:     out std_logic);
end calc_datapath;

architecture rtl of calc_datapath is
  subtype digit_index is unsigned (3 downto 0);
  signal ptr_sel_q:       std_logic;
  signal p_reg:           digit_index;
  signal q_reg:           digit_index;
  signal bcd_reg:         std_logic;
  signal subtract_reg:    std_logic;
  signal a_reg:           std_logic_vector (digits * 4 - 1 downto 0);
  signal b_reg:           std_logic_vector (digits * 4 - 1 downto 0);
  signal s:               std_logic_vector (digits * 4 - 1 downto 0);
  signal s_reg:           std_logic_vector (digits * 4 - 1 downto 0);
  signal c_in_reg:        std_logic;
  signal c_out:           std_logic;
  signal c_out_reg:       std_logic;
  signal leftmost_digit:  digit_index;
  signal rightmost_digit: digit_index;
  signal digit_enable:    std_logic_vector (digits - 1 downto 0);
begin

  tef_g: entity work.tef_decode_nut(rtl)
    port map (field_select    => field_select,
              p               => p_reg,
              q               => q_reg,
              ptr_sel_q       => ptr_sel_q,
              rightmost_digit => rightmost_digit,
              leftmost_digit  => leftmost_digit,
              digit_enable    => digit_enable);

  process (clk)
  begin
    if rising_edge (clk) then
     bcd_reg <= bcd;
     subtract_reg <= subtract;
     if load_a = '1' then
       a_reg <= d_in;
     end if;
     if load_b = '1' then
       b_reg <= d_in;
     end if;
     c_in_reg <= c_in;
     s_reg <= s;
     c_out_reg <= c_out;
    end if;
  end process;
  
  s_output <= s_reg;
  c_output <= c_out_reg;

  ba: entity work.wide_bcd_alu(rtl)
    generic map (digits => 14)
    port map (bcd => bcd_reg,
              subtract => subtract_reg,
              a => a_reg,
              b => b_reg,
              c_in => c_in_reg,
              s => s,
              c_out => c_out,
              leftmost_digit => std_logic_vector(leftmost_digit),
              digit_enable => digit_enable);

end rtl;

