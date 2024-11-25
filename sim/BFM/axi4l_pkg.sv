`define ANSI_GREEN "\033[32m"
`define ANSI_RESET "\033[0m"

package axi4l_pkg;

    // AXI4-Lite read and write response types
    typedef enum logic [1:0] {
        RESP_OKAY       = 2'b00,    // Transaction completed successfully
        RESP_EXOKAY     = 2'b01,    // Exclusvie access successful
        RESP_SLVERR     = 2'b10,    // Slave error
        RESP_DECERR     = 2'b11     // Decode error
    } axi4l_resp_t;

    // AXI4-Lite read or write transactions
    class axi4l_txn #(
        parameter   int ADDR_WIDTH  = 32,
        parameter   int DATA_WIDTH  = 32
    );

        function new();

        endfunction

    endclass

    /* AXI4-Lite bus-functional model */
    class m_axi4l_bfm;

        virtual axi4l_if vif;
        bit rst_active;

        semaphore sem_wr;
        semaphore sem_rd;

        // Master BFM constructor
        function new(virtual axi4l_if vif);
            this.vif = vif;
            // AXI4-Lite master needs to see a reset before it can service reads or writes
            fork monitor_reset(); join_none
            // Each read and write task gets it own semaphore to lock access
            // to the read or write portion of the bus
            sem_wr = new(1);
            sem_rd = new(1);
        endfunction

        // Perform and AXI4-Lite write transaction
        task write(ref axi4l_txn wr_txn);
            static int wr_count = 0;
            // Can check for reset here
            sem_wr.get();
            $display("Obtained AXI4-Lite write access");
            wr_count++;
            sem_wr.put();
            $display("Write count: %0d", wr_count);
        endtask

        // Perform and AXI4-Lite read transaction
        task read(axi4l_txn rd_txn);
            static int rd_count = 0;
            // Can check for reset here
            sem_rd.get();
            $display("Obtained AXI4-Lite read access");
            rd_count++;
            sem_rd.put();
            $display("Read count: %0d", rd_count);
        endtask

        task monitor_reset();
            // Start off in an uninitialized state
            this.rst_active = 0;
            forever begin
                @(this.vif.cb);
                if (this.vif.axi4l_arstn == 0) begin
                    this.vif.awvalid = 1'b0;
                    this.vif.wvalid = 1'b0;
                    this.vif.bready = 1'b0;
                    this.vif.arvalid = 1'b0;
                    this.vif.rready = 1'b0;
                    // Wait for reset to deassert
                    @(posedge vif.axi4l_arstn);
                    this.rst_active = 0;
                    $display(`ANSI_GREEN, "AXI4-Lite master reset deasserted", `ANSI_RESET);
                end
            end
        endtask

    endclass

endpackage
