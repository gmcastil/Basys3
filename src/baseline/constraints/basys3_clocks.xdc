# Identify the external 100MHz clock provided by the DSC1033CC1-100.0000T
# oscillator
create_clock -period 10.000 -name clk_ext -waveform {0.000 5.000} -add [get_ports clk_ext_pad]


