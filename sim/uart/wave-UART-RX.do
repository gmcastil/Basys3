onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider UART
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_valid
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_wr_data
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_valid
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_ready
add wave -noupdate /uart_rx_tb/uart_dut/uart_mode
add wave -noupdate /uart_rx_tb/uart_dut/uart_rxd
add wave -noupdate /uart_rx_tb/uart_dut/uart_txd
add wave -noupdate /uart_rx_tb/uart_dut/baud_tick
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rx_frame_err
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rx_frame_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/tx_frame_cnt
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
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_data_sr
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_bit_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/baud_tick_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/rx_busy
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rx_i0/found_start
add wave -noupdate -divider {RX FIFO}
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
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/fifo_rst_cnt
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/fifo_rx_i0/rst_done
add wave -noupdate -divider {RX Skid Buffer}
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rst
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_full
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_empty
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/skid_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/skid_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1035342348 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 142
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
WaveRestoreZoom {0 ps} {1155 us}
