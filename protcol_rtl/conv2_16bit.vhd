library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;
library work;
use work.regs_pack.all;

entity conv2_16bit is	 
	 port(
		 clk : in std_logic;

		 i_ce: in std_logic;
		 i_sample: in std_logic_vector(15 downto 0); --# unsigned
		 i_exp: in std_logic_vector(5 downto 0); 
		 i_exp_ce: in std_logic; 

		 o_sample: out std_logic_vector(15 downto 0); --# unsigned
		 o_ce: out std_logic
	     );
end conv2_16bit;


architecture conv2_16bit of conv2_16bit is

signal sampleE:std_logic_vector(i_sample'Length-1+12 downto 0);
signal sample_1w:std_logic_vector(i_sample'Length-1 downto 0);
signal ce_1w:std_logic;
signal exp_reg: std_logic_vector(5 downto 0); 

begin


sampleE<=EXT(sample_1w&"00000",sampleE'Length);
process(clk) is
begin
	if rising_edge(clk) then
--		if (i_exp-(243-5))
		ce_1w<=i_ce;
		sample_1w<=i_sample;

		if i_exp_ce='1' then
			exp_reg<=unsigned(i_exp)-51;
		end if;


		if ce_1w='1' then
			case conv_integer(unsigned(exp_reg)) is 
				when 0=>  o_sample<=sampleE(15+0 downto 0+0);
				when 1=>  o_sample<=sampleE(15+1 downto 0+1);
				when 2=>  o_sample<=sampleE(15+2 downto 0+2);
				when 3=>  o_sample<=sampleE(15+3 downto 0+3);
				when 4=>  o_sample<=sampleE(15+4 downto 0+4);
				when 5=>  o_sample<=sampleE(15+5 downto 0+5);
				when 6=>  o_sample<=sampleE(15+6 downto 0+6);
    
				when 7=>  o_sample<=sampleE(15+7 downto 0+7);
				when 8=>  o_sample<=sampleE(15+8 downto 0+8);
				when 9=>  o_sample<=sampleE(15+9 downto 0+9);
				when 10=>  o_sample<=sampleE(15+10 downto 0+10);
				when 11=>  o_sample<=sampleE(15+11 downto 0+11);
				when 12=>  o_sample<=sampleE(15+12 downto 0+12);
				when others=>  o_sample<=sampleE(15+0 downto 0+0);
			end case;
			o_ce<='1';
		else
			o_ce<='0';
		end if;
	end if;
end process;

end conv2_16bit;


