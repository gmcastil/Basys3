# UART register definitions
set uart_offset 0x00000000
set uart_control_reg 0x00
set uart_mode_reg 0x004
set uart_status_reg 0x08
set uart_scratch_reg 0x24

# Read and write scratch register

# Write a UART register and check the response
proc uart_write_reg {uart_reg val} {
    set wr_addr [expr { "${uart_offset}" + "${uart_reg}" }]
    set wr_addr [format 0x%x "${wr_addr}"]
    puts "${wr_addr}"

    # Reset the JTAG to AXI core so that it has a well-defined state
    set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
    reset_hw_axi ${jtag_axi_core}

    # Create a new JTAG to AXI write transaction and run it (we force it to
    # overwrite any existing ones)
    create_hw_axi_txn \
        -force \
        -type WRITE \
        -address "${wr_addr}" \
        -len 1 \
        -data "${val}" \
        wr_txn "${jtag_axi_core}"
    run_hw_axi -quiet [get_hw_axi_txns wr_txn]

    # And then check the result
    set bresp [get_property STATUS.BRESP  "${jtag_axi_core}"]
    if {"${bresp}" != "OKAY"} {
        puts "Error: Write response received ${bresp}"
    }
}

    set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
# Reset the JTAG to AXI core so that it has a well-defined state
reset_hw_axi ${jtag_axi_core}

create_hw_axi_txn \
    -force \
    -type WRITE \
    -address "${addr}" \
    -len 1 \
    -data 0xdeadbeef \
    wr_txn "${jtag_axi_core}"
run_hw_axi -quiet [get_hw_axi_txns wr_txn]

set bresp [get_property STATUS.BRESP  "${jtag_axi_core}"]
if {"${bresp}" != "OKAY"} {
    puts "Error: Write response received ${bresp}"
}

create_hw_axi_txn \
    -force \
    -address "${addr}" \
    -type READ \
    rd_txn "${jtag_axi_core}"

run_hw_axi -quiet [get_hw_axi_txns rd_txn]
set rresp [get_property STATUS.RRESP  "${jtag_axi_core}"]
if {"${rresp}" != "OKAY"} {
    puts "Error: Read response received ${rresp}"
}

create_hw_axi_txn \
    -force \
    -address [expr "${uart_offset}" + "${uart_mode_reg}"] \
    -type WRITE \
    -len 1 \
    -data 0xffffffff \
    wr_txn "${jtag_axi_core}"
run_hw_axi -quiet [get_hw_axi_txns wr_txn]
set bresp [get_property STATUS.BRESP  "${jtag_axi_core}"]
if {"${bresp}" != "OKAY"} {
    puts "Error: Write response received ${bresp}"
}

