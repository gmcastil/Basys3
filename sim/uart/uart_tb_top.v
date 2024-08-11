`timescale 1ns / 1ps

module uart_tb_top ();

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

  string str = "Hello, world";

  // Put the UART in normal mode for simulation and then short the TXD output to
  // the RXD input. UART doesn't need to know about simulation mode (unlike
  // hardware loopback, that shorts the control interface togethe)
  assign uart_mode = 2'b00;
  assign uart_rxd = uart_txd;

  // Establish the 100MHz external oscillator provided by the board
  initial begin
    clk_ext = 1'b0;
    forever begin
      #5ns;
      clk_ext = ~clk_ext;
    end
  end

  // TX simulation
  initial begin
    // Set the TX UART inputs to well-defined values (i.e., idle) before the power
    // on reset is dasserted
    uart_wr_valid = 1'b0;
    uart_wr_data = 8'h0;

    // Wait until reset is deasserted
    @(negedge uart_rst);
    // UART stimulus can start several clocks after reset is deasserted
    repeat (10) @(posedge uart_clk);

    // Now we can send data
    for (int i=0; i<str.len(); i++) begin
      uart_write_byte(str.getc(i));
    end

    // The TX UART takes a long time to finish, so we just use a wait statement
    // at the very end until its ready for data (that we aren't going to send it)
    wait(uart_wr_ready == 1'b1);
    $display("UART TX simulation complete");
    $finish;
  end

  // RX simulation
  initial begin
    uart_rd_ready = 1'b1;
  end 

  // Dump what is read from the output
  always @(posedge uart_clk) begin
    if (uart_rd_valid == 1'b1 && uart_rd_ready == 1'b1) begin
      $display("Read: %c", uart_rd_data);
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

  // Write a byte to the UART input
  task automatic uart_write_byte(
    input   logic   [7:0]   wr_data
  );

    @(posedge uart_clk) begin
      uart_wr_data    <= wr_data;
      uart_wr_valid   <= 1'b1;
    end

    @(posedge uart_clk);
    while (uart_wr_valid == 1'b1) begin
      if (uart_wr_valid == 1'b1 && uart_wr_ready == 1'b1) begin
        uart_wr_valid <= 1'b0;
      end
      @(posedge uart_clk);
    end
  endtask

endmodule
