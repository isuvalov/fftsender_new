library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity make_adc is
	 port(
		 reset: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal
		 pre_shift: in std_logic_vector(5 downto 0);

		 i_data_re: in std_logic_vector(11 downto 0);
		 i_data_im: in std_logic_vector(11 downto 0);
		 i_data_ce: in std_logic;
		 i_data_exp: in std_logic_vector(5 downto 0);
		 i_data_exp_ce: in std_logic;

		 o_dataout: out std_logic_vector(15 downto 0);
		 o_dataout_ce: out std_logic;
		 o_data_exp: out std_logic_vector(5 downto 0);
		 o_data_exp_ce: out std_logic
	     );
end make_adc;


architecture make_adc of make_adc is

signal dataout_ce_1w,dataout_ce_2w,data_ce_1w:std_logic;

signal s_dataout:std_logic_vector(15 downto 0);


begin

process(clk_core) is                                                                      
  begin                                                                                         
    if rising_edge(clk_core) then                                                                   
		

		o_dataout<=i_data_re(11 downto 4)&i_data_im(11 downto 4);

		o_dataout_ce<=i_data_ce;
		data_ce_1w<=i_data_ce;
		o_data_exp_ce<=i_data_ce and not(data_ce_1w);
		o_data_exp<=(others=>'0');


	end if;
end process;


end make_adc;

