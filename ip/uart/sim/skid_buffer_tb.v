`timescale 1ns / 1ps

module skid_buffer_tb ();

    // FIFO signals
    logic fifo_wr_en;
    logic [7:0] fifo_wr_data;
    logic fifo_rd_en;
    logic [7:0] fifo_rd_data;
    logic fifo_ready;
    logic fifo_full;
    logic fifo_empty;

    // Skid buffer signals
    logic [7:0] rd_data;
    logic rd_valid;
    logic rd_ready;

    logic         clk;
    logic         rst;
    logic         clk_ext;
    logic         rst_ext;
    logic [5:0]   sys_clk;
    logic [5:0]   sys_rst;

    assign clk = sys_clk[0];
    assign rst = sys_rst[0];

    // Establish the 100MHz external oscillator provided by the board
    initial begin
      clk_ext = 1'b0;
      forever begin
        #5ns;
        clk_ext = ~clk_ext;
      end
    end

    clk_rst #(
      .RST_LENGTH           (10),
      .NUM_CLOCKS           (6)
    )
    clk_rst_i0 (
      .clk_ext              (clk_ext),
      .rst_ext              (rst_ext),
      .sys_clk              (sys_clk),
      .sys_rst              (sys_rst)
    );

    fifo_sync #(
        .DEVICE             ("7SERIES"),
        .FIFO_WIDTH         (8),
        .FIFO_SIZE          ("18Kb"),
        .FWFT               (0),
        .DO_REG             (1),
        .DEBUG              (0)
    ) fifo_inst (
        .clk                (clk),
        .rst                (rst),
        .wr_en              (fifo_wr_en),
        .wr_data            (fifo_wr_data),
        .rd_en              (fifo_rd_en),
        .rd_data            (fifo_rd_data),
        .ready              (fifo_ready),
        .full               (fifo_full),
        .empty              (fifo_empty)
    );

    skid_buffer #(
        .DATA_WIDTH         (8)
    ) skid_inst (
        .clk                (clk),
        .rst                (rst),
        .fifo_rd_data       (fifo_rd_data),
        .fifo_rd_en         (fifo_rd_en),
        .fifo_full          (fifo_full),
        .fifo_empty         (fifo_empty),
        .fifo_ready         (fifo_ready),
        .rd_data            (rd_data),
        .rd_valid           (rd_valid),
        .rd_ready           (rd_ready)
    );

    initial begin
      rst_ext = 1'b0;
      fifo_wr_en = 1'b0;
      rd_ready = 1'b0;

      @(negedge rst);
      wait(fifo_ready == 1'b1);
      $display("FIFO ready");

      for (int i = 1; i < 128; i++) begin
        write_to_fifo(i[7:0]);
      end

      rd_ready = 1'b1;
      @(posedge clk);
      rd_ready = 1'b0;

      repeat (10) @(posedge clk);

      $finish();
    end

    task automatic write_to_fifo(
      input logic [7:0] data
    );

      // Wait for the FIFO to not be full
      fifo_wr_en = 1'b0;
      while (fifo_full) begin
        @(posedge clk);
      end

      // Write to the FIFO
      fifo_wr_en = 1'b1;
      fifo_wr_data = data;
      @(posedge clk);
      fifo_wr_en = 1'b0;

    endtask

endmodule

