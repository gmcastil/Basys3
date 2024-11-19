`timescale 1ns / 1ps

module skid_buffer_tb ();

    localparam int RST_ASSERT_CNT = 10;

    // FIFO signals
    logic fifo_wr_en;
    logic [7:0] fifo_wr_data;
    logic fifo_rd_en;
    logic [7:0] fifo_rd_data;
    logic fifo_ready;
    logic fifo_full;
    logic fifo_empty;

    // Skid buffer signals
    logic [7:0] rd_data;
    logic rd_valid;
    logic rd_ready;

    logic clk;
    logic rst;

    initial begin
      clk = 1'b0;
      forever begin
        #5ns;
        clk = ~clk;
      end
    end

    initial begin
        rst = 1'b0;
        @(posedge clk);
        rst = 1'b1;
        repeat (RST_ASSERT_CNT) @(posedge clk);
        rst = 1'b0;
    end

    logic read_done;
    logic write_done;

    byte write_bytes[$];
    byte read_bytes[$];

    localparam integer NUM_BYTES = 16;

    // Main body of testbench
    initial begin

        // Only have two control signals to drive here, one to read from the skid buffer and another
        // to write to the FIFO
        fifo_wr_en = 1'b0;
        rd_ready = 1'b0;

        write_done = 1'b0;
        read_done = 1'b0;

        @(negedge rst);
        wait(fifo_ready);
        $display("FIFO ready");
        // Let some clocks go by 
        repeat (20) @(posedge clk);

        // Spin off a process to read and store bytes in the received queue
        fork begin
            $display("Starting background reads from skid buffer");
            while(read_bytes.size != NUM_BYTES) begin
                // Store data when a read has occurred
                if ( (rd_valid == 1'b1) && (rd_ready == 1'b1) ) begin
                    read_bytes.push_back(rd_data);
                end
                // Randomly decide when to assert / deassert the read
                if ($urandom_range(0, 100) < 30) begin
                    rd_ready = 1'b0;
                end else begin
                    rd_ready = 1'b1;
                end
                @(posedge clk);
            end
            rd_ready = 1'b0;
            read_done = 1'b1;
        end join_none

        // Populate the write queue with random data
        fork begin
            int rand_int;
            $display("Starting background writes to FIFO");
            while (write_bytes.size != NUM_BYTES) begin
                if (fifo_full == 1'b0) begin
                    rand_int = $urandom();
                    // Taking the bottom 8 bits actually caused repeated bytes
                    fifo_wr_data = rand_int[8:1];
                    write_bytes.push_back(rand_int[8:1]);
                    fifo_wr_en = 1'b1;
                end else begin
                    fifo_wr_en = 1'b0;
                end
                @(posedge clk);
            end
            fifo_wr_en = 1'b0;
            write_done = 1'b1;
        end join_none

        wait(write_done && read_done);

        if (read_bytes == write_bytes) begin
            $display("Simulation PASS");
        end else begin
            $display("Simulation FAIL");
        end
        $display("Wrote %0d bytes", write_bytes.size);
        $display("Read  %0d bytes", read_bytes.size);

        $finish;
    end

    fifo_sync #(
        .DEVICE             ("7SERIES"),
        .FIFO_WIDTH         (8),
        .FIFO_SIZE          ("18Kb"),
        .FWFT               (0),
        .DO_REG             (0),
        .DEBUG              (0)
    ) fifo_inst (
        .clk                (clk),
        .rst                (rst),
        .wr_en              (fifo_wr_en),
        .wr_data            (fifo_wr_data),
        .rd_en              (fifo_rd_en),
        .rd_data            (fifo_rd_data),
        .ready              (fifo_ready),
        .full               (fifo_full),
        .empty              (fifo_empty)
    );

    skid_buffer #(
        .DATA_WIDTH         (8)
    ) skid_inst (
        .clk                (clk),
        .rst                (rst),
        .fifo_rd_data       (fifo_rd_data),
        .fifo_rd_en         (fifo_rd_en),
        .fifo_full          (fifo_full),
        .fifo_empty         (fifo_empty),
        .fifo_ready         (fifo_ready),
        .rd_data            (rd_data),
        .rd_valid           (rd_valid),
        .rd_ready           (rd_ready)
    );

endmodule

