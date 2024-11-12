`timescale 1ns / 1ps

import uart_pkg::uart_bfm;

module uart_rx_tb #(
  parameter   string  SEND_FILE = "128b-random.bin",
  parameter   string  RECV_FILE = "128b-random-recv.bin"
) ();

  logic [7:0]   uart_rd_data;
  logic         uart_rd_valid;
  logic         uart_rd_ready;
  logic [7:0]   uart_wr_data;
  logic         uart_wr_valid;
  logic         uart_wr_ready;
  logic [1:0]   uart_mode;
  logic         uart_rxd;
  logic         uart_txd;

  logic         clk_100m00;
  logic         rst_100m00;

  logic         uart_clk;
  logic         uart_rst;
  logic         uart_ready;

  // Indicator that file has been sent to the UART
  logic         uart_capture_done;
  uart_bfm bfm;

  assign uart_clk = clk_100m00;
  assign uart_rst = rst_100m00;

  localparam integer RST_ASSERT_CNT = 10;

  // Create 100MHz clock and a synchronous reset
  initial begin
    clk_100m00 = 1'b0;
    forever begin
      #5ns;
      clk_100m00 = ~clk_100m00;
    end
  end

  initial begin
      rst_100m00 = 1'b0;
      @(posedge clk_100m00);
      rst_100m00 = 1'b1;
      repeat (RST_ASSERT_CNT) @(posedge clk_100m00);
      rst_100m00 = 1'b0;
  end

  // Sequence of events which resets the UART, configures the BFM, sends the
  // data file and then ends the test when it's been sent
  initial begin
    uart_rxd = 1'b1;
    uart_mode = 2'b00;
    uart_capture_done = 1'b0;

    uart_wr_valid = 1'b0;

    // To test the RX portion of the hardware, we use a UART BFM that supports
    // things like individual writes, entire files writing,
    bfm = new();

    // Wait until reset is deasserted
    @(negedge uart_rst);
    $display("UART reset complete");

    repeat (10) @(posedge uart_clk);

    // Now that the UART is done with reset (see note on ready and FIFO status)
    @(posedge uart_clk);

    $display("Sending %s to UART", SEND_FILE);
    bfm.send_file(SEND_FILE, uart_rxd);

    #1200us; 

    @(posedge uart_clk);
    uart_capture_done = 1'b1;
    @(posedge uart_clk);
    uart_capture_done = 1'b0;

    $display("Done");
    $finish();
  end

  data_capture #(
    .FILENAME         (RECV_FILE),
    .DATA_WIDTH       (8),
    .MODE             (`CAPTURE_READY_MODE),
    .ASSERT_CNT       (1),
    .DEASSERT_CNT     (1000)
  ) 
  data_capture_uart_rx (
    .clk              (uart_clk),
    .rst              (uart_rst),
    .data             (uart_rd_data),
    .valid            (uart_rd_valid),
    .ready            (uart_rd_ready),
    .done             (uart_capture_done)
  );

  uart #(
    .DEVICE           ("7SERIES"),
    .CLK_FREQ         (100000000),
    .BAUD_RATE        (115200),
    .UART_MODE        ("NORMAL")
  )
  uart_dut (
    .clk              (uart_clk),
    .rst              (uart_rst),
    .uart_ready       (uart_ready),
    .uart_rd_data     (uart_rd_data),
    .uart_rd_valid    (uart_rd_valid),
    .uart_rd_ready    (uart_rd_ready),
    .uart_wr_data     (uart_wr_data),
    .uart_wr_valid    (uart_wr_valid),
    .uart_wr_ready    (uart_wr_ready),
    .uart_rxd         (uart_rxd),
    .uart_txd         (uart_txd)
  );

endmodule

