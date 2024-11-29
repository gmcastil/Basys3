`timescale 1ns / 1ps

import axi4l_pkg::*;

module axi4l_regs_tb ();

    parameter int RST_ASSERT_CNT    = 10;

    parameter int AXI_ADDR_WIDTH    = 32;
    parameter int AXI_DATA_WIDTH    = 32;
    // These require that the register details in the DUT are set as constants or brought in as an
    // external package with a configuration. For now, set these here and then later we'll deal with
    // the complexity of configuration (and especially those in a mixedsvvh environment).
    parameter int REG_ADDR_WIDTH    = 4;
    parameter int REG_DATA_WIDTH    = 32;

    logic axi4l_aclk = 0;
    logic axi4l_arstn = 1;

    // Register Interface Signals
    logic [3:0]                     reg_addr;
    logic [REG_DATA_WIDTH-1:0]      reg_wdata;
    logic                           reg_wren;
    logic [REG_DATA_WIDTH-1:0]      reg_rdata;
    logic                           reg_rden;
    logic                           reg_req;
    logic                           reg_ack;

    // AXI4-Lite master BFM
    axi4l_pkg::m_axi4l_bfm m_bfm;

    axi4l_pkg::axi4l_wr_txn #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) wr_txn;
    axi4l_pkg::axi4l_rd_txn #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) rd_txn;

    // AXI4-Lite interface needs to be instantiated before it can be referenced in simulation code
    axi4l_if #(
        .ADDR_WIDTH     (AXI_ADDR_WIDTH),
        .DATA_WIDTH     (AXI_DATA_WIDTH)
    )
    axi4l_if_i0 (
        .clk            (axi4l_aclk),
        .arstn          (axi4l_arstn)
    );

    // Create our 100MHz clock
    initial begin
        forever begin
            #5ns;
            axi4l_aclk = ~axi4l_aclk;
        end
    end

    // Create our active high reset
    initial begin
        axi4l_arstn = 0;
        repeat(RST_ASSERT_CNT) @(posedge axi4l_aclk);
        axi4l_arstn = 1;
    end

    // Main testbench body
    initial begin
        $display("Starting simulation...");

        m_bfm = new(axi4l_if_i0);

        @(posedge axi4l_arstn);
        repeat (10) @(axi4l_if_i0.cb);

        for (int addr = 0; addr < 4; addr = addr + 4) begin
            rd_txn = new(addr);
            m_bfm.read(rd_txn);
            rd_txn.display();
        end

        $finish;
    end

    axi4l_regs #(
        .AXI_ADDR_WIDTH                 (AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH                 (AXI_DATA_WIDTH),
        .REG_ADDR_WIDTH                 (REG_ADDR_WIDTH),
        .REG_DATA_WIDTH                 (REG_DATA_WIDTH)
    )
    axi4l_regs_i0 (
        .clk                            (axi4l_aclk),
        .rstn                           (axi4l_arstn),
        .s_axi_awaddr                   (axi4l_if_i0.awaddr),
        .s_axi_awvalid                  (axi4l_if_i0.awvalid),
        .s_axi_awready                  (axi4l_if_i0.awready),
        .s_axi_wdata                    (axi4l_if_i0.wdata),
        .s_axi_wstrb                    (axi4l_if_i0.wstrb),
        .s_axi_wvalid                   (axi4l_if_i0.wvalid),
        .s_axi_wready                   (axi4l_if_i0.wready),
        .s_axi_bresp                    (axi4l_if_i0.bresp),
        .s_axi_bvalid                   (axi4l_if_i0.bvalid),
        .s_axi_bready                   (axi4l_if_i0.bready),
        .s_axi_araddr                   (axi4l_if_i0.araddr),
        .s_axi_arvalid                  (axi4l_if_i0.arvalid),
        .s_axi_arready                  (axi4l_if_i0.arready),
        .s_axi_rdata                    (axi4l_if_i0.rdata),
        .s_axi_rresp                    (axi4l_if_i0.rresp),
        .s_axi_rvalid                   (axi4l_if_i0.rvalid),
        .s_axi_rready                   (axi4l_if_i0.rready),
        .reg_addr                       (reg_addr),
        .reg_wdata                      (reg_wdata),
        .reg_wren                       (reg_wren),
        .reg_rdata                      (reg_rdata),
        .reg_rden                       (reg_rden),
        .reg_req                        (reg_req),
        .reg_ack                        (reg_ack)
    );

endmodule

