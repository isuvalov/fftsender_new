library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity estimate_harm is	 
	 port(
		 clk : in std_logic;
		 reset : in std_logic;

		 i_ce: in std_logic;
		 i_sample_1m: in std_logic_vector(15 downto 0); --# unsigned
		 i_sample: in std_logic_vector(15 downto 0); --# unsigned
		 i_sample_1p: in std_logic_vector(15 downto 0); --# unsigned

		 o_sample: out std_logic_vector(15+FIXPOINT downto 0); --# unsigned
		 o_ce: out std_logic
	     );
end estimate_harm;


architecture estimate_harm of estimate_harm is

signal ce_1w,ce_2w,ce_3w,dived_ce,dived_ce_1w:std_logic;
signal sample_reg:std_logic_vector(i_sample'Length-1 downto 0);
signal max_delta,max_delta_unsigned,max_delta_unsigned_1w:std_logic_vector(i_sample'Length+1-1 downto 0);
signal plus_delta:std_logic_vector(i_sample'Length+1-1 downto 0);
signal dividor,dividor_unsigned:std_logic_vector(i_sample'Length+2-1 downto 0);
signal dividor_unsignedE,max_delta_unsignedE,dived:std_logic_vector(31 downto 0);

signal save_sign_md,save_sign_div,cea:std_logic_vector(31+3 downto 0);
signal s_sample:std_logic_vector(31 downto 0);

begin


process(clk) is
begin
	if rising_edge(clk) then
		ce_1w<=i_ce;
		ce_2w<=ce_1w;
		ce_3w<=ce_2w;
		if i_ce='1' then
			sample_reg<=i_sample;
			max_delta<=("0"&i_sample_1p)-("0"&i_sample_1m);
			plus_delta<=("0"&i_sample_1p)+("0"&i_sample_1m);
		end if;
		if ce_1w='1' then
			dividor<=("0"&sample_reg&"0")-("0"&plus_delta);
			if max_delta(max_delta'Length-1)='1' then
				max_delta_unsigned<=0-max_delta;
			else
				max_delta_unsigned<=max_delta;
			end if;
		end if;
		if ce_2w='1' then
			max_delta_unsigned_1w<=max_delta_unsigned;
			if dividor(dividor'Length-1)='1' then
				dividor_unsigned<=0-dividor;
			else
				dividor_unsigned<=dividor;
			end if;
		end if;

		cea<=cea(cea'Length-2 downto 0)&ce_2w;
		save_sign_md<=save_sign_md(save_sign_md'Length-2 downto 0)&max_delta(max_delta'Length-1);
		save_sign_div<=save_sign_div(save_sign_div'Length-2 downto 0)&dividor(dividor'Length-1);

	    if (save_sign_md(save_sign_md'Length-1) xor save_sign_div(save_sign_md'Length-2))='1' then
			s_sample<=0-dived;
		else
			s_sample<=dived;
		end if;

		dived_ce_1w<=dived_ce;
		o_ce<=cea(cea'Length-1);
		o_sample<=s_sample(o_sample'Length-1 downto 0);
	end if;
end process;

dividor_unsignedE<=EXT(dividor_unsigned&EXT("0",FIXPOINT),32);
max_delta_unsignedE<=EXT(max_delta_unsigned_1w&EXT("0",FIXPOINT),32); --# set Q=16.5

serial_divide_uu_i: entity work.serial_divide_uu
  generic map( M_PP => 32,           -- Size of dividend
            N_PP => 32,            -- Size of divisor
            R_PP =>0,            -- Size of remainder
            S_PP =>0,            -- Skip this many bits (known leading zeros)
--            COUNT_WIDTH_PP : integer := 5;  -- 2^COUNT_WIDTH_PP-1 >= (M_PP+R_PP-S_PP-1)
            HELD_OUTPUT_PP =>1) -- Set to 1 if stable output should be held
    port map(   clk_i =>clk,
            clk_en_i=>'1',
            rst_i  =>reset,
            divide_i   =>ce_3w,
            dividend_i =>max_delta_unsignedE,
            divisor_i  =>dividor_unsignedE,
            quotient_o =>dived,
            done_o     =>dived_ce
    );


end estimate_harm;


