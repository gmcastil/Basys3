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

