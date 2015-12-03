LIBRARY ieee;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
--library std;
--use std.textio.all;

entity tb is
generic (
	NOT_PLI:integer:=0
);
end tb;


architecture tb of tb is

-- clkq = 31/25*clk125 

constant CLK_PERIOD_clk125: TIME := 40 ns; 
constant CLK_PERIOD_clkq: TIME := 6.45161290322580645 ns; --# < 1/(125e6*(9/8)*(204/186))

constant CLK_PERIOD_clks: TIME := 1000.0 ns;

constant FRAME_LEN:natural:=204;
constant CE_LEN:natural:=188;


constant SHFT:integer:=8;
component mult31_25
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
end component;


signal clkq,clk125,clk125_div2,clk125_div4,clk125_n,clk_signal_p:std_logic:='0';
signal reset:std_logic:='1'; 
signal cnt_rd:std_logic_vector(64 downto 0):=(others=>'0');
signal cnt_wr:std_logic_vector(64 downto 0):=(others=>'0');

-- for data_generator
signal Tx_mac_wa,Tx_mac_wr:std_logic;
signal Tx_mac_data:std_logic_vector(31 downto 0);
signal Tx_mac_BE:std_logic_vector(1 downto 0);
signal Tx_mac_eop,Tx_mac_sop:std_logic;
signal Tx_mac_wa_n:std_logic;

--# loop back
signal Tx_en,Tx_er,Rx_clk,Gtx_clk,Tx_clk:std_logic;
signal Rx_er,Rx_dv:std_logic;
signal Txd,Rxd:std_logic_vector(7 downto 0):=(others=>'0');

--# rx engine
signal Rx_mac_ra_tb,Rx_mac_rd_tb:std_logic;
signal Rx_mac_eop_tb,Rx_mac_pa_tb,Rx_mac_sop_tb,Tx_mac_wr_n_tb: std_logic;
signal Rx_mac_data_tb : std_logic_vector(31 downto 0);
signal Rx_mac_BE_tb : std_logic_vector(1 downto 0);


signal data_fromfile,data_fromfile_w1,data_fromfile_w2:std_logic_vector(7 downto 0);
signal ce_fromfile_F,ce_fromfile,ce_fromfile_w1,ce_fromfile_w2:std_logic;

signal tx_coded_data,tx_coded_data_rs:std_logic_vector(7 downto 0);
signal tx_coded_ce,reset_delay:std_logic;
signal cccnt,cccnt_t:std_logic_vector(13 downto 0):=(others=>'0');

signal dataout_end:std_logic_vector(7 downto 0);
signal ceout_end:std_logic;

signal err,Tx_er_end,Tx_en_end:std_logic;
signal Txd_end_w1,Txd_end:std_logic_vector(7 downto 0);

signal reset0,locked_sig,ack_out_bus,empty2_bus:std_logic;
signal time_cnt:std_logic_vector(31 downto 0):=(others=>'0');


signal makerr,rd89,empty89,state_value,ce89,ce89_w1,ce98,ce98_w1,empty98:std_logic;
signal data89,data98,DataOutB_2,DataOutB:std_logic_vector(8 downto 0):=(others=>'0');
signal data8:std_logic_vector(7 downto 0):=(others=>'0');
signal towork2,towork:std_logic_vector(11 downto 0):=(others=>'0');

signal clk_signal,signal_ce:std_logic:='0';

signal byted,byted_w1,byted2:std_logic_vector(7 downto 0);
signal short,short2:std_logic_vector(15 downto 0);
signal dv_cnt_short:std_logic:='0';

signal half_b:std_logic_vector(3 downto 0);
signal dv,dv_1w:std_logic;
signal dv_cnt:std_logic:='0';
signal dv_cnt_not,dv_cnt_parse,dv_cnt2:std_logic;
signal sweep_ce,sweep_ce_w1:std_logic;

signal data_to_algorithm:  std_logic_vector(15 downto 0);
signal ce_to_algorithm:  std_logic;
signal finish_to_algorithm:  std_logic;

signal data_from_algorithm:  std_logic_vector(15 downto 0);
signal ce_from_algorithm,signal_direct:  std_logic:='0';
signal finish_from_algorithm:  std_logic;

signal byte1,byte2:std_logic_vector(7 downto 0);

signal datafromcpu,datatocpu:std_logic_vector(15 downto 0);
signal cpu_wr,cpu_rd,dv_send8_cpu:std_logic;


signal cnt_udp_frame,cnt_udp_frame_reg,alg_cnt:integer:=0;

signal signal_start,cpu_rd_1w,cpu_rd_parse:std_logic;

type Tmem is array(0 to 7) of integer;
constant mem:Tmem:=(-1000,-1000,0,1000,1000,50,50,50);

signal localc,allalg:integer:=0;
signal data_send8_rtl,data_send8,data_send8_cpu:std_logic_vector(7 downto 0);
signal data_send4:std_logic_vector(3 downto 0);
signal ce_send8_rtl,dv_send8,dv_send4,send_ask_radar_status,mac_clk_div2:std_logic:='0';


begin

reset<='0' after 600 ns;



CLK_GEN125: process(clk125)
begin
	clk125<= not clk125 after CLK_PERIOD_clk125/2; 
end process;

c125div2: process(clk125)
begin
 if rising_edge(clk125) then
  clk125_div2<=not clk125_div2;
 end if;
end process;

c125div4: process(clk125_div2)
begin
 if rising_edge(clk125_div2) then
  clk125_div4<=not clk125_div4;
 end if;
end process;



sigclk: process(clk_signal_p)
begin
	clk_signal_p<= not clk_signal_p after CLK_PERIOD_clks/2; 
end process;

clk_signal<=clk_signal_p after CLK_PERIOD_clk125/3;


data_from_algorithm<=byte1(3 downto 0)&byte1(3 downto 0)&byte1(3 downto 0)&byte1(3 downto 0);
--data_from_algorithm<=x"4444";
--data_from_algorithm<=x"00FF" when localc=9 else x"0000";

process (clk_signal) is
begin
 if rising_edge(clk_signal) then
	cccnt<=cccnt+1;
	signal_ce<=cccnt(3);
	if unsigned(cccnt)<4096+100 and unsigned(cccnt)>=100 then
	   sweep_ce<='1';
	   cccnt_t<=cccnt_t+1;
	else
	   cccnt_t<=(others=>'0');
	   sweep_ce<='0';
	end if;
	if cccnt=80 then
		signal_direct<=not signal_direct;
		signal_start<='1';
	else
		signal_start<='0';
	end if;
	sweep_ce_w1<=sweep_ce;



	case conv_integer(cccnt) is
	when 30=>
		send_ask_radar_status<='1';
	when others=>
		send_ask_radar_status<='0';
	end case;

--	data_from_algorithm<=data_to_algorithm;
	ce_from_algorithm<=ce_to_algorithm;
	finish_from_algorithm<=finish_to_algorithm;


	if ce_to_algorithm='0' then
--		data_from_algorithm<=x"0000";
		byte1<=x"00";
		alg_cnt<=0;
		localc<=0;
	else
		if localc<128-1 then
			localc<=localc+1;
		else
			localc<=0;
		end if;

		alg_cnt<=alg_cnt+1;
--		if unsigned(byte1)<128-1 then
		if unsigned(byte1)<16-1 then
			byte1(3 downto 0)<=byte1(3 downto 0)+1;
		else
			byte1(3 downto 0)<=x"0";
		end if;
--		data_from_algorithm<=data_from_algorithm+x"0101";
	end if;


 end if;
end process;


--NOT_PLI_i: if NOT_PLI=0 generate
--	cpu_i: entity work.cpu_wrapper
--    	port map(clk =>clk125,
--		  reset =>reset,
--		  oaddr=>open,
--		  odata =>datafromcpu,
--		  wr =>cpu_wr,
--		  rd =>cpu_rd,
--		  idata =>datatocpu
--		);
--end generate;


datatocpu<="0000000"&dv_send8_cpu&data_send8_cpu;


--client_stimulus_cpu_i: entity work.client_stimulus_cpu
--	generic map(
--		CUT_FRAMES=>42
--	)
--	 port map(
--		 reset=>reset,
--		 ce => cpu_rd_parse,
--		 clk =>clk125,
--		 send_ask_radar_status=>send_ask_radar_status,
--		 send_ask_data=>'0',
--  
--		 dv_o=>dv_send8_cpu,
--		 data_o=>data_send8_cpu
--	     );


client_stimulus_i: entity work.client_stimulus_cpu
	generic map(
		CUT_FRAMES=>0
	)
	 port map(
		 reset=>reset,
		 ce => mac_clk_div2,
		 clk =>clk125,
		 send_ask_radar_status=>send_ask_radar_status,
		 send_ask_data=>'0',

		 dv_o=>ce_send8_rtl,   --# Надо подконектить к top_top через конвертор 8в4
		 data_o=>data_send8_rtl  --# Надо подконектить к top_top через конвертор 8в4
	     );


top_top_i: entity work.top_top
	generic map(
		SWAP_SIGNALBITS=>1,
		CLKCORE_EQUAL_CLKSIGNAL=>0
	)
	 port map(
		 reset=>reset,
		 clk_signal =>clk_signal,
		 clk_core =>clk125,
		 clk_mac =>clk125,
			
		 payload_is_counter=>'0',
		 PayloadIsZERO =>'0',
		 send_adc_data =>'0',

		 udp_IPaddr=>x"00000000",  --# UDP IP addr
		 udp_port_number=>conv_std_logic_vector(58062,16),  --# UDP port number

		 pre_shift =>"000000",
		 i_direction =>signal_direct,

		 signal_ce =>sweep_ce_w1,
		 signal_start =>signal_start,
		 signal_real =>towork2,
		 signal_imag =>(others=>'0'),

		 data_out=>half_b,
		 dv =>dv,

		 data_i =>data_send4,
		 dv_i =>dv_send4,

		 tp_tx=>open,
		 tp_rx=>open
	     );



macbits_conv8to4_i: entity work.macbits_conv8to4
	generic map(
		MSB=>1
		)
	 port map(
		 clk=>clk125,

		 data_i=>data_send8_rtl,
		 ce_i =>mac_clk_div2,
		 dv_i =>ce_send8_rtl,

		 data_o =>data_send4,
		 dv_o =>dv_send4
	     );



--towork2<=SXT(towork(towork'Length-1 downto 7),towork2'Length);
towork2<=SXT(towork(towork'Length-1 downto 0),towork2'Length);
--# (525,809) 54=-10  = div 4
--# (525,810) 53=-11  = div 2
--# (525,810) 52=-12  = div 1

FromTextFile_inst: entity work.FromTextFile
	generic map(BitLen =>towork'Length,
			IsSigned=>0, -- you can choose signed or unsigned value you have in text file
			NameOfFile=>"signal.txt")
	 port map(
		 clk =>clk_signal,
		 CE =>sweep_ce,--cccnt(8),--sweep_ce,
		 DataFromFile =>towork
	     );



ethernet2hexfile_i: entity work.ethernet2hexfile
	generic map(
			SWAP_4BITS=>1,			
			NameOfFile=>"frames.txt")
	 port map(
		 clk =>clk125,
		 dv =>dv,
		 DataToSave =>half_b
	     );

cpu_rd_parse<='1' when cpu_rd='1' and cpu_rd_1w='0' else '0';

process (clk125) is
begin
 if rising_edge(clk125) then


    cpu_rd_1w<=cpu_rd;
	byted_w1<=byted;
	if dv_cnt='1' then
		byted2<=byted_w1;
		if dv_cnt_short='0' then
			short2<=short;
			short(7 downto 0)<=byted_w1;
		else
			short(15 downto 8)<=byted_w1;
		end if;
		dv_cnt_short<=not dv_cnt_short;
	end if;
	if dv='1' then
		dv_cnt<=not dv_cnt;
		if dv_cnt='0' then
			byted(3 downto 0)<=half_b;
		else
			byted(7 downto 4)<=half_b;
		end if;
	else
		dv_cnt<='0';
	end if;

	if dv='0' then
		cnt_udp_frame<=0;
	else
		cnt_udp_frame<=cnt_udp_frame+1;
	end if;
    dv_cnt2<=not dv_cnt;

	dv_1w<=dv;
	if dv='0' and dv_1w='1' then
		cnt_udp_frame_reg<=cnt_udp_frame;
	end if;

	mac_clk_div2<=not mac_clk_div2;

 end if;
end process;
dv_cnt_not<=not dv_cnt;

--dv_cnt_parse<=dv_cnt2 when cnt_udp_frame>(8+42+1)*2 and cnt_udp_frame<((256+42+8+2+4-4)*2) else '0';
dv_cnt_parse<=dv when cnt_udp_frame>=(42+8+2)*2 and cnt_udp_frame<(256+42+8+2)*2 else '0';
--# (8+42+2)*2+256*2+2*4

end tb;
