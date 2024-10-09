onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rst
add wave -noupdate -divider {UART RX}
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rd_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rd_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_frame_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_frame_err
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rxd
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rxd_q
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rxd_qq
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/uart_rxd_qqq
add wave -noupdate -radix hexadecimal -childformat {{/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(7) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(6) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(5) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(4) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(3) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(2) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(1) -radix hexadecimal} {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(0) -radix hexadecimal}} -subitemconfig {/uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(7) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(6) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(5) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(4) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(3) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(2) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(1) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr(0) {-height 16 -radix hexadecimal}} /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_bit_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/baud_tick_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_busy
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/found_start
add wave -noupdate -divider {FIFO RX}
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/rst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/wr_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/wr_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/rd_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/full
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/empty
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rst_done
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rst_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/regce
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/regrst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_wr_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_wr_parity
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rd_parity
add wave -noupdate -divider {Skid Buffer RX}
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_full
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_empty
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/skid_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/skid_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82873362 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 325
configure wave -valuecolwidth 111
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {82642072 ps} {83296606 ps}
