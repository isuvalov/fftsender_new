library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity find_max is	 
	 port(
		 reset: in std_logic;
		 clk : in std_logic;

		 i_ce: in std_logic;
		 i_sample: in std_logic_vector(15 downto 0); --# unsigned

		 maximum_m1: out std_logic_vector(15 downto 0);    --# value left of maximum
		 maximum: out std_logic_vector(15 downto 0);
		 maximum_p1: out std_logic_vector(15 downto 0);    --# value right of maximum
		 maximum_ce: out std_logic                         --# latency 2 clock from i_sample and i_ce
	     );
end find_max;


architecture find_max of find_max is

constant DIV_THR:std_logic_vector(15 downto 0):=conv_std_logic_vector(65536/3,16);  --# for divider 1/3
constant AREA_SIZE:integer:=11;

constant MUL_LATENCY:integer:=1;
constant TRACE_LEN:integer:=AREA_SIZE+MUL_LATENCY;



type Ttrace is array (TRACE_LEN-1 downto 0) of std_logic_vector(i_sample'Length-1 downto 0);
signal trace:Ttrace;

signal cnt,max_pos,make_max_pos:std_logic_vector(3 downto 0):=(others=>'0');
signal max_val,make_max_val:std_logic_vector(i_sample'Length-1 downto 0);
signal ce_max:std_logic;
signal mul_thr:std_logic_vector((2*i_sample'Length)-1 downto 0);
signal prev_maximum_exist:std_logic:='0';
signal can_calc:std_logic:='1';
signal prev_maximum_val:std_logic_vector(i_sample'Length-1 downto 0):=(others=>'0');
signal prev_maximum_exist_cnt:std_logic_vector(3 downto 0):=(others=>'1');


begin


process(clk) is
begin
	if rising_edge(clk) then

		if i_ce='1' then
			trace(0)<=i_sample;
			for i in TRACE_LEN-1 downto 1 loop
				trace(i)<=trace(i-1);
			end loop;
		end if; --# ce

		if  i_ce='1' then
			--# We try to think that trace(5) is maximum
			--# Test it by thresholds it!
			mul_thr<=unsigned(trace(5))*unsigned(DIV_THR);
			if prev_maximum_exist='1' then
				if (unsigned(trace(5))<unsigned(prev_maximum_val)) then
					can_calc<='0';
				else
					can_calc<='1';
				end if;
			else
				can_calc<='1';
			end if;
			if not(unsigned(trace(5-1+MUL_LATENCY))>unsigned(mul_thr(mul_thr'Length-1 downto mul_thr'Length-i_sample'Length)) or unsigned(trace(5+1+MUL_LATENCY))>unsigned(mul_thr)) and can_calc='1' and
				unsigned(trace(5+MUL_LATENCY))>1 then
				maximum_ce<='1';
				maximum<=trace(5+MUL_LATENCY);
				maximum_m1<=trace(5-1+MUL_LATENCY);
				maximum_p1<=trace(5+1+MUL_LATENCY);
				prev_maximum_exist_cnt<=(others=>'0');
				prev_maximum_val<=trace(5+MUL_LATENCY);
				prev_maximum_exist<='1';
			else
				if unsigned(prev_maximum_exist_cnt)<AREA_SIZE/2-1 then
					prev_maximum_exist_cnt<=prev_maximum_exist_cnt+1;
					prev_maximum_exist<='1';
				else
					prev_maximum_exist<='0';
				end if;
				maximum_ce<='0';	
			end if;
		else
			maximum_ce<='0';	
		end if;


	end if;
end process;

end find_max;
