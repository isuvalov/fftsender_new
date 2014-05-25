library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;


entity top_receiver is
	 port(
		 reset: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal
		 clk_mac: in std_logic;
		 port_number: in std_logic_vector(15 downto 0);
		 to_tx_module: out Trx2tx_wires;

		 data_i: in std_logic_vector(3 downto 0);
		 dv_i : in std_logic;

		 tp: out std_logic_vector(7 downto 0)
	     );
end top_receiver;


architecture top_receiver of top_receiver is

constant MSB:integer:=1;

signal cnt_conv:std_logic:='0';

signal data8:  std_logic_vector(7 downto 0);
signal dv8,ce8 : std_logic;

--signal rx2tx: Trx2tx_wires;
--signal regs_from_host: Tregs_from_host;


begin


macbits_conv4to8_i: entity work.macbits_conv4to8
	generic map(
		MSB=>MSB
		)
	 port map(
		 clk=>clk_mac,

		 data_i=>data_i,
		 dv_i =>dv_i,

		 data_o =>data8,
		 ce_o =>ce8,
		 dv_o =>dv8
	     );

udp_rx_i: entity work.udp_rx
	 port map(
		 reset =>reset,
		 clk =>clk_mac,

		 port_number=>port_number,

		 i_dv =>dv8, --# must be with i_ce 
		 i_ce =>ce8,
		 i_data =>data8,

		 rx2tx=>to_tx_module
	     );


process(clk_mac) is
begin
	if rising_edge(clk_mac) then
	end if;
end process;

end top_receiver;
