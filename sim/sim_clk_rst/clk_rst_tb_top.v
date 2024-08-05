module clk_rst_tb_top ();

  parameter     T = 10ns;

  logic         clk_ext;
  logic         rst_ext;
  logic         clk_100m00;
  logic         rst_100m00;

  // External 100MHz oscillator
  initial begin
    clk_ext = 1'b0;
    forever begin
      #(T/2);
      clk_ext = ~clk_ext;
    end
  end

  // Create some asynchronous external reset
  initial begin
    rst_ext = 1'b0;
    #(35*T);
    rst_ext = 1'b1;
    #(77*T);
    rst_ext = 1'b0;
  end

  clk_rst #(
    .RST_LENGTH       (10)
  )
  clk_rst_dut (
    .clk_ext          (clk_ext),
    .rst_ext          (rst_ext),
    .clk_100m00       (clk_100m00),
    .rst_100m00       (rst_100m00)
  );

endmodule
