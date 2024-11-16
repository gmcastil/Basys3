onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/clk
add wave -noupdate -radix hexadecimal /uart_rx_tb/uart_dut/rst
add wave -noupdate /uart_rx_tb/uart_dut/clk
add wave -noupdate /uart_rx_tb/uart_dut/rst
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_valid
add wave -noupdate /uart_rx_tb/uart_dut/uart_rd_ready
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_data
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_en
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/rd_valid
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_valid_int
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_valid
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_data
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_en
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_valid
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/rd_valid
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/fifo_rd_valid_int
add wave -noupdate -expand -label {Contributors: skid_valid} -group {Contributors: sim:/uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_valid} /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_data
add wave -noupdate /uart_rx_tb/uart_dut/g_uart_comps/uart_rx_i0/skid_buffer_rx/skid_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12311309410 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 500
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
WaveRestoreZoom {0 ps} {233504 ps}
