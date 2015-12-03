library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity agregate_sweeps is	 
	generic (
		MEMLEN:integer:=1024;
		LOG2MEMLEN:integer:=10
	 );
	 port(
		 reset: in std_logic;
		 clk_core : in std_logic;
		 clk_mac : in std_logic;

		 i_can_agreagate_new_sweeps: in std_logic;

		 i_signal_start: in std_logic;
		 i_sweep_direction: in std_logic; --# get it to register by i_signal_start

	     i_abs_data_exp: in std_logic_vector(5 downto 0);
		 i_abs_data_exp: in std_logic;
		 i_abs_data: in std_logic_vector(15 downto 0);
		 i_abs_data_ce: in std_logic;

		 i_send_adc_data: in std_logic; --# use it abs_data or adc_data
		 i_adc_data: in std_logic_vector(15 downto 0);


		 o_data_exp_swp_p: out std_logic_vector(5 downto 0);
		 o_data_exp_swp_m: out std_logic_vector(5 downto 0);
		 i_rd_ptr_p: in std_logic_vector(LOG2MEMLEN-1 downto 0);
		 o_data_p: out std_logic_vector(15 downto 0);
		 i_rd_ptr_m: in std_logic_vector(LOG2MEMLEN-1 downto 0);
		 o_data_m: out std_logic_vector(15 downto 0);

	     );
end agregate_sweeps;


architecture agregate_sweeps of agregate_sweeps is

signal mux_data:std_logic_vector(15 downto 0);
signal mux_data_ce,mux_data_exp_ce:std_logic;
signal mux_data_exp:std_logic_vector(5 downto 0);

signal sig_direct_ce,sig_direct,sweep_direction_1w,sweep_direction_2w:std_logic;
signal signal_start_1w,signal_start_2w,signal_start_3w:std_logic;

signal data_exp_swp_p,data_exp_swp_m,data_exp_swp_p_by,data_exp_swp_m_by:std_logic_vector(5 downto 0);

signal wr_ptr_p,wr_ptr_m:std_logic_vector(LOG2MEMLEN-1 downto 0);
type mem is array(MEMLEN-1 downto 0) of std_logic_vector(15 downto 0);

signal mem_p:mem;
signal mem_m:mem;

signal mem_wr_p,mem_wr_m:std_logic;
signal mem_data_p,mem_data_m:std_logic_vector(15 downto 0);

signal exp_ce,exp_ce_by,exp_ce_by_1w,exp_ce_by_2w:std_logic;
signal exp_ce_cnt:std_logic_vector(3 downto 0):=(others=>'0');
begin

process(clk_core) is
begin
	if rising_edge(clk_core) then
		if i_send_adc_data='1' then
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


		signal_start_1w<=i_signal_start;
		signal_start_2w<=signal_start_1w;
		signal_start_3w<=signal_start_2w;

		sweep_direction_1w<=i_sweep_direction;
		sweep_direction_2w<=sweep_direction_1w;

		if signal_start_3w='0' and signal_start_2w='1' then
			sig_direct<=sweep_direction_2w;
			sig_direct_ce<='1';
			wr_ptr_p<=(others=>'0');
			wr_ptr_m<=(others=>'0');
		else
			sig_direct_ce<='0';

			if mem_wr_p='1' then
				wr_ptr_p<=wr_ptr_p+1;
			end if;
			if mem_wr_m='1' then
				wr_ptr_m<=wr_ptr_m+1;
			end if;
		end if;
		
		if mux_data_exp_ce='1' then
			if sig_direct='0' then
				data_exp_swp_p<=mux_data_exp;
			else
				data_exp_swp_m<=mux_data_exp;
			end if;
			exp_ce_cnt<=(others=>'1');
			exp_ce<='1';
		else
			if unsigned(exp_ce_cnt)>0 then
				exp_ce_cnt<=exp_ce_cnt-1;
				exp_ce<='1';
			else
				exp_ce<='0';
			end if;
		end if; --# i_abs_data_exp

		mem_data_p<=mux_data;
		mem_data_m<=mux_data;
		if sig_direct='0' then			
			mem_wr_p<=mux_data_ce;
			mem_wr_m<='0';
		else
			mem_wr_p<='0';
			mem_wr_m<=mux_data_ce;
		end if;

		
	end if;
end process;


process(clk_core) is
begin
	if rising_edge(clk_core) then
		if mem_wr_p='1' then
			mem_p(conv_integer(wr_ptr_p))<=mem_data_p;	
		end if;
		if mem_wr_m='1' then
			mem_p(conv_integer(wr_ptr_m))<=mem_data_m;	
		end if;
	end if;
end process;

process(clk_mac) is
begin
	if rising_edge(clk_mac) then
		exp_ce_by<=exp_ce;
		exp_ce_by_1w<=exp_ce_by;
		exp_ce_by_2w<=exp_ce_by_1w;
		if exp_ce_by_1w='1' and exp_ce_by_2w='0' then
			data_exp_swp_p_by<=data_exp_swp_p;
			data_exp_swp_m_by<=data_exp_swp_m;
		end if;
		o_data_exp_swp_p<=data_exp_swp_p_by;
		o_data_exp_swp_m<=data_exp_swp_m_by;

        o_data_p<=mem_p(conv_integer(i_rd_ptr_p));
        o_data_m<=mem_m(conv_integer(i_rd_ptr_m));
		
	end if;
end process;

end agregate_sweeps;
