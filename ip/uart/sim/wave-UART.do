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
add wave -noupdate -divider {TX FIFO}
add wave -noupdate /uart_rx_tb/uart_clk
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_wr_en
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_wr_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/tx_fifo_wr_data
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_rd_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/tx_fifo_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_ready
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_full
add wave -noupdate /uart_rx_tb/uart_dut/tx_fifo_empty
add wave -noupdate -divider {UART Write}
add wave -noupdate /uart_rx_tb/uart_clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_wr_data_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_valid_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_ready_l
add wave -noupdate -divider {RX FIFO}
add wave -noupdate /uart_rx_tb/uart_clk
add wave -noupdate /uart_rx_tb/uart_dut/rx_fifo_wr_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rx_fifo_wr_data
add wave -noupdate /uart_rx_tb/uart_dut/rx_fifo_rd_en
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rx_fifo_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/rx_fifo_ready
add wave -noupdate /uart_rx_tb/uart_dut/rx_fifo_full
add wave -noupdate /uart_rx_tb/uart_dut/rx_fifo_empty
add wave -noupdate -divider {UART Read}
add wave -noupdate /uart_rx_tb/uart_clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_rd_data_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_valid_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_ready_l
add wave -noupdate -divider {RX Skid Buffer}
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/clk
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/rst
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_en
add wave -noupdate -radix hexadecimal -childformat {{/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(7) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(6) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(5) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(4) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(3) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(2) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(1) -radix hexadecimal} {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(0) -radix hexadecimal}} -subitemconfig {/uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(7) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(6) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(5) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(4) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(3) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(2) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(1) {-height 16 -radix hexadecimal} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data(0) {-height 16 -radix hexadecimal}} /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_full
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_empty
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_ready
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/rd_data
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/rd_valid
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/rd_ready
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/fifo_valid
add wave -noupdate /uart_rx_tb/uart_dut/skid_buffer_rx/skid_valid
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/skid_data
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/skid_buffer_rx/state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62638376 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {1463284133 ps}
