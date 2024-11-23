# Simulation
Each testbench is contained in its own directory and responsible for its own
setup and configuration.  A great deal of commonality exists between simulations
and it is expected that most simulations will be setup by sourcing a
configuration script in `sim/common` and reference the `sim/modelsim.ini`.
Configuration settings can be overriden or neglected entirely and different
simulator configuration files can be specified by exporting the `MODELSIM`
environment variable.

