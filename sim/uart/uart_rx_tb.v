`timescale 1ns / 1ps

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

  logic         uart_clk;
  logic         uart_rst;

  uart_bfm bfm;

  string test_file = "128b-random.bin";
  string recv_file = "128b-random-recv.bin";
  int recv_fd;

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

  // Sequence of events which resets the UART, configures the BFM, sends the
  // data file and then ends the test when it's been sent
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
    bfm = new();

    // Wait until reset is deasserted
    @(negedge uart_rst);
    $display("UART reset complete");
    // UART stimulus can start several clocks after reset is deasserted (this is not exactly true,
    // since the FIFO might not be ready yet.  Future revision should include some sort of a ready
    // signal, but for now this is good)
    repeat (10) @(posedge uart_clk);

    // Now that the UART is done with reset (see note on ready and FIFO status)
    uart_rd_ready = 1'b1;
    @(posedge uart_clk);

    $display("Sending %s to UART", test_file);
    bfm.send_file(test_file, uart_rxd);

    $display("Done");
    $finish();
  end

  // Open the received file so we can save what is received in a clocked process
  // that is sensitive to clock edges
  initial begin
    recv_fd = $fopen(recv_file, "wb");
    if (recv_fd) begin
      $display("Opened %s for storing received data", recv_file);
    end else begin
      $fatal(1, "Could not open %s for writing", recv_file);
    end
    $fflush(recv_fd);
  end

    always @(posedge uart_clk) begin
        if ( (uart_rd_valid == 1'b1 ) && (uart_rd_ready == 1'b1) ) begin
            if (recv_fd) begin
                $fwrite(recv_fd, "%c", uart_rd_data);
            end
        end
    end

  final begin
    if (recv_fd) begin
      $display("Closing %s", recv_file);
      $fclose(recv_fd);
    end
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
    .DEVICE           ("7SERIES"),
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

