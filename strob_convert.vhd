library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity strob_convert is
	 port(
		 clk_a: in std_logic;
		 clk_b: in std_logic; --# must be quickly than clk_signal

		 strob_a: in std_logic;
		 strob_b: out std_logic
	     );
end strob_convert;


architecture strob_convert of strob_convert is


signal s_strob_b:std_logic;

begin
	
process (clk_a,strob_a) is
begin
	if strob_a='1' then
		s_strob_b<='1';
	elsif falling_edge(clk_a) then
		s_strob_b<='0';
	end if;
end process;


process (clk_b) is
begin
	if rising_edge(clk_b) then
		strob_b<=s_strob_b;
	end if;
end process;


end strob_convert;
