onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /uart_tb_top/uart_clk
add wave -noupdate /uart_tb_top/uart_rst
add wave -noupdate /uart_tb_top/uart_wr_data
add wave -noupdate /uart_tb_top/uart_wr_valid
add wave -noupdate /uart_tb_top/uart_wr_ready
add wave -noupdate -radix ascii -childformat {{/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(7) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(6) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(5) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(4) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(3) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(2) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(1) -radix ascii} {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(0) -radix ascii}} -subitemconfig {/uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(7) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(6) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(5) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(4) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(3) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(2) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(1) {-radix ascii} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data(0) {-radix ascii}} /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_data
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_valid
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rd_ready
add wave -noupdate -divider {UART RX}
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/clk
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/rst
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rxd
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rxd_q
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rxd_qq
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/uart_rxd_qqq
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/rx_data_sr
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/rx_bit_cnt
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/baud_tick_cnt
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/rx_busy
add wave -noupdate /uart_tb_top/uart_dut/uart_rx_i0/rx_done
add wave -noupdate -divider {UART TX}
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/clk
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/rst
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/baud_tick
add wave -noupdate -radix hexadecimal /uart_tb_top/uart_dut/uart_tx_i0/uart_wr_data
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/uart_wr_valid
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/uart_wr_ready
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/uart_txd
add wave -noupdate -radix binary -childformat {{/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(9) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(8) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(7) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(6) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(5) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(4) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(3) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(2) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(1) -radix binary} {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(0) -radix binary}} -subitemconfig {/uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(9) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(8) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(7) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(6) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(5) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(4) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(3) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(2) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(1) {-height 16 -radix binary} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr(0) {-height 16 -radix binary}} /uart_tb_top/uart_dut/uart_tx_i0/tx_data_sr
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/tx_bit_cnt
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/tx_frame_cnt
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/tx_busy
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/tx_done
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/baud_tick_q
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/baud_tick_qq
add wave -noupdate /uart_tb_top/uart_dut/uart_tx_i0/baud_tick_red
add wave -noupdate /uart_tb_top/uart_dut/loopback
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {296750197 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 158
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {2100507663 ps}
