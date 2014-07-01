onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb/cccnt
add wave -noupdate -group top /tb/top_top_i/reset
add wave -noupdate -group top /tb/top_top_i/clk_signal
add wave -noupdate -group top /tb/top_top_i/clk_core
add wave -noupdate -group top /tb/top_top_i/clk_mac
add wave -noupdate -group top /tb/top_top_i/payload_is_counter
add wave -noupdate -group top /tb/top_top_i/PayloadIsZERO
add wave -noupdate -group top /tb/top_top_i/send_adc_data
add wave -noupdate -group top /tb/top_top_i/pre_shift
add wave -noupdate -group top /tb/top_top_i/i_direction
add wave -noupdate -group top /tb/top_top_i/signal_ce
add wave -noupdate -group top /tb/top_top_i/signal_start
add wave -noupdate -group top /tb/top_top_i/signal_real
add wave -noupdate -group top /tb/top_top_i/signal_imag
add wave -noupdate -group top /tb/top_top_i/data_out
add wave -noupdate -group top /tb/top_top_i/dv
add wave -noupdate -group top /tb/top_top_i/data_i
add wave -noupdate -group top /tb/top_top_i/dv_i
add wave -noupdate -group top /tb/top_top_i/tp_tx
add wave -noupdate -group top /tb/top_top_i/tp_rx
add wave -noupdate -group top /tb/top_top_i/reset_tx
add wave -noupdate -group top /tb/top_top_i/reset_rx
add wave -noupdate -group top /tb/top_top_i/to_tx_module
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/CLKCORE_EQUAL_CLKSIGNAL
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/PayloadIsZERO
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/SWAP_SIGNALBITS
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/clk_core
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/clk_mac
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/clk_signal
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/i_direction
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/payload_is_counter
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/pre_shift
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/reset
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/send_adc_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_imag
add wave -noupdate -expand -group top_sender -format Analog-Step -height 30 -max 3000.0 -min -3000.0 /tb/top_top_i/top_sender_i/signal_real
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_real
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_start
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/to_tx_module
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/udp_IPaddr
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/udp_port_number
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/data_out
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/dv
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/tp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/CUT_LEN
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/DEBUG
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/MAX_TARGET_NUM
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/abs_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/abs_data_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/abs_data_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/abs_data_exp_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/adc_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/adc_data_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/adc_data_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/adc_data_exp_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/data_req_event
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/direct
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/direction_1w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/direction_2w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/direction_3w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_data_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_data_exp_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_data_exp_ce_1w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_data_exp_ce_2w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_dataout_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_dataout_im
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fft_dataout_re
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fifo_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fifo_data_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fifo_data_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fifo_data_exp_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/fifo_empty
add wave -noupdate -expand -group top_sender -radix unsigned /tb/top_top_i/top_sender_i/harm_cnt
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/making_fft
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/maximum
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/maximum_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/maximum_m1
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/maximum_p1
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/mux_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/mux_data_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/mux_data_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/mux_data_exp_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/protocol_data_out
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/protocol_dv
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rd_data
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rd_direct
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rd_exp
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/read_count
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/ready
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rls_data_out
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rls_dv
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rls_finish
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/rls_mux
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sample16l
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sample16l_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sample16l_ce_1w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sample16l_ce_2w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sig_direct
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/sig_direct_ce
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_start_1w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_start_2w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/signal_start_3w
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/targets
add wave -noupdate -expand -group top_sender -radix unsigned /tb/top_top_i/top_sender_i/targets_cnt
add wave -noupdate -expand -group top_sender -radix unsigned -childformat {{/tb/top_top_i/top_sender_i/targets_harm(31) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(30) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(29) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(28) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(27) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(26) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(25) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(24) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(23) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(22) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(21) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(20) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(19) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(18) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(17) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(16) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(15) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(14) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(13) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(12) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(11) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(10) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(9) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(8) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(7) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(6) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(5) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(4) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(3) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(2) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(1) -radix unsigned} {/tb/top_top_i/top_sender_i/targets_harm(0) -radix unsigned}} -subitemconfig {/tb/top_top_i/top_sender_i/targets_harm(31) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(30) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(29) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(28) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(27) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(26) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(25) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(24) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(23) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(22) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(21) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(20) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(19) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(18) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(17) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(16) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(15) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(14) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(13) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(12) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(11) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(10) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(9) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(8) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(7) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(6) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(5) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(4) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(3) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(2) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(1) {-height 15 -radix unsigned} /tb/top_top_i/top_sender_i/targets_harm(0) {-height 15 -radix unsigned}} /tb/top_top_i/top_sender_i/targets_harm
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/targets_m1
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/targets_p1
add wave -noupdate -expand -group top_sender /tb/top_top_i/top_sender_i/tp_fifo
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/reset
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/clk_core
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/clk_mac
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/to_tx_module
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/data_i
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/dv_i
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/tp
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/cnt_conv
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/data8
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/dv8
add wave -noupdate -group top_receiver /tb/top_top_i/top_receiver_i/ce8
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/clk
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/data_i
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/ce_i
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/dv_i
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/data_o
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/dv_o
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/cnt_conv
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/data_reg
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/s_data_o
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/s_dv_o
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/ce_1w
add wave -noupdate -group {conv 8 to 4} /tb/macbits_conv8to4_i/dv_reg
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/clk
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/data_i
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/dv_i
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/data_o
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/ce_o
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/dv_o
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/cnt_conv
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/dv_i_1w
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/dv_i_2w
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/s_ce
add wave -noupdate -group {conv 4 to 8} /tb/top_top_i/top_receiver_i/macbits_conv4to8_i/data_reg
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/reset
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/clk
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/port_number
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/i_dv
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/i_ce
add wave -noupdate -group udp_rx_02 -radix hexadecimal -childformat {{/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(7) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(6) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(5) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(4) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(3) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(2) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(1) -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(0) -radix hexadecimal}} -subitemconfig {/tb/top_top_i/top_receiver_i/udp_rx_i/i_data(7) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(6) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(5) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(4) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(3) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(2) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(1) {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data(0) {-height 15 -radix hexadecimal}} /tb/top_top_i/top_receiver_i/udp_rx_i/i_data
add wave -noupdate -group udp_rx_02 -radix hexadecimal -childformat {{/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.new_request_received -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.number_of_req -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.request_type -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.infinity_measure -radix hexadecimal} {/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.measure_time -radix hexadecimal}} -expand -subitemconfig {/tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.new_request_received {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.number_of_req {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.request_type {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.infinity_measure {-height 15 -radix hexadecimal} /tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx.measure_time {-height 15 -radix hexadecimal}} /tb/top_top_i/top_receiver_i/udp_rx_i/rx2tx
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/correct_prmb_cnt
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/correct_mac_cnt
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/udp_header_cnt
add wave -noupdate -group udp_rx_02 -radix unsigned /tb/top_top_i/top_receiver_i/udp_rx_i/by_frame_cnt
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/port_number_reg
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/port_number_correct
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/port_error
add wave -noupdate -group udp_rx_02 -radix hexadecimal /tb/top_top_i/top_receiver_i/udp_rx_i/stm
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/can_go
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/ce
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/clk
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/reset
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/data_o
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/dv_o
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/RESP_NUM
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/cnt
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/delay_cnt
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/seq_array0
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/seq_array1
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/seq_array2
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/seq_array3
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/seq_array4
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/sizes
add wave -noupdate -group file_request /tb/cpp_req2vhdl_i/stm
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/can_go
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/ce
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/clk
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/reset
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/data_o
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/dv_o
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/RESP_NUM
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/cnt
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/delay_cnt
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/seq_array0
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/seq_array1
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/seq_array2
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/seq_array3
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/seq_array4
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/sizes
add wave -noupdate -group file_response /tb/cpu_correct_requset_i/stm
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/clk
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/data_i
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/ce_i
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/dv_i
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/data_o
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/dv_o
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/cnt_conv
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/data_reg
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/s_data_o
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/s_dv_o
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/ce_1w
add wave -noupdate -group tb_8to4 /tb/macbits_conv8to4_i/dv_reg
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/reset
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/clk_mac
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/radar_status
add wave -noupdate -group send_protocol -expand /tb/top_top_i/top_sender_i/send_protocol_udp_i/to_tx_module
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/data_out
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/dv
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/frame_num
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/stm_read
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/exp_first_read
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/signal_direct_reg
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/cnt_mac
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/crc32
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/C_calc
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/s_data_out
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/s_dv
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/read_cnt
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/sig_dir
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/exp_fifosE
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/delay_cnt
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/request_type_reg
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/number_of_req_reg
add wave -noupdate -group send_protocol /tb/top_top_i/top_sender_i/send_protocol_udp_i/to_tx_module_1w
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/clk
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/i_ce
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/i_sample
add wave -noupdate -expand -group convert -radix unsigned -childformat {{/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(5) -radix decimal} {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(4) -radix decimal} {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(3) -radix decimal} {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(2) -radix decimal} {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(1) -radix decimal} {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(0) -radix decimal}} -subitemconfig {/tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(5) {-radix decimal} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(4) {-radix decimal} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(3) {-radix decimal} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(2) {-radix decimal} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(1) {-radix decimal} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp(0) {-radix decimal}} /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/i_exp_ce
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/o_sample
add wave -noupdate -expand -group convert /tb/top_top_i/top_sender_i/conv2_16bit_i/o_ce
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/reset
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/clk
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/i_ce
add wave -noupdate -expand -group find_max -format Analog-Step -height 50 -max 600.0 -radix unsigned /tb/top_top_i/top_sender_i/find_max_i/i_sample
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/i_sample
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/maximum_m1
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/maximum
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/maximum_p1
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/maximum_ce
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/trace
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/cnt
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/max_pos
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/make_max_pos
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/max_val
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/make_max_val
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/ce_max
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/mul_thr
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/prev_maximum_exist
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/can_calc
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/prev_maximum_val
add wave -noupdate -expand -group find_max /tb/top_top_i/top_sender_i/find_max_i/prev_maximum_exist_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8420966511 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {8384678324 ps} {8536125963 ps}
