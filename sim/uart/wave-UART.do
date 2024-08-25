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
add wave -noupdate -divider {UART Write}
add wave -noupdate /uart_rx_tb/uart_clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/uart_wr_data_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_valid_l
add wave -noupdate /uart_rx_tb/uart_dut/uart_wr_ready_l
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {66578175 ps} 0}
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
WaveRestoreZoom {0 ps} {504569045 ps}
