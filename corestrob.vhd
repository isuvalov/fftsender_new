library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;

entity corestrob is
	generic(
		WIDTH:natural:=12
	);
	 port(
		 clk_signal: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal

		 data_i: in std_logic_vector(WIDTH-1 downto 0);
		 ce_i : in std_logic;

		 data_o: out std_logic_vector(WIDTH-1 downto 0);
		 ce_o : out std_logic
	     );
end corestrob;


architecture corestrob of corestrob is

signal clk_signal_bycore,clk_signal_bycore_1w,ce_i_bycore,ce_i_bycore_1w,local_ce :std_logic;
signal data_i_reg,data_i_reg_1w,datareg:std_logic_vector(data_i'Length-1 downto 0);

begin
	
process (clk_core) is
begin
	if rising_edge(clk_core) then
		clk_signal_bycore<=clk_signal;
		clk_signal_bycore_1w<=clk_signal_bycore;
		ce_i_bycore<=ce_i;
		ce_i_bycore_1w<=ce_i_bycore;
		data_i_reg<=data_i;		
	end if;
end process;

process (clk_core) is
begin
	if rising_edge(clk_core) then
		if clk_signal_bycore='1' and clk_signal_bycore_1w='0' then
			datareg<=data_i_reg;
			local_ce<=ce_i_bycore_1w;
		else
			local_ce<='0';
		end if;
	end if;
end process;

data_o<=data_i_reg;
ce_o<=local_ce;


end corestrob;
