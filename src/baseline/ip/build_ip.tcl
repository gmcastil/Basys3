# Generates Xilinx IP as XCI files from Tcl scripts

# Identify the location that IP will be placed when completed

set ip_dir "ip"
set part "xc7a35tcpg236-1"

set build_ip_names {"uart_core_ila"}

foreach ip_name "${build_ip_names}" {
    source "${ip_name}.tcl"
}
