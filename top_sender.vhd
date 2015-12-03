library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity top_sender is
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

		 pre_shift: in std_logic_vector(5 downto 0);
		 i_direction : in std_logic;

		 signal_ce : in std_logic;
		 signal_start: in std_logic;
		 signal_real: in std_logic_vector(11 downto 0);
		 signal_imag: in std_logic_vector(11 downto 0);

		 data_out: out std_logic_vector(3 downto 0);
		 dv : out std_logic;

		 to_tx_module: in Trx2tx_wires;
		 tp: out std_logic_vector(7 downto 0)
	     );
end top_sender;


architecture top_sender of top_sender is

constant CUT_LEN:integer:=1024; 	--# How many samples transfer to MAC
constant DEBUG:integer:=1;

signal fft_dataout_re: std_logic_vector(11 downto 0);
signal fft_dataout_im: std_logic_vector(11 downto 0);
signal fft_dataout_ce: std_logic;
signal fft_data_exp: std_logic_vector(5 downto 0);
signal fft_data_exp_ce_2w,fft_data_exp_ce_1w,fft_data_exp_ce: std_logic;

signal mux_data,adc_data,abs_data: std_logic_vector(15 downto 0);
signal mux_data_ce,adc_data_ce,abs_data_ce:std_logic;
signal mux_data_exp,adc_data_exp,abs_data_exp: std_logic_vector(5 downto 0);
signal mux_data_exp_ce,adc_data_exp_ce,abs_data_exp_ce: std_logic;

signal direction_1w,direction_2w,direction_3w:std_logic;
signal signal_start_1w,signal_start_2w,signal_start_3w:std_logic;

signal sig_direct,making_fft: std_logic;
signal sig_direct_ce,fifo_empty,ready: std_logic;
signal read_count: std_logic_vector(10 downto 0);

signal rd_exp,rd_data,rd_direct,direct,fifo_data_ce,fifo_data_exp_ce:std_logic;
signal fifo_data : std_logic_vector(3 downto 0);
signal fifo_data_exp : std_logic_vector(7 downto 0);
signal tp_fifo : std_logic_vector(2 downto 0);

begin


make_fft_i: entity work.make_fft
	generic map(
		CLKCORE_EQUAL_CLKSIGNAL=>CLKCORE_EQUAL_CLKSIGNAL,
		CUT_LEN=>CUT_LEN 	--# How many samples transfer to MAC
	)
	 port map(
		 reset=>reset,
		 clk_signal=>clk_signal,
		 clk_core=>clk_core, --# must be quickly than clk_signal

		 signal_ce =>signal_ce,
		 signal_start =>signal_start,
		 signal_real =>signal_real,
		 signal_imag =>signal_imag,

		 dataout_re =>fft_dataout_re,
		 dataout_im =>fft_dataout_im,
		 dataout_ce =>fft_dataout_ce,
		 data_exp =>fft_data_exp,
		 data_exp_ce =>fft_data_exp_ce
	     );


make_abs_i: entity work.make_abs
	 port map(
		 reset=>reset,
		 clk_core=>clk_core, --# must be quickly than clk_signal
		 pre_shift =>pre_shift,

		 i_data_re =>fft_dataout_re,
		 i_data_im =>fft_dataout_im,
		 i_data_ce =>fft_dataout_ce,
		 i_data_exp =>fft_data_exp,
		 i_data_exp_ce =>fft_data_exp_ce,

		 o_dataout =>abs_data,
		 o_dataout_ce =>abs_data_ce,
		 o_data_exp =>abs_data_exp,
		 o_data_exp_ce =>abs_data_exp_ce
	     );


make_adc_i: entity work.make_adc
	 port map(
		 reset=>reset,
		 clk_core=>clk_core, --# must be quickly than clk_signal
		 pre_shift=>pre_shift,

		 i_data_re =>signal_real,
		 i_data_im =>signal_imag,
		 i_data_ce =>signal_ce,
		 i_data_exp =>(others=>'0'),
		 i_data_exp_ce =>'0',

		 o_dataout =>adc_data,
		 o_dataout_ce =>adc_data_ce,
		 o_data_exp =>adc_data_exp,
		 o_data_exp_ce =>adc_data_exp_ce
	     );



process(clk_signal) is
begin
	if rising_edge(clk_signal) then
		tp<="00"&fft_data_exp_ce&fft_dataout_ce&making_fft&tp_fifo;
	end if;
end process;

process(clk_core) is
begin
	if rising_edge(clk_core) then
		direction_1w<=i_direction;
		direction_2w<=direction_1w;
		direction_3w<=direction_2w;
		signal_start_1w<=signal_start;
		signal_start_2w<=signal_start_1w;
		signal_start_3w<=signal_start_2w;

		fft_data_exp_ce_1w<=fft_data_exp_ce;
		fft_data_exp_ce_2w<=fft_data_exp_ce_1w;
		



		if signal_start_3w='0' and signal_start_2w='1' then
			sig_direct<=direction_2w;
			sig_direct_ce<='1';			
			making_fft<='1';
		else
			if fft_data_exp_ce_2w='0' and fft_data_exp_ce_1w='1' then
				making_fft<='0';
			end if;
			sig_direct_ce<='0';
		end if;
		
		if send_adc_data='1' then
			mux_data<=adc_data;
			mux_data_ce<=adc_data_ce;
			mux_data_exp<=adc_data_exp;
			mux_data_exp_ce<=adc_data_exp_ce;
		else
			mux_data<=abs_data;
			mux_data_ce<=abs_data_ce;
			mux_data_exp<=abs_data_exp;
			mux_data_exp_ce<=abs_data_exp_ce;
		end if;


	end if;
end process;




fifo_all_i: entity work.fifo_all
	generic map(
		SWAP_SIGNALBITS=>SWAP_SIGNALBITS
	)
	 port map(
		 reset =>reset,
		 clk_core =>clk_core,
		 clk_mac =>clk_mac,

		 payload_is_counter=>payload_is_counter,

		 i_direct =>sig_direct,
		 i_direct_ce =>sig_direct_ce,
		 i_data =>mux_data,
		 i_data_ce =>mux_data_ce,
		 i_data_exp =>mux_data_exp,
		 i_data_exp_ce =>mux_data_exp_ce,

		 fifo_empty =>fifo_empty,
		 rd_data =>rd_data,    --# by clk_mac
		 rd_exp =>rd_exp,     --# by clk_mac
		 rd_direct =>rd_direct,  --# by clk_mac
		 read_count =>read_count,

		 o_direct =>direct,
		 o_data =>fifo_data,
		 o_data_ce =>fifo_data_ce,
		 o_data_exp =>fifo_data_exp,
		 o_data_exp_ce =>fifo_data_exp_ce,
		
		 tp => tp_fifo
	     );


send_udp_i: entity work.send_udp
	generic map(
		CUT_LEN=>CUT_LEN,
		DEBUG=>DEBUG
	)
	 port map(
		 reset=>reset,
		 clk_mac=>clk_mac,

		 PayloadIsZERO=>PayloadIsZERO, --# if it '1' make zero all data in MAC frame

		 rd_data =>rd_data,
		 fifo_empty =>fifo_empty,
		 read_count =>read_count,

		 rd_direct =>rd_direct,
		 i_direct =>direct,

		 i_data =>fifo_data,
		 i_data_ce =>fifo_data_ce,

		 rd_exp =>rd_exp,
		 i_data_exp =>fifo_data_exp,
		 i_data_exp_ce =>fifo_data_exp_ce,
		 rx2tx =>to_tx_module,
		  
		 data_out =>data_out,
		 dv =>dv
	     );


end top_sender;
