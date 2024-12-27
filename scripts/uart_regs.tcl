# UART register definitions
set uart_offset 0x80000000
set uart_control_reg 0x80000004
set uart_mode_reg 0x80000004
set uart_scratch_reg 0x80000020

# Read and write scratch register
set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]

create_hw_axi_txn \
    -force \
    -address ${uart_scratch_reg} \
    -type WRITE \
    -len 1 \
    -data 0xdeadbeef \
    wr_txn "${jtag_axi_core}"

run_hw_axi [get_hw_axi_txns wr_txn]

create_hw_axi_txn \
    -force \
    -address ${uart_scratch_reg} \
    -type READ \
    rd_txn "${jtag_axi_core}"

run_hw_axi [get_hw_axi_txns rd_txn]

