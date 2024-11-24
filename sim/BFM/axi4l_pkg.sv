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

    class m_axi4l_bfm;

        virtual axi4l_if vif;
        bit rst_active;

        // Master BFM constructor
        function new(virtual axi4l_if vif);
            this.vif = vif;
            // AXI4-Lite master needs to see a reset before it can service reads or writes
            this.rst_active = 0;
            fork
                monitor_reset();
            join_none
        endfunction

        // Perform and AXI4-Lite write transaction
        task write(ref axi4l_write_t txn);
            // Can check for reset here
        endtask

        // Perform and AXI4-Lite read transaction
        task read(ref axi4l_read_t txn);
            // Can check for reset here
        endtask

        task monitor_reset();
            forever begin
                @(this.vif.cb);
                if (this.vif.axi4l_arstn == 0) begin
                    this.vif.awvalid = 1'b0;
                    this.vif.wvalid = 1'b0;
                    this.vif.bready = 1'b0;
                    this.vif.arvalid = 1'b0;
                    this.vif.rready = 1'b0;
                    @(posedge vif.axi4l_arstn);
                    this.rst_active = 0;
                    $display(`ANSI_GREEN, "AXI4-Lite master reset deasserted", `ANSI_RESET);
                end
            end
        endtask

    endclass

endpackage
