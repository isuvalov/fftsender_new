onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/top_sender_i/reset
add wave -noupdate /tb/top_sender_i/clk_signal
add wave -noupdate /tb/top_sender_i/clk_core
add wave -noupdate /tb/top_sender_i/clk_mac
add wave -noupdate /tb/top_sender_i/payloadiszero
add wave -noupdate /tb/top_sender_i/pre_shift
add wave -noupdate /tb/top_sender_i/i_direction
add wave -noupdate /tb/top_sender_i/signal_ce
add wave -noupdate /tb/top_sender_i/signal_start
add wave -noupdate /tb/top_sender_i/signal_real
add wave -noupdate /tb/top_sender_i/signal_imag
add wave -noupdate /tb/top_sender_i/data_out
add wave -noupdate /tb/top_sender_i/dv
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
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_real
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_imag
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/dataout_re
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/dataout_im
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/dataout_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/data_exp
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/data_exp_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/sg_real
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/sg_imag
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/sg_real_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/sg_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/sg_imag_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_start_core
add wave -noupdate -expand -group make_fft -radix unsigned /tb/top_sender_i/make_fft_i/counter
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_dav
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_start_core2
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/signal_start_core_reg
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_sop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/fft_real_out
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/fft_imag_out
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_ena
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_sink_ena
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_sop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/master_source_eop
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/cut_ce
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/exponent_out
add wave -noupdate -expand -group make_fft /tb/top_sender_i/make_fft_i/dataout_ce
add wave -noupdate -expand -group make_fft -radix unsigned -subitemconfig {/tb/top_sender_i/make_fft_i/out_time(11) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(10) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(9) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(8) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(7) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(6) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(5) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(4) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(3) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(2) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(1) {-radix unsigned} /tb/top_sender_i/make_fft_i/out_time(0) {-radix unsigned}} /tb/top_sender_i/make_fft_i/out_time
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/reset
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/clk_mac
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/payloadiszero
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/rd_data
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/fifo_empty
add wave -noupdate -group send_upd -radix unsigned -subitemconfig {/tb/top_sender_i/send_udp_i/read_count(10) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(9) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(8) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(7) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(6) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(5) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(4) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(3) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(2) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(1) {-radix unsigned} /tb/top_sender_i/send_udp_i/read_count(0) {-radix unsigned}} /tb/top_sender_i/send_udp_i/read_count
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/rd_direct
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/i_direct
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/i_data
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/i_data_ce
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/rd_exp
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/i_data_exp
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/i_data_exp_ce
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/data_out
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/dv
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/stm_read
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/fifo_empty_1w
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/exp_first_read
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/signal_direct_reg
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/frame_num
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/cnt_mac
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/crc32
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/c_calc
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/s_data_out
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/s_dv
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/read_cnt
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/sig_dir
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/exp_fifose
add wave -noupdate -group send_upd /tb/top_sender_i/send_udp_i/delay_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1504500000 ps} 0}
configure wave -namecolwidth 188
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
WaveRestoreZoom {0 ps} {7506093 ns}
