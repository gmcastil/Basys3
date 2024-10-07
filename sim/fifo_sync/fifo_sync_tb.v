`timescale 1ns / 1ps

module fifo_sync_tb #(
  parameter string  DEVICE      = "7SERIES",
  parameter integer FIFO_WIDTH  = 72,
  parameter string  FIFO_SIZE   = "36Kb",
  parameter integer DO_REG      = 1,
  parameter integer DEBUG       = 0
);

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [FIFO_WIDTH-1:0] wr_data;
    wire [FIFO_WIDTH-1:0] rd_data;
    wire full;
    wire empty;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock (10 ns period)
    end

    // Reset generation
    initial begin
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        rst = 0;  // Deassert reset after 20 ns
    end

    // Test stimulus
    initial begin
        // Initialize control signals
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;

        // Wait for reset to deassert
        @(negedge rst);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // Write data into the FIFO
        write_to_fifo;
        write_to_fifo;
        write_to_fifo;

        // Read data from the FIFO
        #30;
        read_from_fifo();
        read_from_fifo();
        read_from_fifo();

        #50;
        $stop;
    end

    // Task to write data to the FIFO
    task write_to_fifo;
      // Use 96 bits and then slice it down to whatever the FIFO_WIDTH is
      reg [95:0] random_data;
        begin
            random_data[95:64] = $random;
            random_data[63:32] = $random;
            random_data[31:0]  = $random;
            @(posedge clk);
            wr_data = random_data[FIFO_WIDTH-1:0];
            wr_en = 1;
            @(posedge clk);
            wr_en = 0;
        end
    endtask

    // Task to read data from the FIFO
    task read_from_fifo();
        begin
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
        end
    endtask

  // Instantiate the FIFO Sync Module
  fifo_sync #(
      .DEVICE		    (DEVICE),
      .FIFO_WIDTH		(FIFO_WIDTH),
      .FIFO_SIZE		(FIFO_SIZE),
      .DO_REG		    (DO_REG),
      .DEBUG        (DEBUG)
  )
  fifo_sync_i0 (
      .clk		      (clk),
      .rst		      (rst),
      .wr_en		    (wr_en),
      .wr_data		  (wr_data),
      .rd_en		    (rd_en),
      .rd_data		  (rd_data),
      .ready		    (ready),
      .full		      (full),
      .empty		    (empty)
  );

endmodule

