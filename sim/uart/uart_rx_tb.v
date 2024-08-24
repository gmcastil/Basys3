`timescale 1ns / 1ps;

import uart_pkg::uart_bfm;

module uart_rx_tb;

  logic [7:0]   uart_rd_data;
  logic         uart_rd_valid;
  logic         uart_rd_ready;
  logic [7:0]   uart_wr_data;
  logic         uart_wr_valid;
  logic         uart_wr_ready;
  logic [1:0]   uart_mode;
  logic         uart_rxd;
  logic         uart_txd;

  logic         clk_ext;
  logic         rst_ext;
  logic [5:0]   sys_clk;
  logic [5:0]   sys_rst;

  logic         clk_100m00;
  logic         rst_100m00;

  logic         uart_clk;
  logic         uart_rst;

  assign uart_clk = sys_clk[0];
  assign uart_rst = sys_rst[0];

  uart_bfm bfm;

  // Establish the 100MHz external oscillator provided by the board
  initial begin
    clk_ext = 1'b0;
    forever begin
      #5ns;
      clk_ext = ~clk_ext;
    end
  end

  initial begin
    // External reset is not asserted and the RXD is pulled high (powering up or
    // resetting the UART with something jabbering on the line is absolutely
    // a use case to test, but for now, stick to setting this to 1)
    rst_ext = 1'b0;
    uart_rxd = 1'b1;
    uart_mode = 2'b00;

    uart_rd_ready = 1'b0;
    uart_wr_valid = 1'b0;

    // To test the RX portion of the hardware, we use a UART BFM that supports
    // things like individual writes, entire files writing,
    bfm = new(.baud_rate(115200), .verbose(1));

    // Wait until reset is deasserted
    @(negedge uart_rst);
    $display("UART reset deasserted");
    // UART stimulus can start several clocks after reset is deasserted
    repeat (10) @(posedge uart_clk);

    bfm.send_frame(8'h10, uart_rxd);
    bfm.send_frame(8'h11, uart_rxd);
    bfm.send_frame(8'h12, uart_rxd);
    bfm.send_frame(8'h13, uart_rxd);

    $display("Done");
    $stop();
  end

  clk_rst #(
    .RST_LENGTH       (10),
    .NUM_CLOCKS       (6)
  )
  clk_rst_i0 (
    .clk_ext          (clk_ext),        // in    std_logic;
    .rst_ext          (rst_ext),        // in    std_logic;
    .sys_clk          (sys_clk),        // out   std_logic_vector((NUM_CLOCKS - 1) downto 0);
    .sys_rst          (sys_rst)         // out   std_logic_vector((NUM_CLOCKS - 1) downto 0)
  );

  uart #(
    .CLK_FREQ         (100000000),
    .BAUD_RATE        (115200)
  )
  uart_dut (
    .clk              (uart_clk),       // in    std_logic;
    .rst              (uart_rst),       // in    std_logic;
    .uart_rd_data     (uart_rd_data),   // out   std_logic_vector(7 downto 0);
    .uart_rd_valid    (uart_rd_valid),  // out   std_logic;
    .uart_rd_ready    (uart_rd_ready),  // in    std_logic;
    .uart_wr_data     (uart_wr_data),   // in    std_logic_vector(7 downto 0);
    .uart_wr_valid    (uart_wr_valid),  // in    std_logic;
    .uart_wr_ready    (uart_wr_ready),  // out   std_logic;
    .uart_mode        (uart_mode),      // in    std_logic_vector(1 downto 0);
    .uart_rxd         (uart_rxd),       // in    std_logic;
    .uart_txd         (uart_txd)        // out   std_logic
  );

endmodule

