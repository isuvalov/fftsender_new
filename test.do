quit -sim

vlib work
vmap work work

vcom FromTextFile.vhd
vcom ToTextFile.vhd 

vcom -novopt -work work fft_lib/fft_pack.vhd                  
vcom -novopt -work work fft_lib/twid_rom.vhd                  
vcom -novopt -work work fft_lib/asj_fft_1dp_ram.vhd           
vcom -novopt -work work fft_lib/asj_fft_1tdp_rom.vhd          
vcom -novopt -work work fft_lib/asj_fft_3dp_rom.vhd           
vcom -novopt -work work fft_lib/asj_fft_3pi_mram.vhd          
vcom -novopt -work work fft_lib/asj_fft_3tdp_rom.vhd          
vcom -novopt -work work fft_lib/asj_fft_4dp_ram.vhd           
vcom -novopt -work work fft_lib/asj_fft_6tdp_rom.vhd          
vcom -novopt -work work fft_lib/asj_fft_alt_shift_tdl.vhd     
vcom -novopt -work work fft_lib/asj_fft_bfp_ctrl.vhd          
vcom -novopt -work work fft_lib/asj_fft_bfp_i.vhd             
vcom -novopt -work work fft_lib/asj_fft_bfp_i_1pt.vhd         
vcom -novopt -work work fft_lib/asj_fft_bfp_o.vhd             
vcom -novopt -work work fft_lib/asj_fft_bfp_o_1pt.vhd         
vcom -novopt -work work fft_lib/asj_fft_burst_ctrl.vhd        
vcom -novopt -work work fft_lib/asj_fft_burst_ctrl_de.vhd     
vcom -novopt -work work fft_lib/asj_fft_burst_ctrl_qe.vhd     
vcom -novopt -work work fft_lib/asj_fft_cmult_can.vhd         
vcom -novopt -work work fft_lib/asj_fft_cmult_std.vhd         
vcom -novopt -work work fft_lib/asj_fft_cnt_ctrl.vhd          
vcom -novopt -work work fft_lib/asj_fft_cnt_ctrl_de.vhd       
vcom -novopt -work work fft_lib/asj_fft_cxb_addr.vhd          
vcom -novopt -work work fft_lib/asj_fft_cxb_data.vhd          
vcom -novopt -work work fft_lib/asj_fft_cxb_data_mram.vhd     
vcom -novopt -work work fft_lib/asj_fft_cxb_data_r.vhd        
vcom -novopt -work work fft_lib/asj_fft_data_ram.vhd          
vcom -novopt -work work fft_lib/asj_fft_data_ram_dp.vhd       
vcom -novopt -work work fft_lib/asj_fft_dataadgen.vhd         
vcom -novopt -work work fft_lib/asj_fft_dft_bfp.vhd           
vcom -novopt -work work fft_lib/asj_fft_dft_bfp_sgl.vhd       
vcom -novopt -work work fft_lib/asj_fft_dp_mram.vhd           
vcom -novopt -work work fft_lib/asj_fft_dpi_mram.vhd          
vcom -novopt -work work fft_lib/asj_fft_dualstream.vhd        
vcom -novopt -work work fft_lib/asj_fft_in_write_sgl.vhd      
vcom -novopt -work work fft_lib/asj_fft_lcm_mult.vhd          
vcom -novopt -work work fft_lib/asj_fft_lcm_mult_2m.vhd       
vcom -novopt -work work fft_lib/asj_fft_lpp.vhd               
vcom -novopt -work work fft_lib/asj_fft_lpp_serial.vhd        
vcom -novopt -work work fft_lib/asj_fft_lpp_serial_r2.vhd     
vcom -novopt -work work fft_lib/asj_fft_lpprdadgen.vhd        
vcom -novopt -work work fft_lib/asj_fft_lpprdadr2gen.vhd      
vcom -novopt -work work fft_lib/asj_fft_m_k_counter.vhd       
vcom -novopt -work work fft_lib/asj_fft_mult_add.vhd          
vcom -novopt -work work fft_lib/asj_fft_pround.vhd            
vcom -novopt -work work fft_lib/asj_fft_sglstream.vhd         
vcom -novopt -work work fft_lib/asj_fft_si_de_so_b.vhd        
vcom -novopt -work work fft_lib/asj_fft_si_de_so_bb.vhd       
vcom -novopt -work work fft_lib/asj_fft_si_qe_so_b.vhd        
vcom -novopt -work work fft_lib/asj_fft_si_qe_so_bb.vhd       
vcom -novopt -work work fft_lib/asj_fft_si_se_so_b.vhd        
vcom -novopt -work work fft_lib/asj_fft_si_se_so_bb.vhd       
vcom -novopt -work work fft_lib/asj_fft_si_sose_so_b.vhd      
vcom -novopt -work work fft_lib/asj_fft_tdl.vhd               
vcom -novopt -work work fft_lib/asj_fft_tdl_bit.vhd           
vcom -novopt -work work fft_lib/asj_fft_tdl_bit_rst.vhd       
vcom -novopt -work work fft_lib/asj_fft_tdl_rst.vhd           
vcom -novopt -work work fft_lib/asj_fft_twadgen.vhd           
vcom -novopt -work work fft_lib/asj_fft_twadgen_dual.vhd      
vcom -novopt -work work fft_lib/asj_fft_twadsogen.vhd         
vcom -novopt -work work fft_lib/asj_fft_twadsogen_q.vhd       
vcom -novopt -work work fft_lib/asj_fft_twid_rom_tdp.vhd      
vcom -novopt -work work fft_lib/asj_fft_twiddle_ctrl_qe.vhd   
vcom -novopt -work work fft_lib/asj_fft_unbburst_ctrl.vhd     
vcom -novopt -work work fft_lib/asj_fft_unbburst_ctrl_de.vhd  
vcom -novopt -work work fft_lib/asj_fft_unbburst_ctrl_qe.vhd  
vcom -novopt -work work fft_lib/asj_fft_unbburst_sose_ctrl.vhd
vcom -novopt -work work fft_lib/asj_fft_wrengen.vhd           
vcom -novopt -work work fft_lib/asj_fft_wrswgen.vhd           

vcom -novopt -work work fft4096_x16.vhd
vcom -novopt -work work fifo16x4.vhd 
vcom -novopt -work work sqrt32to16.vhd 

vcom -novopt -work work GrayCounter.vhd 
vcom -novopt -work work aFifo.vhd


vcom assert_pack.vhd 

vcom corestrob.vhd

vcom make_abs.vhd
vcom make_fft.vhd
vcom send_udp.vhd 

vcom -novopt -work work FromTextFile.vhd 
vcom -novopt -work work ToTextFile.vhd 
#vcom -novopt -work work tb.vhd


#vsim -novopt -t ps work.tb
#do wave.do
#run -all


