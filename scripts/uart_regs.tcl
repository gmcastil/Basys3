# UART register definitions
set UART_OFFSET 0x80000000
set UART_CONTROL_REG 0x00
set UART_MODE_REG 0x004
set UART_STATUS_REG 0x08
set UART_SCRATCH_REG 0x24

# Dump out the properties of a specific JTAG to AXI core
proc display_hw_axi_properties {jtag_axi_core} {
    set properties [list_property "${jtag_axi_core}"]

    puts "== JTAG to AXI Core =="
    foreach prop "${properties}" {
        set value [get_property "${prop}" "${jtag_axi_core}"]
        puts [format "%-30s %s" "${prop}" "${value}"] 
    }
}

# Write a UART register and check the response. Returns nothing.
proc uart_write_reg {reg val} {
    global UART_OFFSET
    set wr_addr [expr { "${UART_OFFSET}" + "${reg}" }]
    # This extra format step is required because the command that creates the
    # hardware transaction assumes addresses are in a hexadecimal format
    set wr_addr [format 0x%x "${wr_addr}"]

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
        error "${bresp}"
    }
}

# Read a UART register and check the response. Returns 32-bit read value in hex.
proc uart_read_reg {reg} {
    global UART_OFFSET
    set rd_addr [expr { "${UART_OFFSET}" + "${reg}" }]
    # This extra format step is required because the command that creates the
    # hardware transaction assumes addresses are in a hexadecimal format
    set rd_addr [format 0x%x "${rd_addr}"]

    # Reset the JTAG to AXI core so that it has a well-defined state
    set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
    reset_hw_axi ${jtag_axi_core}

    # Create a new JTAG to AXI write transaction and run it (we force it to
    # overwrite any existing ones)
    create_hw_axi_txn \
        -force \
        -type READ \
        -address "${rd_addr}" \
        -len 1 \
        rd_txn "${jtag_axi_core}"
    run_hw_axi -quiet [get_hw_axi_txns rd_txn]

    set rresp [get_property STATUS.RRESP "${jtag_axi_core}"]
    if {"${rresp}" != "OKAY"} {
        error "rresp"
    } else {
        # Vivado returns this implicitly as a hex value, so we prepend 0x to it
        return 0x[get_property DATA [get_hw_axi_txns rd_txn]]
    }
}

# Check JTAG to AXI master status before getting started
set jtag_axi_core [get_hw_axis -of_objects [current_hw_device]]
display_hw_axi_properties "${jtag_axi_core}"

# Check scratch register
set wr_data 0x12341234
uart_write_reg "${UART_SCRATCH_REG}" "${wr_data}"
set rd_data [uart_read_reg "${UART_SCRATCH_REG}"]
if {"${wr_data}" != "${rd_data}"} {
    puts "Error: Failed to write scratch register. Expected ${wr_data} but received ${rd_data}"
}


