RTL_DIR		:= ..
UART_DIR	:= .

UART_WORK	:= work

uart: work
	vcom -lint -work $(UART_WORK) -2008 $(RTL_DIR)/axi4l_regs.vhd
	vcom -lint -work $(UART_WORK) -2008 $(RTL_DIR)/reg_block.vhd
	vcom -lint -work $(UART_WORK) -2008 $(UART_DIR)/uart_reg_map.vhd
	vcom -lint -work $(UART_WORK) -2008 $(UART_DIR)/uart_core.vhd
	vcom -lint -work $(UART_WORK) -2008 $(UART_DIR)/uart_top.vhd

work:
	rm -rf $(UART_WORK)
	vlib $(UART_WORK)

