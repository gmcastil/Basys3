# Indent and Formatting
Port definitions for a module or its instantiations should only use one port per
line, with the columns aligned and separated by whitespace. Interfaces may group
all inputs and outputs together in single lines such as
```systemverilog
    clocking cb @(posedge clk);
        input   awready, wready, bvalid, arready, rvalid, rdata, bresp, rresp;
        output  awaddr, awvalid, wdata, wstrb, wvalid, bready, araddr, arvalid, rready;
    endclocking
```
This allows even large interface definitions to fit on a single page and
facilitates setting up things like master and slave modports.  Signal
definitions in the interface should still follow the same guideline of one
signal definition per line.
# SystemVerilog
## Interfaces

