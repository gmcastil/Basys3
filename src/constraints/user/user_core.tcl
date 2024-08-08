# NOTE: These are intended to be unmanaged contraints, which allows for more
# general Tcl language constructs (e.g., conditionals). They can be added (in
# project mode) via the `read_xdc -unmanaged user_core.tcl` command.

# Because PMOD connectors include ground and VCC pins, the pin numbering
# does not match the port numbering at the top level. It is the responsibility
# of the user to make sure that the pin number and ordering that is in the
# schematic for the board, the PMOD connector and the RTL match up as desired.

# PMOD label JA1
set_property PACKAGE_PIN J1 [get_ports {pmod_ja_pad[0]}]

# PMOD label JA2
set_property PACKAGE_PIN L2 [get_ports {pmod_ja_pad[1]}]

# PMOD label JA3
set_property PACKAGE_PIN J2 [get_ports {pmod_ja_pad[2]}]

# PMOD label JA4
set_property PACKAGE_PIN G2 [get_ports {pmod_ja_pad[3]}]

# PMOD label JA7
set_property PACKAGE_PIN H1 [get_ports {pmod_ja_pad[4]}]

# PMOD label JA8
set_property PACKAGE_PIN K2 [get_ports {pmod_ja_pad[5]}]

# PMOD label JA9
set_property PACKAGE_PIN H2 [get_ports {pmod_ja_pad[6]}]

# PMOD label JA10
set_property PACKAGE_PIN G3 [get_ports {pmod_ja_pad[7]}]

# PMOD connectors are all on the same IO bank
for {set i 0} {$i < 8} {incr i} {
    set_property IOSTANDARD LVCMOS33 [get_ports pmod_ja_pad[$i]]
}

