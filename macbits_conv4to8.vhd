library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;


entity macbits_conv4to8 is
	generic(
		MSB:integer:=1
		);
	 port(
		 clk: in std_logic;

		 data_i: in std_logic_vector(3 downto 0);
		 dv_i : in std_logic;

		 data_o: out std_logic_vector(7 downto 0);
		 ce_o : out std_logic;
		 dv_o : out std_logic
	     );
end macbits_conv4to8;


architecture macbits_conv4to8 of macbits_conv4to8 is

signal cnt_conv,dv_i_1w,dv_i_2w,s_ce:std_logic:='0';
signal data_reg:std_logic_vector(7 downto 0);

begin

process(clk) is
begin
	if rising_edge(clk) then
		dv_i_1w<=dv_i;
		dv_i_2w<=dv_i_1w;
		if dv_i='1' and dv_i_1w='0' then
			cnt_conv<='0';
			if MSB=1 then
				data_reg(3 downto 0)<=data_i;
			else
--				data_reg(3 downto 0)<=data_i;
				data_reg(7 downto 4)<=data_i;
			end if;
			s_ce<='0';
		else
			if MSB=1 then
				data_reg<=data_reg(3 downto 0)&data_i;
			else
				data_reg<=data_i&data_reg(7 downto 4);
			end if;

			cnt_conv<=not cnt_conv;
			s_ce<=not cnt_conv;
		end if;
		ce_o<=s_ce;
		data_o<=data_reg;
		dv_o<=dv_i_2w;
	end if;
end process;

end macbits_conv4to8;
