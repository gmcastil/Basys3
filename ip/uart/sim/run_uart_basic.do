# Suppress warnings about problems reading symbols
vsim work.uart_tb_top +nowarn3116

set StdArithNoWarnings 1
set NumericStdNoWarnings 1

log -r \*
run -all

