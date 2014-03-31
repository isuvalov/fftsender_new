onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/top_sender_i/clk_signal
add wave -noupdate /tb/top_sender_i/clk_core
add wave -noupdate /tb/top_sender_i/clk_mac
add wave -noupdate /tb/top_sender_i/payloadiszero
add wave -noupdate /tb/top_sender_i/pre_shift
add wave -noupdate -color blue -itemcolor blue /tb/top_sender_i/reset
add wave -noupdate -color Blue -itemcolor Blue /tb/top_sender_i/signal_ce
add wave -noupdate -color Blue -itemcolor Blue /tb/top_sender_i/i_direction
add wave -noupdate -color Blue -itemcolor Blue /tb/top_sender_i/signal_start
add wave -noupdate -color Blue -itemcolor Blue -radix unsigned -subitemconfig {/tb/top_sender_i/signal_real(11) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(10) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(9) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(8) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(7) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(6) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(5) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(4) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(3) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(2) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(1) {-color #00000000ffff -itemcolor #00000000ffff} /tb/top_sender_i/signal_real(0) {-color #00000000ffff -itemcolor #00000000ffff}} /tb/top_sender_i/signal_real
add wave -noupdate -color Blue -itemcolor Blue -radix unsigned /tb/top_sender_i/signal_imag
add wave -noupdate -color Blue -itemcolor Blue /tb/top_sender_i/data_out
add wave -noupdate -color Blue -itemcolor Blue /tb/top_sender_i/dv
add wave -noupdate /tb/top_sender_i/fft_dataout_re
add wave -noupdate /tb/top_sender_i/fft_dataout_im
add wave -noupdate /tb/top_sender_i/fft_dataout_ce
add wave -noupdate /tb/top_sender_i/fft_data_exp
add wave -noupdate /tb/top_sender_i/fft_data_exp_ce
add wave -noupdate /tb/top_sender_i/abs_data
add wave -noupdate /tb/top_sender_i/abs_data_ce
add wave -noupdate /tb/top_sender_i/abs_data_exp
add wave -noupdate /tb/top_sender_i/abs_data_exp_ce
add wave -noupdate /tb/top_sender_i/direction_1w
add wave -noupdate /tb/top_sender_i/direction_2w
add wave -noupdate /tb/top_sender_i/direction_3w
add wave -noupdate /tb/top_sender_i/signal_start_1w
add wave -noupdate /tb/top_sender_i/signal_start_2w
add wave -noupdate /tb/top_sender_i/signal_start_3w
add wave -noupdate /tb/top_sender_i/sig_direct
add wave -noupdate /tb/top_sender_i/sig_direct_ce
add wave -noupdate /tb/top_sender_i/fifo_empty
add wave -noupdate /tb/top_sender_i/read_count
add wave -noupdate /tb/top_sender_i/rd_exp
add wave -noupdate /tb/top_sender_i/rd_data
add wave -noupdate /tb/top_sender_i/rd_direct
add wave -noupdate /tb/top_sender_i/direct
add wave -noupdate /tb/top_sender_i/fifo_data_ce
add wave -noupdate /tb/top_sender_i/fifo_data_exp_ce
add wave -noupdate /tb/top_sender_i/fifo_data
add wave -noupdate /tb/top_sender_i/fifo_data_exp
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/reset
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/clk_signal
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/clk_core
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_start
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/signal_real
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/signal_imag
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/dataout_re
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/dataout_im
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/dataout_ce
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/data_exp
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/data_exp_ce
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/sg_real
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/sg_imag
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/sg_real_ce
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/sg_imag_ce
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/signal_start_core
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/signal_start_core2
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/signal_start_core_reg
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/fft_real_out
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/fft_imag_out
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/reset_fft
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/waitcnt
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/addition_end
add wave -noupdate -expand -group make_fft -radix unsigned /tb/top_sender_i/make_fft_i/output_cnt
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_ena
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_dav
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_ena
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_sop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_sop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_eop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/cut_ce
add wave -noupdate -expand -group make_fft -radix hexadecimal /tb/top_sender_i/make_fft_i/exponent_out
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/dataout_ce
add wave -noupdate -expand -group make_fft -radix unsigned /tb/top_sender_i/make_fft_i/out_time
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/reset
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/clk_mac
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/payloadiszero
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/rd_data
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/fifo_empty
add wave -noupdate -expand -group send_upd -radix unsigned /tb/top_sender_i/send_udp_i/read_count
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/rd_direct
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/i_direct
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/i_data
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/i_data_ce
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/rd_exp
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/i_data_exp
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/i_data_exp_ce
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/data_out
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/dv
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/stm_read
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/fifo_empty_1w
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/exp_first_read
add wave -noupdate -expand -group send_upd /tb/top_sender_i/send_udp_i/signal_direct_reg
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/frame_num
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/cnt_mac
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/crc32
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/c_calc
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/s_data_out
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/s_dv
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/read_cnt
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/sig_dir
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/exp_fifose
add wave -noupdate -expand -group send_upd -radix hexadecimal /tb/top_sender_i/send_udp_i/delay_cnt
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/reset
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/clk_core
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/pre_shift
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/i_data_re
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/i_data_im
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/i_data_ce
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/i_data_exp
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/i_data_exp_ce
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/o_dataout
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/o_dataout_ce
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/o_data_exp
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/o_data_exp_ce
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/sq_dataout_re
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/sq_dataout_im
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/tosqrt
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/fft_plus_shift
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/fft_plus
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/dataout_ce_1w
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/dataout_ce_2w
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/s_dataout
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/exp_ce_w
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/data_ce_w
add wave -noupdate -group make_abs /tb/top_sender_i/make_abs_i/exp_data_w
add wave -noupdate -group fifo_all /tb/top_sender_i/fifo_all_i/reset
add wave -noupdate -group fifo_all /tb/top_sender_i/fifo_all_i/clk_core
add wave -noupdate -group fifo_all /tb/top_sender_i/fifo_all_i/clk_mac
add wave -noupdate -group fifo_all /tb/top_sender_i/fifo_all_i/i_direct
add wave -noupdate -group fifo_all /tb/top_sender_i/fifo_all_i/i_direct_ce
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/i_data
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/i_data_ce
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/i_data_exp
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/i_data_exp_ce
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/fifo_empty
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/rd_data
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/rd_exp
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/rd_direct
add wave -noupdate -group fifo_all -radix unsigned /tb/top_sender_i/fifo_all_i/read_count
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/o_direct
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/o_data
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/o_data_ce
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/o_data_exp
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/o_data_exp_ce
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/i_direct_reg
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/directe
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/full
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/empty
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/wr
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/wre
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/full_exp
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/empty_exp
add wave -noupdate -group fifo_all -radix hexadecimal /tb/top_sender_i/fifo_all_i/exponent_oute
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4697640000 ps} 0}
configure wave -namecolwidth 205
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {10500 us}
