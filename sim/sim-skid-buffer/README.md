To compile the simulation:
```bash
$ ./sim_skid_buffer
```
To run the simulation, call Questa with the appropriate `.do` file
```bash
$ vsim -c -do run_sim.do
```
The simulation writes 1024 random values to the FIFO and then reads them out
from the end of the skid buffer, while randomly asserting and deasserting the
ready signal.  Once all 1024 values have been written to the FIFO and read from
the skid buffer, the simulation ends and the two sets of data are compared. If
they are identical, then the simulation will indicate it passes, otherwise it
will indicate a failure.

Note that the `DO_REG` generic determines whether the FIFO is instantiated with
or without the additional pipeline register.  This can be modified in the DO
file by setting the `DO_REG` generic to a 1 or 0.

