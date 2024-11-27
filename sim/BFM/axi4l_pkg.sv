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

    // AXI4-Lite read transaction
    class axi4l_rd_txn #(
        parameter   int ADDR_WIDTH  = 32,
        parameter   int DATA_WIDTH  = 32
    );

        logic [ADDR_WIDTH-1:0] araddr;
        logic [DATA_WIDTH-1:0] rdata;
        axi4l_resp_t rresp;

        function new(logic [ADDR_WIDTH-1:0] araddr);
            this.araddr = araddr;
        endfunction

    endclass

    // AXI4-Lite write transaction
    class axi4l_wr_txn #(
        parameter   int ADDR_WIDTH  = 32,
        parameter   int DATA_WIDTH  = 32
    );
        
        logic [ADDR_WIDTH-1:0] awaddr;
        logic [DATA_WIDTH-1:0] wdata;
        logic [(DATA_WIDTH/8)-1:0] wstrb;
        axi4l_resp_t wr_resp;

        function new(logic [ADDR_WIDTH-1:0] awaddr, logic [DATA_WIDTH-1:0] wdata, logic [(DATA_WIDTH/8)-1:0] wstrb);
            this.awaddr = awaddr;
            this.wdata = wdata;
            this.wstrb = wstrb;
        endfunction

    endclass

    /* AXI4-Lite bus-functional model */
    class m_axi4l_bfm #(
        parameter   int ADDR_WIDTH  = 32,
        parameter   int DATA_WIDTH  = 32
    );

        virtual axi4l_if vif;
        bit rst_active;

        semaphore sem_wr;
        semaphore sem_rd;

        integer wr_count;
        integer rd_count;

        // Master BFM constructor
        function new(virtual axi4l_if vif);

            // Initialize instance variables
            this.vif = vif;
            this.wr_count = 0;
            this.rd_count = 0;

            // Each read and write task gets it own semaphore to lock access
            // to the read or write portion of the bus.
            sem_wr = new(1);
            sem_rd = new(1);

            // AXI4-Lite master needs to see a reset before it can service reads or writes
            fork monitor_reset(); join_none

        endfunction

        // Perform an AXI4-Lite write transaction
        task write(axi4l_wr_txn wr_txn);

            if (this.vif.arstn == 1'b0) begin
                $display("Write ignored while in reset");
                return;
            end

            sem_wr.get();
            this.vif.awvalid = 1'b1;
            this.vif.awaddr = wr_txn.awaddr;
            this.vif.wvalid = 1'b1;
            this.vif.wdata = wr_txn.wdata;
            this.vif.wstrb = wr_txn.wstrb;

            this.wr_count++;
            sem_wr.put();
            $display("Write count: %0d", wr_count);
        endtask

        // Perform and AXI4-Lite read transaction
        task read(axi4l_rd_txn rd_txn);

            if (this.vif.arstn == 1'b0) begin
                $display("Read ignored while in reset");
                return;
            end

            sem_rd.get();
            this.vif.arvalid = 1'b1;
            this.vif.araddr = rd_txn.araddr;
            sem_rd.put();
            $display("Read count: %0d", rd_count);
        endtask

        task monitor_reset();
            // Start off in an uninitialized state
            this.rst_active = 0;
            forever begin
                @(this.vif.cb);
                if (this.vif.arstn == 0) begin
                    this.vif.awvalid = 1'b0;
                    this.vif.wvalid = 1'b0;
                    this.vif.bready = 1'b0;
                    this.vif.arvalid = 1'b0;
                    this.vif.rready = 1'b0;
                    // Wait for reset to deassert
                    @(posedge vif.arstn);
                    this.rst_active = 0;
                    $display(`ANSI_GREEN, "AXI4-Lite master reset deasserted", `ANSI_RESET);
                end
            end
        endtask

    endclass

endpackage
