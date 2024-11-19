#!/bin/bash

# Prints a user-provided error message to stderr
err() {
    local msg
    msg="${1}"
    printf 'Error: %s\n' "${msg}" >&2
}

# Returns zero if ModelSim executables are found in the current PATH, else non-zero
check_modelsim() {
    command -v vlib >/dev/null 2>&1 || return 1
    command -v vsim >/dev/null 2>&1 || return 1
    command -v vlog >/dev/null 2>&1 || return 1
    command -v vcom >/dev/null 2>&1 || return 1
    command -v vopt >/dev/null 2>&1 || return 1
}

check_vivado() {
    command -v vivado >/dev/null 2>&1 || return 1
}

# COuld do other things here as well, like define useful helpful functions that
# do things like show / verify the files that are in a file list or something
# liek that
# show_sim_setup_status() {
# 
# }

if ! check_modelsim; then
    err "Could not find ModelSim tools in current PATH"
    return 1
fi

# Constant locations for source code
rtl_dir="../../rtl"
ip_dir="../../.."
tools_dir="${TOOLS_ROOT:-"/tools"}"

# Establish Xilinx simulation library locations and export the appropriate
# enviornment variable so that the modelsim.ini file can find things like the
# UNISIM and XPM libraries
questa_version="22.2"
sim_version="questa_fe"
vivado_version="2024.1"

# Xilinx libraries need to be available ---------------
#
# If the caller never set this, we craft it ourself based on the tool versions
# we defined earlier
if [[ -z "${XILINX_SIMLIB_DIR+set}" ]]; then
    XILINX_SIMLIB_DIR="${tools_dir}/lib/${vivado_version}/${sim_version}/${questa_version}"
fi
# Could get a bit more granular and verify that the libraries we want to
# compile against actually exist here
if [[ ! -d "${XILINX_SIMLIB_DIR}" ]]; then
    err "Directory ${XILINX_SIMLIB_DIR} does not exist"
    return 1
fi

# Location of Xilinx wrapper code (e.g., FIFO_SYNC_MACRO replacements)
macros_dir="${XILINX_MACROS_DIR:-"${ip_dir}/macros"}"
if [[ ! -d "${macros_dir}" ]]; then
    err "Macros directory ${macros_dir} does not exist."
    return 1
fi

# Assume that all simulations will use the same modelsim.ini file. If a
# simulation needs to override settings in this one, it can create its own
# locally and then just override this setting.
MODELSIM="../modelsim.ini"
if [[ ! -f "${MODELSIM}" ]]; then
    err "Could not locate modelsim.ini file"
    return 1
fi

# Check that modelsim.ini exists now
export XILINX_SIMLIB_DIR
export MODELSIM

# printf 'Using Xilinx simulation libraries at %s\n' "${XILINX_SIMLIB_DIR}"
# Actualy, these displays should all just be a function ad then the claler is
# free to call it themselves. Sourcing this script should just return an error
# value
#
# Display the XILINX library maps
# Display the tools version that are going to get used
# Displays that are going to get used
#
