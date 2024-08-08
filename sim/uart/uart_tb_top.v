module uart_tb_top ();

  logic         clk;
  logic         rst;
  logic [7:0]   uart_rd_data;
  logic         uart_rd_valid;
  logic         uart_rd_ready;
  logic [7:0]   uart_wr_data;
  logic         uart_wr_valid;
  logic         uart_wr_ready;
  logic         uart_rxd;
  logic         uart_txd;

  uart #(
    .CLK_FREQ         (100000000),
    .BAUD_RATE        (115200)
  )
  uart_dut (
    .clk              (clk),             // in    std_logic;
    .rst              (rst),             // in    std_logic;
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
