`timescale 1ns / 1ps

module uart_tb_top ();

  logic [7:0]   uart_rd_data;
  logic         uart_rd_valid;
  logic         uart_rd_ready;
  logic [7:0]   uart_wr_data;
  logic         uart_wr_valid;
  logic         uart_wr_ready;
  logic         uart_rxd;
  logic         uart_txd;

  logic         clk_ext;
  logic         rst_ext;
  logic [5:0]   sys_clk;
  logic [5:0]   sys_rst;

  logic         clk_100m00;
  logic         rst_100m00;

  assign clk_100m00 = sys_clk[0];
  assign rst_100m00 = sys_rst[0];

  // Establish the 100MHz external oscillator provided by the board
  initial begin
    clk_ext = 1'b0;
    forever begin
      #5ns;
      clk_ext = ~clk_ext;
    end
  end

  // This can be either the synthesizable clock and reset module or a functional
  // model.  They should be equivalent but without needing to sim all of the
  // MMCM or PLL that get included later
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
    .clk              (clk_100m00),      // in    std_logic;
    .rst              (rst_100m00),      // in    std_logic;
    .uart_rd_data     (uart_rd_data),    // out   std_logic_vector(7 downto 0);
    .uart_rd_valid    (uart_rd_valid),   // out   std_logic;
    .uart_rd_ready    (uart_rd_ready),   // in    std_logic;
    .uart_wr_data     (uart_wr_data),    // in    std_logic_vector(7 downto 0);
    .uart_wr_valid    (uart_wr_valid),   // in    std_logic;
    .uart_wr_ready    (uart_wr_ready),   // out   std_logic;
    .uart_rxd         (uart_rxd),        // in    std_logic;
    .uart_txd         (uart_txd)         // out   std_logic
  );

endmodule
