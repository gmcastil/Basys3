`timescale 1ns / 1ps;

package uart_pkg;

// Bus functional model for a UART
class uart_bfm;

    int baud_rate;
    real baud_period;
    int start_bits;
    int data_bits;
    int parity_bits;
    int stop_bits;
    string parity;
    int verbose;

    // Initialize a new UART BFM object with the provided baud rate and framing
    function new(
        int baud_rate = 115200, int data_bits = 8, string parity = "none",
        int stop_bits = 1, int verbose = 0
    );

        // The baud rate for the BFM to use
        this.baud_rate = baud_rate;
        // How many start bits in a frame
        this.start_bits = 1;
        // How many data bits in a frame
        this.data_bits = data_bits;
        // How many stop bits in a frame
        this.stop_bits = stop_bits;
        // Even, odd, or none
        this.parity = parity;
        // Set the logging level
        this.verbose = verbose;

        // This will be used for both TX and RX functions, since the BFM has no
        // concept of a clock when sending and receiving data.
        this.baud_period = 1.0e9 / baud_rate;

        if (this.parity == "none") begin
            this.parity_bits = 0;
        end else begin
            this.parity_bits = 1;
        end

        if (this.verbose == 1) begin
            $display("UART BFM initialized with:");
            $display("Baud rate: %0d", this.baud_rate);
            $display("Baud tick: %0.3f ns", this.baud_period);
            $display("Start bits: %0d", this.start_bits);
            $display("Data bits: %0d", this.data_bits);
            $display("Parity: %s", this.parity);
            $display("Parity bits: %0d", this.parity_bits);
            $display("Stop bits: %0d", this.stop_bits);
        end

    endfunction

    // Send a single frame of data (usually a byte) with whatever additional bits
    // are required based on the UART configuration
    task send_frame(
        logic  [7:0]  tx_data,
        ref logic     txd
    );
        // Send start bits
        for (int i=0; i<this.start_bits; i++) begin
            txd = 1'b0;
            #(this.baud_period);
        end

        // Send data bits
        for (int i=0; i<this.data_bits; i++) begin
            txd = tx_data[i];
            #(this.baud_period);
        end

        // Send parity bits
        for (int i=0; i<this.parity_bits; i++) begin
            txd = set_parity(tx_data);
            #(this.baud_period);
        end

        // Send stop bits
        for (int i=0; i<this.stop_bits; i++) begin
            txd = 1'b1;
            #(this.baud_period);
        end
    endtask

    // Set the parity bit value for even or odd parity
    function bit set_parity(
        logic   [7:0]   data
    );
        if (this.parity == "even") begin
            set_parity = ^data;
        end else if (this.parity == "odd") begin
            set_parity = ~^data;
        end else begin
            $display("Invalid parity was provided");
        end
    endfunction

  endclass

endpackage
