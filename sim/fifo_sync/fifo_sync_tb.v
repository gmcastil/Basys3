`timescale 1ns / 1ps

module fifo_sync_tb;

    // Parameters for the FIFO
    localparam DATA_WIDTH = 8;  // Assuming FIFO_WIDTH is 8-bits
    localparam FIFO_DEPTH = 256;  // Number of words the FIFO can store

    // Testbench signals
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] wr_data;
    wire [DATA_WIDTH-1:0] rd_data;
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
        write_to_fifo(8'hA5);
        write_to_fifo(8'h3C);
        write_to_fifo(8'h7E);

        // Read data from the FIFO
        #30;
        read_from_fifo();
        read_from_fifo();
        read_from_fifo();

        #50;
        $stop;
    end

    // Task to write data to the FIFO
    task write_to_fifo(input [DATA_WIDTH-1:0] data);
        begin
            @(posedge clk);
            wr_data = data;
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
      .DEVICE		    ("7SERIES"),
      .FIFO_WIDTH		(8),
      .FIFO_SIZE		("18Kb"),
      .DO_REG		    (0)
  ) uut 		(
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

