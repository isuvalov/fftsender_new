library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity top_sender is
	 port(
		 reset: in std_logic;
		 clk_signal: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal
		 clk_mac: in std_logic;

		 PayloadIsZERO: in std_logic;
		 pre_shift: in std_logic_vector(5 downto 0);
		 i_direction : in std_logic;

		 signal_ce : in std_logic;
		 signal_start: in std_logic;
		 signal_real: in std_logic_vector(11 downto 0);
		 signal_imag: in std_logic_vector(11 downto 0);

		 data_out: out std_logic_vector(3 downto 0);
		 dv : out std_logic
	     );
end top_sender;


architecture top_sender of top_sender is

constant CUT_LEN:integer:=1024; 	--# How many samples transfer to MAC
constant DEBUG:integer:=1;

signal fft_dataout_re: std_logic_vector(11 downto 0);
signal fft_dataout_im: std_logic_vector(11 downto 0);
signal fft_dataout_ce: std_logic;
signal fft_data_exp: std_logic_vector(5 downto 0);
signal fft_data_exp_ce: std_logic;

signal abs_data: std_logic_vector(15 downto 0);
signal abs_data_ce:std_logic;
signal abs_data_exp: std_logic_vector(5 downto 0);
signal abs_data_exp_ce: std_logic;

signal direction_1w,direction_2w,direction_3w:std_logic;
signal signal_start_1w,signal_start_2w,signal_start_3w:std_logic;

signal sig_direct: std_logic;
signal sig_direct_ce,fifo_empty: std_logic;
signal read_count: std_logic_vector(10 downto 0);

signal rd_exp,rd_data,rd_direct,direct,fifo_data_ce,fifo_data_exp_ce:std_logic;
signal fifo_data : std_logic_vector(3 downto 0);
signal fifo_data_exp : std_logic_vector(7 downto 0);


begin


make_fft_i: entity work.make_fft
	generic map(
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

process(clk_core) is
begin
	if rising_edge(clk_core) then
		direction_1w<=i_direction;
		direction_2w<=direction_1w;
		direction_3w<=direction_2w;
		signal_start_1w<=signal_start;
		signal_start_2w<=signal_start_1w;
		signal_start_3w<=signal_start_2w;
		if signal_start_3w='0' and signal_start_2w='1' then
			sig_direct<=direction_2w;
			sig_direct_ce<='1';
		else
			sig_direct_ce<='0';
		end if;
	end if;
end process;




fifo_all_i: entity work.fifo_all
	 port map(
		 reset =>reset,
		 clk_core =>clk_core,
		 clk_mac =>clk_mac,

		 i_direct =>sig_direct,
		 i_direct_ce =>sig_direct_ce,
		 i_data =>abs_data,
		 i_data_ce =>abs_data_ce,
		 i_data_exp =>abs_data_exp,
		 i_data_exp_ce =>abs_data_exp_ce,

		 fifo_empty =>fifo_empty,
		 rd_data =>rd_data,    --# by clk_mac
		 rd_exp =>rd_exp,     --# by clk_mac
		 rd_direct =>rd_direct,  --# by clk_mac
		 read_count =>read_count,

		 o_direct =>direct,
		 o_data =>fifo_data,
		 o_data_ce =>fifo_data_ce,
		 o_data_exp =>fifo_data_exp,
		 o_data_exp_ce =>fifo_data_exp_ce
	     );


send_udp_i: entity work.send_udp
	generic map(
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

		 data_out =>data_out,
		 dv =>dv
	     );


end top_sender;
