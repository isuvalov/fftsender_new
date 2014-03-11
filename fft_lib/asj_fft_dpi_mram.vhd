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
--  $Header: /ipbu/cvs/dsp/projects/FFT/src/rtl/lib/asj_fft_dpi_mram.vhd,v 1.1.1.1 2005/12/08 01:14:15 jzhang Exp $ 
--  $log$ 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
-- megafunction wizard: %ALTSYNCRAM%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: altsyncram 

-- ============================================================
-- File Name: asj_fft_dpi_mram.vhd
-- Megafunction Name(s):
-- 			altsyncram
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
-- ************************************************************


--Copyright (C) 1991-2003 Altera Corporation
--Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
--support information,  device programming or simulation file,  and any other
--associated  documentation or information  provided by  Altera  or a partner
--under  Altera's   Megafunction   Partnership   Program  may  be  used  only
--to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
--other  use  of such  megafunction  design,  netlist,  support  information,
--device programming or simulation file,  or any other  related documentation
--or information  is prohibited  for  any  other purpose,  including, but not
--limited to  modification,  reverse engineering,  de-compiling, or use  with
--any other  silicon devices,  unless such use is  explicitly  licensed under
--a separate agreement with  Altera  or a megafunction partner.  Title to the
--intellectual property,  including patents,  copyrights,  trademarks,  trade
--secrets,  or maskworks,  embodied in any such megafunction design, netlist,
--support  information,  device programming or simulation file,  or any other
--related documentation or information provided by  Altera  or a megafunction
--partner, remains with Altera, the megafunction partner, or their respective
--licensors. No other licenses, including any licenses needed under any third
--party's intellectual property, are provided herein.


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fft_pack.all;
library lpm;
use lpm.lpm_components.all;
library altera_mf;
use altera_mf.altera_mf_components.all;



entity asj_fft_dpi_mram is
	generic(
					dpr : integer :=192; 
					apr : integer :=12;
					bytesize : integer :=8;
					bpr : integer :=24
	);
	port
	(
		data		: in std_logic_vector (dpr-1 downto 0);
		wren		: in std_logic  := '1';
		wraddress		: in std_logic_vector (apr-1 downto 0);
		rdaddress		: in std_logic_vector (apr-1 downto 0);
		byteena_a		: in std_logic_vector (bpr-1 downto 0);
		clock		: in std_logic ;
		q		: out std_logic_vector (dpr-1 downto 0)
	);
end asj_fft_dpi_mram;


architecture syn of asj_fft_dpi_mram is

		function GET_BYTE_SIZE(dpr : in integer) return integer is
      variable temp : integer;
    	begin
        if (dpr=144) then
        	temp := 9;
        else
        	temp := 8;
        end if;
      return temp;
    end GET_BYTE_SIZE;

	
  constant bs_comp : integer := GET_BYTE_SIZE(dpr);
	constant internal_dpr : integer:=bpr*bs_comp;
	constant external_mpr : integer:=dpr/8;
	constant internal_mpr : integer:=internal_dpr/8;
	signal sub_wire0	: std_logic_vector (internal_dpr-1 downto 0);
	signal data_int : std_logic_vector(internal_dpr-1 downto 0);
	signal q_int     : std_logic_vector(internal_dpr-1 downto 0);
	
	



	component altsyncram
	generic (
		operation_mode		: string;
		width_a		: natural;
		widthad_a		: natural;
		numwords_a		: natural;
		width_b		: natural;
		widthad_b		: natural;
		numwords_b		: natural;
		lpm_type		: string;
		width_byteena_a		: natural;
		byte_size		: natural;
		outdata_reg_b		: string;
		indata_aclr_a		: string;
		wrcontrol_aclr_a		: string;
		address_aclr_a		: string;
		byteena_aclr_a		: string;
		address_reg_b		: string;
		address_aclr_b		: string;
		outdata_aclr_b		: string;
		read_during_write_mode_mixed_ports		: string;
		ram_block_type		: string;
		intended_device_family		: string
	);
	port (
			wren_a	: in std_logic ;
			clock0	: in std_logic ;
			byteena_a	: in std_logic_vector (bpr-1 downto 0);
			address_a	: in std_logic_vector (apr-1 downto 0);
			address_b	: in std_logic_vector (apr-1 downto 0);
			q_b	: out std_logic_vector (internal_dpr-1 downto 0);
			data_a	: in std_logic_vector (internal_dpr-1 downto 0)
	);
	end component;

BEGIN
	


	gen_mpr20_bus : if(dpr=160) generate
	
		gen_input_data_bus : process(data) is
		begin
			for i in 8 downto 1 loop
			 -- Wrong data widths here for slices
				data_int(i*24-1 downto ((i-1)*24)+20) <= ((i*24)-1 downto ((i-1)*24)+20 => data((i*20)-1));
				data_int(((i-1)*24)+20-1 downto (i-1)*24) <=  data((i*20)-1 downto (i-1)*20);	
			end loop;
		end process gen_input_data_bus;
		
		gen_output_data_bus : process(q_int) is
		begin
			for i in 8 downto 1 loop
				q((i*20)-1 downto (i-1)*20) <=  q_int((i-1)*24+20-1 downto (i-1)*24);	
			end loop;
		--end generate gen_data_bus;
		end process gen_output_data_bus;
	
	end generate gen_mpr20_bus;
	
	
	gen_mpr161824_bus : if(dpr/=160) generate
	
		gen_input_data_bus : process(data) is
		begin
			for i in 8 downto 1 loop
				data_int(i*internal_mpr-1 downto ((i-1)*internal_mpr)+external_mpr) <= (i*internal_mpr-1 downto ((i-1)*internal_mpr)+external_mpr => data(i*external_mpr-1));
				data_int(((i-1)*internal_mpr)+external_mpr-1 downto (i-1)*internal_mpr) <=  data(i*external_mpr-1 downto (i-1)*external_mpr);	
			end loop;
		end process gen_input_data_bus;
		
		gen_output_data_bus : process(q_int) is
		begin
			for i in 8 downto 1 loop
				q(i*external_mpr-1 downto (i-1)*external_mpr) <=  q_int((i-1)*internal_mpr+external_mpr-1 downto (i-1)*internal_mpr);	
			end loop;
		--end generate gen_data_bus;
		end process gen_output_data_bus;
		
	end generate gen_mpr161824_bus;

	q_int    <= sub_wire0(internal_dpr-1 DOWNTO 0);


	altsyncram_component : altsyncram
	GENERIC MAP (
		operation_mode => "DUAL_PORT",
		width_a => internal_dpr,
		widthad_a => apr,
		numwords_a => 2**apr,
		width_b => internal_dpr,
		widthad_b => apr,
		numwords_b => 2**apr,
		lpm_type => "altsyncram",
		width_byteena_a => bpr,
		byte_size => bs_comp,
		outdata_reg_b => "CLOCK0",
		indata_aclr_a => "NONE",
		wrcontrol_aclr_a => "NONE",
		address_aclr_a => "NONE",
		byteena_aclr_a => "NONE",
		address_reg_b => "CLOCK0",
		address_aclr_b => "NONE",
		outdata_aclr_b => "NONE",
		read_during_write_mode_mixed_ports => "DONT_CARE",
		ram_block_type => "M-RAM",
		intended_device_family => "Stratix"
	)
	PORT MAP (
		wren_a => wren,
		clock0 => clock,
		byteena_a => byteena_a,
		address_a => wraddress,
		address_b => rdaddress,
		data_a => data_int,
		q_b => sub_wire0
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: VarWidth NUMERIC "0"
-- Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "16"
-- Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "16"
-- Retrieval info: PRIVATE: MEMSIZE NUMERIC "65536"
-- Retrieval info: PRIVATE: Clock NUMERIC "0"
-- Retrieval info: PRIVATE: rden NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE_A NUMERIC "1"
-- Retrieval info: PRIVATE: BYTE_ENABLE_B NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
-- Retrieval info: PRIVATE: Clock_A NUMERIC "0"
-- Retrieval info: PRIVATE: Clock_B NUMERIC "0"
-- Retrieval info: PRIVATE: REGdata NUMERIC "1"
-- Retrieval info: PRIVATE: REGwraddress NUMERIC "1"
-- Retrieval info: PRIVATE: REGwren NUMERIC "1"
-- Retrieval info: PRIVATE: REGrdaddress NUMERIC "1"
-- Retrieval info: PRIVATE: REGrren NUMERIC "1"
-- Retrieval info: PRIVATE: REGq NUMERIC "0"
-- Retrieval info: PRIVATE: INDATA_REG_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRADDR_REG_B NUMERIC "0"
-- Retrieval info: PRIVATE: OUTDATA_REG_B NUMERIC "1"
-- Retrieval info: PRIVATE: CLRdata NUMERIC "0"
-- Retrieval info: PRIVATE: CLRwren NUMERIC "0"
-- Retrieval info: PRIVATE: CLRwraddress NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrdaddress NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrren NUMERIC "0"
-- Retrieval info: PRIVATE: CLRq NUMERIC "0"
-- Retrieval info: PRIVATE: BYTEENA_ACLR_A NUMERIC "0"
-- Retrieval info: PRIVATE: INDATA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRCTRL_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: WRADDR_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: OUTDATA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: BYTEENA_ACLR_B NUMERIC "0"
-- Retrieval info: PRIVATE: enable NUMERIC "0"
-- Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_MIXED_PORTS NUMERIC "2"
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
-- Retrieval info: PRIVATE: MIFfilename STRING ""
-- Retrieval info: PRIVATE: UseLCs NUMERIC "0"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_B"
-- Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
-- Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "2"
-- Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "DUAL_PORT"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "12"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "4096"
-- Retrieval info: CONSTANT: WIDTH_B NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD_B NUMERIC "12"
-- Retrieval info: CONSTANT: NUMWORDS_B NUMERIC "4096"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "2"
-- Retrieval info: CONSTANT: BYTE_SIZE NUMERIC "8"
-- Retrieval info: CONSTANT: OUTDATA_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: INDATA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: WRCONTROL_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: BYTEENA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: ADDRESS_REG_B STRING "CLOCK0"
-- Retrieval info: CONSTANT: ADDRESS_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_B STRING "NONE"
-- Retrieval info: CONSTANT: READ_DURING_WRITE_MODE_MIXED_PORTS STRING "DONT_CARE"
-- Retrieval info: CONSTANT: RAM_BLOCK_TYPE STRING "AUTO"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Stratix"
-- Retrieval info: USED_PORT: data 0 0 16 0 INPUT NODEFVAL data[15..0]
-- Retrieval info: USED_PORT: wren 0 0 0 0 INPUT VCC wren
-- Retrieval info: USED_PORT: q 0 0 16 0 OUTPUT NODEFVAL q[15..0]
-- Retrieval info: USED_PORT: wraddress 0 0 12 0 INPUT NODEFVAL wraddress[11..0]
-- Retrieval info: USED_PORT: rdaddress 0 0 12 0 INPUT NODEFVAL rdaddress[11..0]
-- Retrieval info: USED_PORT: byteena_a 0 0 2 0 INPUT VCC byteena_a[1..0]
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: CONNECT: @data_a 0 0 16 0 data 0 0 16 0
-- Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 16 0 @q_b 0 0 16 0
-- Retrieval info: CONNECT: @address_a 0 0 12 0 wraddress 0 0 12 0
-- Retrieval info: CONNECT: @address_b 0 0 12 0 rdaddress 0 0 12 0
-- Retrieval info: CONNECT: @byteena_a 0 0 2 0 byteena_a 0 0 2 0
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
