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

		 to_tx_module: in Trx2tx_wires;
		 tp: out std_logic_vector(7 downto 0)
	     );
end top_sender;


architecture top_sender of top_sender is

constant CUT_LEN:integer:=1024; 	--# How many samples transfer to MAC
constant DEBUG:integer:=1;

FUNCTION log2roundup (data_value : integer)
		RETURN integer IS
		
		VARIABLE width       : integer := 0;
		VARIABLE cnt         : integer := 1;
		CONSTANT lower_limit : integer := 1;
		CONSTANT upper_limit : integer := 8;
		
	BEGIN
		IF (data_value <= 1) THEN
			width   := 0;
		ELSE
			WHILE (cnt < data_value) LOOP
				width := width + 1;
				cnt   := cnt *2;
			END LOOP;
		END IF;
		
		RETURN width;
	END log2roundup;


constant MAX_TARGET_NUM:integer:=32;
type Ttargets is array(MAX_TARGET_NUM-1 downto 0) of std_logic_vector(15 downto 0);
signal one_targets_m1,one_targets_p1,one_targets,one_targets_harm:Ttargets;
signal zero_targets_m1,zero_targets_p1,zero_targets,zero_targets_harm:Ttargets;

signal one_rd_ptr,zero_rd_ptr:std_logic_vector(9 downto 0);

signal targets_cnt:std_logic_vector(log2roundup(MAX_TARGET_NUM)-1 downto 0);
signal harm_cnt:std_logic_vector(15 downto 0);

signal sample16l_ce_1w,sample16l_ce_2w:std_logic;

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

signal rls_dv:std_logic;
signal rls_data_out:std_logic_vector(3 downto 0);

signal rls_mux,rls_finish,data_req_event:std_logic;
signal protocol_data_out:std_logic_vector(3 downto 0);
signal protocol_dv:std_logic;

signal sample16l: std_logic_vector(15 downto 0);
signal sample16l_ce:std_logic;

signal maximum_m1: std_logic_vector(15 downto 0);    --# value left of maximum
signal maximum: std_logic_vector(15 downto 0);
signal maximum_p1: std_logic_vector(15 downto 0);    --# value right of maximum
signal maximum_ce: std_logic;                         --# latency 2 clock from i_sample and i_ce

signal find_equal_harms_1p_1w,find_equal_harms_1p,find_equal_harms:std_logic:='0';
type Tfstm is (STARTING_PASS,NEXT_PASS,STOPING);
signal fstm:Tfstm;


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

conv2_16bit_i: entity work.conv2_16bit	 
	 port map(
		 clk =>clk_core,

		 i_ce =>abs_data_ce,
		 i_sample =>abs_data, --# unsigned
		 i_exp =>abs_data_exp,
		 i_exp_ce =>abs_data_exp_ce,

		 o_sample =>sample16l, --# unsigned
		 o_ce =>sample16l_ce
	     );



find_max_i: entity work.find_max
	 port map(
		 reset=>reset,
		 clk =>clk_core,
  
		 i_ce =>sample16l_ce,
		 i_sample =>sample16l, --# unsigned

		 maximum_m1=>maximum_m1,    --# value left of maximum
		 maximum=>maximum,
		 maximum_p1=>maximum_p1,    --# value right of maximum
		 maximum_ce=>maximum_ce                         --# latency 2 clock from i_sample and i_ce
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



process(clk_core) is
begin
	if rising_edge(clk_core) then
		sample16l_ce_1w<=sample16l_ce;
		sample16l_ce_2w<=sample16l_ce_1w;
		if abs_data_exp_ce='1' then
			targets_cnt<=(others=>'0');
			harm_cnt<=(others=>'0');
		else --# adc_data_exp_ce
			if sample16l_ce_2w='1' then
				harm_cnt<=harm_cnt+1;
			end if;

			if maximum_ce='1' then
				targets_cnt<=targets_cnt+1;
			end if;

			if maximum_ce='1' and sig_direct='1' then
				one_targets_m1(conv_integer(targets_cnt))<=maximum_m1; --# I must save only one value!!! after SweepRadar::estimate_harm
				one_targets(conv_integer(targets_cnt))<=maximum;
				one_targets_p1(conv_integer(targets_cnt))<=maximum_p1;
				one_targets_harm(conv_integer(targets_cnt))<=harm_cnt-6;				
			end if; --# maximum_ce

			if maximum_ce='1' and sig_direct='0' then
				zero_targets_m1(conv_integer(targets_cnt))<=maximum_m1;
				zero_targets(conv_integer(targets_cnt))<=maximum;
				zero_targets_p1(conv_integer(targets_cnt))<=maximum_p1;
				zero_targets_harm(conv_integer(targets_cnt))<=harm_cnt-6;
			end if; --# maximum_ce
		end if; --# adc_data_exp_ce

		if harm_cnt=1023 then
			find_equal_harms_1p<='1';
		else
			find_equal_harms_1p<='0';
		end if;
		find_equal_harms_1p_1w<=find_equal_harms_1p;
		if find_equal_harms_1p_1w='1' and find_equal_harms_1p='0' then
			find_equal_harms<='1';
		else
			find_equal_harms<='0';
		end if;

	end if;
end process;


process(clk_core) is
begin
	if rising_edge(clk_core) then
	end if;
end process;


process(clk_core) is
begin
	if rising_edge(clk_core) then
		if find_equal_harms='1' then
			fstm<=STARTING_PASS;
			one_rd_ptr<=(others=>'0');
			zero_rd_ptr<=(others=>'0');
		else
			case fstm is
			when STARTING_PASS=>
				
			when NEXT_PASS=>
			when STOPING=>
			end case;
		end if;
	end if;
end process;



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

		 sequense_finish=>rls_finish,
		 data_out =>rls_data_out,
		 dv =>rls_dv
	     );


send_protocol_udp_i: entity work.send_protocol_udp
	 port map(
		 reset=>reset,
		 clk_mac=>clk_mac,
		 
		 radar_status=>x"00", --# send by request N_0
		 temperature1=>x"00",
		 temperature2=>x"00",
		 temperature3=>x"00",
		 power1=>x"00",
		 power2=>x"00",
		 power3=>x"00",

		 voltage1=>x"00",
		 voltage2=>x"00",
		 voltage3=>x"00",
		 voltage4=>x"00",

		 to_tx_module=>to_tx_module,

		 data_out=>protocol_data_out,
		 dv =>protocol_dv
	     );

data_out<=protocol_data_out;
dv<=protocol_dv;

process(clk_mac) is
begin
	if rising_edge(clk_mac) then
		if to_tx_module.new_request_received='1' then
			case to_tx_module.request_type is
			when x"01" =>
				data_req_event<='1';
			when others =>
				data_req_event<='0';
			end case;
		else
			data_req_event<='0';
		end if;


		if data_req_event='1' then
			rls_mux<='1';
		else
			if rls_finish='1' then
				rls_mux<='0';
			end if;
		end if;

	end if;
end process;




end top_sender;
