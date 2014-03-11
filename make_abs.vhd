library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity make_abs is
	 port(
		 reset: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal
		 pre_shift: in std_logic_vector(5 downto 0);

		 i_data_re: in std_logic_vector(11 downto 0);
		 i_data_im: in std_logic_vector(11 downto 0);
		 i_data_ce: in std_logic;
		 i_data_exp: in std_logic_vector(5 downto 0);
		 i_data_exp_ce: in std_logic;

		 o_dataout: out std_logic_vector(15 downto 0);
		 o_dataout_ce: out std_logic;
		 o_data_exp: out std_logic_vector(5 downto 0);
		 o_data_exp_ce: out std_logic
	     );
end make_abs;


architecture make_abs of make_abs is

constant SQRT_LATENCY:natural:=16+2; --# +2 becouse  _w1 and _w2

signal SQ_dataout_re,SQ_dataout_im:std_logic_vector(i_data_re'Length*2-1 downto 0);
signal tosqrt:std_logic_vector(31 downto 0);
signal fft_plus_shift,fft_plus:std_logic_vector(i_data_re'Length*2 downto 0);
signal dataout_ce_1w,dataout_ce_2w:std_logic;

signal s_dataout:std_logic_vector(15 downto 0);

signal exp_ce_W,data_ce_W:std_logic_vector(SQRT_LATENCY-1 downto 0);
type Texp_data_W is array(SQRT_LATENCY-1 downto 0) of std_logic_vector(o_data_exp'Length-1 downto 0);
signal exp_data_W:Texp_data_W;


begin

process(clk_core) is                                                                      
  begin                                                                                         
    if rising_edge(clk_core) then                                                                   

		exp_ce_W<=exp_ce_W(exp_ce_W'Length-2 downto 0)&i_data_exp_ce;
		data_ce_W<=data_ce_W(data_ce_W'Length-2 downto 0)&i_data_ce;
		exp_data_W(0)<=i_data_exp;
		for i in 0 to SQRT_LATENCY-2 loop
			exp_data_W(i+1)<=exp_data_W(i);
		end loop;
		

		SQ_dataout_re<=signed(i_data_re)*signed(i_data_re); --# w1
		SQ_dataout_im<=signed(i_data_im)*signed(i_data_im);
		fft_plus<=EXT(SQ_dataout_re,fft_plus'Length)+EXT(SQ_dataout_im,fft_plus'Length); --# w2

		dataout_ce_1w<=i_data_ce;
		dataout_ce_2w<=dataout_ce_1w;



		case conv_integer(pre_shift) is
		when 0 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-1 downto 0);
		when 1 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-2 downto 0)&"0";
		when 2 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-3 downto 0)&"00";
		when 3 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-4 downto 0)&"000";
		when 4 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-5 downto 0)&"0000";
		when 5 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-6 downto 0)&"00000";
		when 6 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-7 downto 0)&"000000";
		when 7 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-8 downto 0)&"0000000";
		when 8 =>
			fft_plus_shift<=fft_plus(fft_plus'Length-9 downto 0)&"00000000";
		when 9 =>
		   fft_plus_shift<=fft_plus(fft_plus'Length-10 downto 0)&"000000000";
		when 10 =>
		   fft_plus_shift<=fft_plus(fft_plus'Length-11 downto 0)&"0000000000";
		when 11 =>
		   fft_plus_shift<=fft_plus(fft_plus'Length-12 downto 0)&"00000000000";
		when others=>
			fft_plus_shift<=fft_plus(fft_plus'Length-1 downto 0);
		end case;


		o_dataout<=s_dataout;
	end if;
end process;

tosqrt<=EXT(fft_plus_shift,32);

sqrt32to16_inst: entity work.sqrt32to16  --# w3
port map(
	clk =>clk_core,
	ce=>dataout_ce_2w,
	A =>tosqrt,  -- A: Radicand 
    Q =>s_dataout    -- Q: Root 
);	

o_dataout_ce<=data_ce_W(SQRT_LATENCY-1);
o_data_exp_ce<=exp_ce_W(SQRT_LATENCY-1);
o_data_exp<=exp_data_W(SQRT_LATENCY-1);

end make_abs;

