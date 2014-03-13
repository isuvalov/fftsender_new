library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity make_fft is
	generic (
		CUT_LEN:integer:=1024 	--# How many samples transfer to MAC
	);
	 port(
		 reset: in std_logic;
		 clk_signal: in std_logic;
		 clk_core: in std_logic; --# must be quickly than clk_signal

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
end make_fft;


architecture make_fft of make_fft is

signal sg_real,sg_imag:std_logic_vector(11 downto 0);
signal sg_real_ce,sg_imag_ce,signal_start_core:std_logic;
signal counter : std_logic_vector(11 downto 0); 
signal master_sink_dav,master_sink_sop:std_logic;
signal fft_real_out,fft_imag_out:std_logic_vector(11 downto 0); 
signal master_source_ena,master_sink_ena,master_source_sop,master_source_eop,cut_ce:std_logic;
signal exponent_out:std_logic_vector(5 downto 0);
signal out_time:std_logic_vector(11 downto 0);
signal sg_ce_n,signal_start_core_reg,signal_start_core2,sg_ce,sg_ce_1w:std_logic;

begin

signal_start_core<=signal_start;

  n_sample_count : process(clk_signal) is                                                       
    begin                                                                                         
      if rising_edge(clk_signal) then                                                                    
		sg_ce_1w<=sg_ce;
        if signal_start_core='1' then                                                                         
          counter <= (others=>'0');
        else
			if sg_real_ce='1' then
        		counter <= counter + 1;
			end if;
        end if;                                                                                    
      end if;                                                                                      
  end process n_sample_count; 

master_sink_sop<=signal_start_core2;




sg_ce_n<=not sg_ce;
fft4096_inst: entity work.fft4096_x16
	PORT map(
		clk	=>clk_signal,--sg_ce_n,--clk_core,
		reset	=>reset,
		master_sink_dav	=>master_sink_dav, 
		master_sink_sop	=>master_sink_sop,
		master_sink_ena	=>master_sink_ena,
		inv_i	=>'0',
		data_real_in	=>sg_real,
		data_imag_in	=>sg_imag,
		fft_real_out	=>fft_real_out,
		fft_imag_out	=>fft_imag_out,
		exponent_out	=>exponent_out,
		master_source_dav =>'1',--'1',--'1',
		master_source_sop =>master_source_sop,
		master_source_eop =>master_source_eop,
		master_source_ena =>master_source_ena
	);



makeout : process(clk_signal) is                                                                      
  begin                                                                                         
    if rising_edge(clk_signal) then                                                                   
		data_exp<=exponent_out;
		dataout_re<=fft_real_out;
		dataout_im<=fft_imag_out;

		sg_real_ce<=signal_ce;
		sg_imag_ce<=signal_ce;
		sg_real<=signal_real;
		sg_imag<=signal_imag;
		master_sink_dav <= sg_real_ce;


		
		if signal_start_core='1' then
			signal_start_core_reg<='1';
			signal_start_core2<='0';
		else			
			if sg_real_ce='1' and signal_start_core_reg='1' then
				signal_start_core2<='1';
				signal_start_core_reg<='0';
			else
				signal_start_core2<='0';
			end if;
		end if;


		if master_source_sop='1' then
			out_time<=(others=>'0');
			cut_ce<='1';
			data_exp_ce<='1';
		else    
			data_exp_ce<='0';
			if master_source_ena='1' then
				out_time<=out_time+1;
			end if;
    
			if unsigned(out_time)<CUT_LEN-1 then
				cut_ce<='1';
			else
				cut_ce<='0';
			end if;
		end if; --# master_source_sop
    end if;                                                                                     
end process;   

dataout_ce<=cut_ce;



end make_fft;
