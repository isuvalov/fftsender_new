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

		 pre_shift: in std_logic_vector(5 downto 0);
		 i_direction : in std_logic;

		 signal_ce : in std_logic;
		 signal_start: in std_logic;
		 signal_real: in std_logic_vector(11 downto 0);
		 signal_imag: in std_logic_vector(11 downto 0);

		 dataout_re: out std_logic_vector(11 downto 0);
		 dataout_im: out std_logic_vector(11 downto 0);
		 dataout_ce: out std_logic;
		 data_exp: out std_logic_vector(5 downto 0);
		 data_exp_ce: out std_logic
	     );
end top_sender;


architecture top_sender of top_sender is

constant CUT_LEN:integer:=1024; 	--# How many samples transfer to MAC


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
signal sig_direct_ce: std_logic;


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
		 i_data: in std_logic_vector(15 downto 0);
		 i_data_ce: in std_logic;
		 i_data_exp: in std_logic_vector(5 downto 0);
		 i_data_exp_ce: in std_logic;

		 fifo_empty: out std_logic;
		 rd_data: in std_logic;    --# by clk_mac
		 rd_exp: in std_logic;     --# by clk_mac
		 rd_direct: in std_logic;  --# by clk_mac
		 read_count: out std_logic_vector(8 downto 0);

		 o_direct: out std_logic;
		 o_data: out std_logic_vector(3 downto 0);
		 o_data_ce: out std_logic;
		 o_data_exp: out std_logic_vector(7 downto 0);
		 o_data_exp_ce: out std_logic
	     );


end top_sender;
