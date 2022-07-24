Configuration Modes
===================
There are three mode pins on the FPGA that are used to determine the method for
obtaining and loading the bitstream (see UG470 for details).  The Digilent
Basys3 board pulls M[0] high through a 1k resistor, which limits the supported
boot options to JTAG, serial SPI (which the TRM refers to as USB host
programming), or from flash memory.

Configuration Clock (CCLK)
--------------------------
The nature of the configuration clock (CCLK) depends upon the programming mode
that is selected.  The 7-Series Configuration User Guide (UG470), particularly
Table 2-1, goes into much greater detail.  The end result, from a user
perspective is that accessing the flash memory from user logic requires
instantiating the STARTUPE2 primitive.  It may even limit the programming
options (e.g., not immediately clear to me yet if JTAG programming mode shuts of
the internal oscillator that is used to generate the CCLK signal).

Accessing Flash Memory
----------------------
There is definitely some work to be done here with a user core application of
some sort that accesses flash memory and then explores the various configuration
options available.

