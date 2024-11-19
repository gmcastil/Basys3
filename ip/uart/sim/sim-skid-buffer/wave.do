onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /skid_buffer_tb/clk
add wave -noupdate /skid_buffer_tb/rst
add wave -noupdate /skid_buffer_tb/fifo_wr_en
add wave -noupdate /skid_buffer_tb/fifo_wr_data
add wave -noupdate /skid_buffer_tb/rd_data
add wave -noupdate /skid_buffer_tb/rd_valid
add wave -noupdate /skid_buffer_tb/rd_ready
add wave -noupdate -divider {Skid Buffer}
add wave -noupdate /skid_buffer_tb/skid_inst/clk
add wave -noupdate /skid_buffer_tb/skid_inst/rst
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_ready
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_full
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_empty
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_rd_en
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_rd_valid_int
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_rd_valid
add wave -noupdate /skid_buffer_tb/skid_inst/fifo_rd_data
add wave -noupdate /skid_buffer_tb/skid_inst/skid_valid
add wave -noupdate /skid_buffer_tb/skid_inst/skid_data
add wave -noupdate /skid_buffer_tb/skid_inst/rd_data
add wave -noupdate /skid_buffer_tb/skid_inst/rd_valid
add wave -noupdate /skid_buffer_tb/skid_inst/rd_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {800182 ps} 0}
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
WaveRestoreZoom {200560 ps} {983697 ps}
