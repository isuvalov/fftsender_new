---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
--  version		: $Version:	1.0 $ 
--  revision		: $Revision: 1.1.1.1 $ 
--  designer name  	: $Author: jzhang $ 
--  company name   	: altera corp.
--  company address	: 101 innovation drive
--                  	  san jose, california 95134
--                  	  u.s.a.
-- 
--  copyright altera corp. 2003
-- 
-- 
--  $Header: /ipbu/cvs/dsp/projects/FFT/src/rtl/lib/asj_fft_tdl_bit.vhd,v 1.1.1.1 2005/12/08 01:14:15 jzhang Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

library ieee;                              
use ieee.std_logic_1164.all;               
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;
library work;
use work.fft_pack.all;
-- TDL For single-bit delay register chains

entity asj_fft_tdl_bit is 
generic( 
				 del    : integer :=6
				);
port( 	clk 			: in std_logic;
				--reset   	: in std_logic;
		 		data_in 	: in std_logic;
		 		data_out 	: out std_logic
		);

end asj_fft_tdl_bit;


architecture syn of asj_fft_tdl_bit is 

	 
signal tdl_arr : std_logic_vector(del-1 downto 0);



begin

	gen_no_del : if(del=0) generate
		data_out <= data_in;
	end generate gen_no_del;
	
	gen_del : if(del>0) generate
	
	data_out <= tdl_arr(del-1);
	
	tdl : process(clk,data_in,tdl_arr) is
		begin
			if(rising_edge(clk)) then
				for i in del-1 downto 1 loop
					tdl_arr(i)<=tdl_arr(i-1);
				end loop;
				tdl_arr(0) <= data_in;
				end if;
		end process tdl;
	
	end generate gen_del;
	
  
end syn;
