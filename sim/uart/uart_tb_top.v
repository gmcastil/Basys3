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

  logic         uart_clk;
  logic         uart_rst;

  assign uart_clk = sys_clk[0];
  assign uart_rst = sys_rst[0];

  // Establish the 100MHz external oscillator provided by the board
  initial begin
    clk_ext = 1'b0;
    forever begin
      #5ns;
      clk_ext = ~clk_ext;
    end
  end

  initial begin
    // Set the UART inputs to well-defined values (i.e., idle) before the power
    // on reset is dasserted
    uart_idle();

    // UART stimulus can start several clocks after reset is deasserted
    wait(uart_rst == 1'b0);
    repeat (10) @(posedge uart_clk);

    // Now we can start sending data
    uart_write_byte(8'h48);
    uart_write_byte(8'h47);

    // Let the simulation run until the UART is ready for more data
//    repeat (100) @(posedge uart_clk);
    wait(uart_wr_ready);
    $display("UART simulation complete");
    $finish;
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
    .clk              (uart_clk),       // in    std_logic;
    .rst              (uart_rst),       // in    std_logic;
    .uart_rd_data     (uart_rd_data),   // out   std_logic_vector(7 downto 0);
    .uart_rd_valid    (uart_rd_valid),  // out   std_logic;
    .uart_rd_ready    (uart_rd_ready),  // in    std_logic;
    .uart_wr_data     (uart_wr_data),   // in    std_logic_vector(7 downto 0);
    .uart_wr_valid    (uart_wr_valid),  // in    std_logic;
    .uart_wr_ready    (uart_wr_ready),  // out   std_logic;
    .uart_rxd         (uart_rxd),       // in    std_logic;
    .uart_txd         (uart_txd)        // out   std_logic
  );

  // Set UART inputs to quiescent states
  function void uart_idle();
    uart_wr_valid   = 1'b0;
    uart_wr_data    = 8'h0;

    uart_rd_ready   = 1'b0;

    uart_rxd        = 1'b1;
  endfunction

  // Write a byte to the UART input
  task automatic uart_write_byte(
    input   logic   [7:0]   wr_data
  );
    uart_wr_data    = wr_data;
    uart_wr_valid   = 1'b1;
    wait(uart_wr_valid && uart_wr_ready);
    @(posedge uart_clk);
    uart_wr_valid   = 1'b0;
  endtask

endmodule
