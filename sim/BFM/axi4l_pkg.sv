package axi4l_pkg;

    // AXI4-Lite read and write response types
    typedef enum logic [1:0] {
        RESP_OKAY       = 2'b00,    // Transaction completed successfully
        RESP_EXOKAY     = 2'b01,    // Exclusvie access successful
        RESP_SLVERR     = 2'b10,    // Slave error
        RESP_DECERR     = 2'b11     // Decode error
    } axi4l_resp_t;

    typedef enum {
        AXI4L_READ,
        AXI4L_WRITE
    } txn_type_t;

    class axi4l_txn #(
        parameter   int ADDR_WIDTH  = 32,
        parameter   int DATA_WIDTH  = 32
    );

        logic [ADDR_WIDTH-1:0] addr;
        logic [DATA_WIDTH-1:0] data;
        axi4l_resp_t resp;
        txn_type_t kind;
        int index;

        function new(logic [ADDR_WIDTH-1:0] addr, txn_type_t kind);
            this.addr = addr;
            this.kind = kind;
            if (this.kind == AXI4L_WRITE) begin
                this.data = $random;
            end
        endfunction

       function void display();

           if (this.kind == AXI4L_READ) begin
               if (ADDR_WIDTH == 32) begin
                   $display("Read Addr: 0x%08h", this.addr);
               end else if (ADDR_WIDTH == 64) begin
                   $display("Read Addr: 0x%08h_%08h", this.addr[63:32], this.addr[31:0]);
               end else begin
                   $display("Read Addr: 0x%h", this.addr);
               end

               if (DATA_WIDTH == 32) begin
                   $display("Read Data: 0x%08h", this.data);
               end else if (DATA_WIDTH == 64) begin
                   $display("Read Data: 0x%08h_08h", this.data[63:32], this.data[31:0]);
               end else begin
                   $display("Read Data: 0x%h", this.data);
               end
               $display("Read Resp: %s", resp.name());
               $display("Read Index: %d", this.index);

            end else begin

                $display("Write Addr: 0x%08h", this.addr);
                $display("Write Datta: 0x%08h", this.data);
                $display("Write Resp: %s", resp.name());

            end

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

        axi4l_txn #(ADDR_WIDTH, DATA_WIDTH) txn_history[$];

        // Master BFM constructor
        function new(virtual axi4l_if vif);

            // Initialize instance variables
            this.vif = vif;

            // Each read and write task gets it own semaphore to lock
            // access to the read or write portion of the bus.
            sem_wr = new(1);
            sem_rd = new(1);

            // AXI4-Lite master needs to see a reset before it can service reads or writes
            fork monitor_reset(); join_none

        endfunction

        // Perform an AXI4-Lite write transaction
        /* task write(axi4l_txn wr_txn); */

        /*     if (this.vif.arstn == 1'b0) begin */
        /*         $display("Write ignored while in reset"); */
        /*         return; */
        /*     end */

        /*     sem_wr.get(); */
        /*     this.vif.awvalid = 1'b1; */
        /*     this.vif.awaddr = wr_txn.awaddr; */
        /*     this.vif.wvalid = 1'b1; */
        /*     this.vif.wdata = wr_txn.wdata; */
        /*     this.vif.wstrb = wr_txn.wstrb; */

        /*     sem_wr.put(); */
        /* endtask */

        // Perform and AXI4-Lite read transaction
        task read(axi4l_txn rd_txn);

            // Total number of read transactions (used as index for read transaction results)
            static int rd_count = 0;

            event raddr_done;

            if (this.vif.arstn == 1'b0) begin
                $display("Read ignored while in reset");
                return;
            end

            sem_rd.get();

            // Background two processes, one to wait for the address phase to be complete and signal
            // to the other to wait for the data phase to be complete
            fork
                // Read address accepted phase
                begin
                    // Assert that we have a valid address and block until ready and valid are true
                    this.vif.araddr = rd_txn.addr;
                    this.vif.arvalid = 1'b1;
                    @(this.vif.cb.arready);
                    this.vif.arvalid = 1'b0;
                    ->raddr_done;
                end
                begin
                    // Once the event has fired, we can capture the data
                    @raddr_done;

                    // Assert that we are ready for data and block until valid and ready are true
                    this.vif.rready = 1'b1;
                    @(this.vif.cb.rvalid);
                    rd_txn.data = this.vif.rdata;
                    rd_txn.resp = axi4l_resp_t'(this.vif.rresp);
                    this.vif.rready = 1'b0;
                end
            // Require that both of these tasks complete before rejoining the main thread
            join
            rd_txn.index = rd_count++;
            this.txn_history.push_back(rd_txn);

            sem_rd.put();
        endtask

        task write(axi4l_txn wr_txn);

            // Total number of write transactions (used as index for write transaction results)
            static int wr_count = 0;

            bit wdata_done;
            bit waddr_done;
            event wr_done;

            sem_wr.get();

            fork
                // Write address accepted phase
                begin
                    this.vif.awaddr = wr_txn.addr;
                    this.vif.awvalid = 1'b1;
                    @(this.vif.cb.awready);
                    this.vif.awvalid = 1'b0;
                    waddr_done = 1'b1; 
                end
                // Write data accepted phase
                begin
                    this.vif.wdata = wr_txn.data;
                    this.vif.wvalid = 1'b1;
                    this.vif.wstrb = 4'hF;
                    @(this.vif.cb.wready);
                    this.vif.wvalid = 1'b0;
                    wdata_done = 1'b1;
                end
            // Wait for both phases to complete
            join

            wait(waddr_done && wdata_done);

            // Response phase
            this.vif.bready = 1'b1;
            @(this.vif.cb.bvalid);
            wr_txn.resp = axi4l_resp_t'(this.vif.cb.bresp);
            this.vif.bready = 1'b0;

            wr_txn.index = wr_count++;
            this.txn_history.push_back(wr_txn);

            sem_wr.put();

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
                    $display("AXI4-Lite master reset deasserted");
                end
            end
        endtask

    endclass
endpackage
