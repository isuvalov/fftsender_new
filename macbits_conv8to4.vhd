library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;


entity macbits_conv8to4 is
	generic(
		MSB:integer:=1
		);
	 port(
		 clk: in std_logic;

		 data_i: in std_logic_vector(7 downto 0);
		 ce_i : in std_logic;
		 dv_i : in std_logic;

		 data_o: out std_logic_vector(3 downto 0);
		 dv_o : out std_logic
	     );
end macbits_conv8to4;


architecture macbits_conv8to4 of macbits_conv8to4 is

signal cnt_conv:std_logic:='0';
signal data_reg:std_logic_vector(7 downto 0);

signal s_data_o: std_logic_vector(3 downto 0);
signal s_dv_o,ce_1w,dv_reg : std_logic;


begin

process(clk) is
begin
	if rising_edge(clk) then
		ce_1w<=ce_i;
		if MSB=1 then
			if ce_i='1' then
				data_reg<=data_i;
				s_data_o<=data_i(7 downto 4);				
				s_dv_o<=dv_i;
				dv_reg<=dv_i;
			elsif ce_1w='1' then
	            s_data_o<=data_reg(3 downto 0);
				s_dv_o<=dv_reg;
			else
				s_dv_o<='0';
				s_data_o<=x"0";
			end if;
		else
			if ce_i='1' then
				data_reg<=data_i;
				s_data_o<=data_i(3 downto 0);
				s_dv_o<=dv_i;
				dv_reg<=dv_i;
			elsif ce_1w='1' then
	            s_data_o<=data_reg(7 downto 4);
				s_dv_o<=dv_reg;
			else
				s_dv_o<='0';
				s_data_o<=x"0";
			end if;
		end if;
		dv_o<=s_dv_o;
		data_o<=s_data_o;
	end if;
end process;

end macbits_conv8to4;
