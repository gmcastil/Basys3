BFM_DIR		:= ../BFM
IF_DIR		:= ../interfaces
RTL_DIR		:= ../../src/baseline/rtl
TB_DIR		:= ./

TB_WORK		:= work
DUT_WORK	:= work

all: tb dut

tb: work
	vlog -work $(TB_WORK) -sv $(IF_DIR)/axi4l_if.sv
	vlog -work $(TB_WORK) -sv $(BFM_DIR)/axi4l_pkg.sv
	vlog -work $(TB_WORK) -sv $(TB_DIR)/axi4l_regs_tb.sv

dut: work
	vcom -lint -work $(DUT_WORK) -2008 $(RTL_DIR)/axi4l_regs.vhd
	vcom -lint -work $(DUT_WORK) -2008 $(RTL_DIR)/reg_block.vhd

work:
	rm -rf work
	vlib work

