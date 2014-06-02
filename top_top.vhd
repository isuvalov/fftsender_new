library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;


entity top_top is
	generic(
		SWAP_SIGNALBITS:integer:=0;
		CLKCORE_EQUAL_CLKSIGNAL:integer:=1 --# if it =1 clk_signal=clk_core, else clk_core>>clk_signal
	);
	 port(
		 reset: in std_logic;
		 clk_signal: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal
		 clk_mac: in std_logic;

		 payload_is_counter: in std_logic;
		 PayloadIsZERO: in std_logic;
		 send_adc_data: in std_logic;

		 udp_IPaddr: in std_logic_vector(31 downto 0);  --# UDP port number
		 udp_port_number: in std_logic_vector(15 downto 0);  --# UDP port number

		 pre_shift: in std_logic_vector(5 downto 0);
		 i_direction : in std_logic;

		 signal_ce : in std_logic;
		 signal_start: in std_logic;
		 signal_real: in std_logic_vector(11 downto 0);
		 signal_imag: in std_logic_vector(11 downto 0);

		 data_out: out std_logic_vector(3 downto 0);
		 dv : out std_logic;

		 data_i: in std_logic_vector(3 downto 0);
		 dv_i : in std_logic;

		 tp_tx: out std_logic_vector(7 downto 0);
		 tp_rx: out std_logic_vector(7 downto 0)
	     );
end top_top;


architecture top_top of top_top is

signal reset_tx,reset_rx:std_logic;
signal to_tx_module: Trx2tx_wires;
signal s_data_out: std_logic_vector(3 downto 0);
signal s_dv : std_logic;


begin


process(clk_core) is 
begin
	if rising_edge(clk_core) then
		reset_tx<=reset;
		reset_rx<=reset;
	end if;
end process;

top_sender_i: entity work.top_sender
	generic map(
		SWAP_SIGNALBITS=>SWAP_SIGNALBITS,
		CLKCORE_EQUAL_CLKSIGNAL=>CLKCORE_EQUAL_CLKSIGNAL --# if it =1 clk_signal=clk_core, else clk_core>>clk_signal
	)
	 port map(
		 reset=>reset_tx,
		 clk_signal=>clk_signal,
		 clk_core=>clk_core, --# must be quickly than clk_signal
		 clk_mac=>clk_mac,

		 payload_is_counter=>payload_is_counter,
		 PayloadIsZERO=>PayloadIsZERO,
		 send_adc_data=>send_adc_data,

		 udp_IPaddr=>udp_IPaddr,  --# UDP port number
		 udp_port_number=>udp_port_number,  --# UDP port number

		 pre_shift=>pre_shift,
		 i_direction =>i_direction,

		 signal_ce =>signal_ce,
		 signal_start =>signal_start,
		 signal_real =>signal_real,
		 signal_imag =>signal_imag,

		 data_out =>s_data_out,
		 dv =>s_dv,

		 to_tx_module=>to_tx_module,
		 tp =>tp_rx
	     );


output_p: process (clk_mac) is
begin
     if falling_edge (clk_mac) then
	     data_out<=s_data_out;
         dv<=s_dv;
	  end if;
end process;


top_receiver_i: entity work.top_receiver
	 port map(
		 reset =>reset_rx,
		 clk_core=>clk_core, --# must be quickly than clk_signal
		 clk_mac=>clk_mac,

		 udp_IPaddr=>udp_IPaddr,
		 port_number=>udp_port_number,
		 to_tx_module =>to_tx_module,

		 data_i=>data_i,
		 dv_i =>dv_i,

		 tp=>tp_rx
	     );




end top_top;
