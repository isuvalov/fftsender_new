library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity fifo_all is
	 port(
		 reset: in std_logic;
		 clk_core: in std_logic;
		 clk_mac: in std_logic;

		 payload_is_counter: in std_logic;

		 i_direct: in std_logic;
		 i_direct_ce: in std_logic;
		 i_data: in std_logic_vector(15 downto 0);
		 i_data_ce: in std_logic;
		 i_data_exp: in std_logic_vector(5 downto 0);
		 i_data_exp_ce: in std_logic;

		 fifo_empty: out std_logic;
		 rd_data: in std_logic;    --# by clk_mac
		 rd_exp: in std_logic;     --# by clk_mac
		 rd_direct: in std_logic;  --# by clk_mac
		 read_count: out std_logic_vector(10 downto 0);

		 o_direct: out std_logic;
		 o_data: out std_logic_vector(3 downto 0);
		 o_data_ce: out std_logic;
		 o_data_exp: out std_logic_vector(7 downto 0);
		 o_data_exp_ce: out std_logic
	     );
end fifo_all;


architecture fifo_all of fifo_all is

constant COUNTER_8BIT:integer:=1;


function fliplr(A:std_logic_vector) return std_logic_vector is
variable R:std_logic_vector(A'Range);
begin
  for i in A'Low to A'High loop
	  R(A'High-(i-A'Low)):=A(i);
  end loop; 
  return R;
end function;

component fifo16x4
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		rdusedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		wrfull		: OUT STD_LOGIC 
	);
end component;


signal i_direct_reg,directE:std_logic_vector(7 downto 0);
signal full,empty,wr,wre,full_exp,empty_exp:std_logic;
signal exponent_outE:std_logic_vector(7 downto 0);

signal data_mux,data_emul_cnt_swap,data_emul_cnt:std_logic_vector(i_data'Length-1 downto 0):=(others=>'0');
signal data_mux_ce:std_logic;


begin

wr<=data_mux_ce and not(full);
wre<=i_data_exp_ce and not(full_exp);

fifo16x4_inst : fifo16x4 PORT MAP (
		aclr	 => reset,
		data	 => data_mux,
		rdclk	 => clk_mac,
		rdreq	 => rd_data,
		wrclk	 => clk_core,
		wrreq	 => wr,
		q	 	 => o_data,
		rdempty	 => empty,
		rdusedw	 => read_count,
		wrfull	 => full
	);

fifo_empty<=empty;

exponent_outE<=EXT(i_data_exp,exponent_outE'Length);
fifo8x4_inst: entity work.aFifo
	generic map(
		DATA_WIDTH =>8,
		ADDR_WIDTH =>5
		)
	port map(
		-- Reading port.
		Data_out    =>o_data_exp,
		Empty_out   =>empty_exp,
		ReadEn_in   =>rd_exp,
		RClk        =>clk_mac,
		-- Writing port.
		Data_in     =>exponent_outE,
		Full_out    =>full_exp,
		WriteEn_in  =>wre,
		WClk        =>clk_core,
		
		Clear_in =>reset
		);


fifo8x4b_inst: entity work.aFifo
	generic map(
		DATA_WIDTH =>8,
		ADDR_WIDTH =>5
		)
	port map(
		-- Reading port.
		Data_out    =>directE,
		Empty_out   =>open,
		ReadEn_in   =>rd_direct,
		RClk        =>clk_mac,
		-- Writing port.
		Data_in     =>i_direct_reg,
		Full_out    =>open,
		WriteEn_in  =>i_direct_ce,
		WClk        =>clk_core,
		
		Clear_in =>reset
		);

i_direct_reg<=EXT("0"&i_direct,8);
o_direct<=directE(0);

data_emul_cnt_swap<=data_emul_cnt(3 downto 0)&data_emul_cnt(7 downto 4)&data_emul_cnt(11 downto 8)&data_emul_cnt(15 downto 12) when COUNTER_8BIT=0 else
    data_emul_cnt(11 downto 8)&data_emul_cnt(15 downto 12)&data_emul_cnt(3 downto 0)&data_emul_cnt(7 downto 4);
process(clk_core) is                                                                      
  begin                                                                                         
    if rising_edge(clk_core) then
		o_data_ce<=rd_data;
		o_data_exp_ce<=rd_exp;
		if payload_is_counter='1' then
			if COUNTER_8BIT=1 then
				data_mux<=data_emul_cnt_swap(7 downto 0)&data_emul_cnt_swap(7 downto 0);
			else
				data_mux<=data_emul_cnt_swap;			
			end if;
		else
			data_mux<=i_data;
		end if;
		data_mux_ce<=i_data_ce;

		if i_data_ce='1' then
           data_emul_cnt<=data_emul_cnt+1;
		end if;
	end if;
end process;



end fifo_all;

