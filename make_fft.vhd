library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_arith.all;

entity make_fft is
	generic (
		CLKCORE_EQUAL_CLKSIGNAL:integer:=1;
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

signal sg_real,sg_imag:std_logic_vector(11 downto 0);
signal sg_real_ce,sg_imag_ce,signal_start_core:std_logic;
signal master_sink_dav,master_sink_sop,s_data_exp_ce:std_logic;
signal fft_real_out,fft_imag_out:std_logic_vector(11 downto 0); 
signal master_source_ena,master_sink_ena,master_source_sop,master_source_eop,cut_ce:std_logic;
signal exponent_out:std_logic_vector(5 downto 0);
signal out_time:std_logic_vector(11 downto 0);
signal signal_start_core_reg,signal_start_core2,sg_real_ce_p,addition_end:std_logic;
signal input_cnt:std_logic_vector(log2roundup(CUT_LEN*4)-1 downto 0);
signal output_cnt:std_logic_vector(log2roundup(CUT_LEN*4)-1 downto 0);
signal reset_fft:std_logic:='1';
signal waitcnt:std_logic_vector(2 downto 0);

begin

signal_start_core<=signal_start;

  n_sample_count : process(clk_signal) is                                                       
    begin                                                                                         
      if rising_edge(clk_signal) then                                                                    
--		master_sink_sop<=signal_start_core2;
        if signal_start_core='1' then                                                                         
          input_cnt <= (others=>'0');
		  sg_real_ce_p<=sg_real_ce;
        else
			if sg_real_ce='1' then
				if unsigned(input_cnt)<((CUT_LEN*4)-1) then
	        		input_cnt <= input_cnt + 1;
					sg_real_ce_p<=sg_real_ce;
				else
					sg_real_ce_p<='0';
				end if;
			end if;
        end if;                                                                                    
      end if;                                                                                      
  end process n_sample_count; 






fft4096_inst: entity work.fft4096_x16
	PORT map(
		clk	=>clk_signal,
		reset	=>reset,--reset_fft,--reset,
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

--master_source_eop<=addition_end;


makeout : process(clk_signal) is                                                                      
  begin                                                                                         
    if rising_edge(clk_signal) then 

		master_sink_sop<=signal_start_core2;
		master_sink_dav <= sg_real_ce_p;
                                                                  
		sg_real_ce<=signal_ce;
		sg_imag_ce<=signal_ce;
		sg_real<=signal_real;
		sg_imag<=signal_imag;


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

		if master_sink_sop='1' then
        	output_cnt<=(others=>'0');
			addition_end<='0';
		else
			if master_source_ena='1' then
				if unsigned(output_cnt)<(CUT_LEN*4)-1 then
					output_cnt<=output_cnt+1;
				end if;
			end if;
			if output_cnt=(CUT_LEN*4)-2 then
				addition_end<='1';
			else
				addition_end<='0';
			end if;
		end if;
		if reset='1' then
			cut_ce<='0';
			out_time<=(others=>'1');
		else
			if master_source_sop='1' then
				out_time<=(others=>'0');
				cut_ce<='1';
				s_data_exp_ce<='1';
			else    
				s_data_exp_ce<='0';
				if master_source_ena='1' then
					out_time<=out_time+1;
				end if;
    
				if unsigned(out_time)<CUT_LEN-1 then
					cut_ce<='1';
				else
					cut_ce<='0';
				end if;
			end if; --# master_source_sop
		end if; --# reset
    end if;                                                                                     
end process;   

--dataout_ce<=cut_ce;

ch01: if CLKCORE_EQUAL_CLKSIGNAL/=1 generate

corestrob_i: entity work.corestrob
	generic map(
		WIDTH=>fft_real_out'Length
	)
	 port map(
		 clk_signal =>clk_signal,
		 clk_core =>clk_core,

		 data_i =>fft_real_out,
		 ce_i =>cut_ce,

		 data_o =>dataout_re,
		 ce_o =>dataout_ce
	     );

corestrob_r: entity work.corestrob
	generic map(
		WIDTH=>fft_real_out'Length
	)
	 port map(
		 clk_signal =>clk_signal,
		 clk_core =>clk_core,

		 data_i =>fft_imag_out,
		 ce_i =>cut_ce,

		 data_o =>dataout_im,
		 ce_o =>open
	     );


corestrob_rexp: entity work.corestrob
	generic map(
		WIDTH=>exponent_out'Length
	)
	 port map(
		 clk_signal =>clk_signal,
		 clk_core =>clk_core,

		 data_i =>exponent_out,
		 ce_i =>s_data_exp_ce,

		 data_o =>data_exp,
		 ce_o =>data_exp_ce
	     );
end generate; --# CLKCORE_EQUAL_CLKSIGNAL/=1

ch02: if CLKCORE_EQUAL_CLKSIGNAL=1 generate
	process(clk_core) is
	begin
		if rising_edge(clk_core) then
			dataout_re<=fft_real_out;
			dataout_im<=fft_imag_out;
			dataout_ce<=cut_ce;
			data_exp<=exponent_out;
			data_exp_ce<=s_data_exp_ce;
		end if;
	end process;
end generate; --# CLKCORE_EQUAL_CLKSIGNAL=1


end make_fft;
