`timescale 1ns / 1ps

import axi4l_pkg::*;

module axi4l_regs_tb ();

    parameter int RST_ASSERT_CNT = 10;

    parameter int AXI_ADDR_WIDTH = 32;
    parameter int AXI_DATA_WIDTH = 32;

    logic axi4l_aclk = 0;
    logic axi4l_arstn = 1;

    // AXI4-Lite master BFM
    axi4l_pkg::m_axi4l_bfm m_bfm;

    axi4l_pkg::axi4l_txn #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) wr_txn;
    axi4l_pkg::axi4l_txn #(AXI_ADDR_WIDTH, AXI_DATA_WIDTH) rd_txn;

    // AXI4-Lite interface needs to be instantiated before it can be referenced in simulation code
    axi4l_if #(
        .ADDR_WIDTH     (AXI_ADDR_WIDTH),
        .DATA_WIDTH     (AXI_DATA_WIDTH)
    )
    axi4l_if_i0 (
        .axi4l_aclk     (axi4l_aclk),
        .axi4l_arstn    (axi4l_arstn)
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
        m_bfm = new(axi4l_if_i0);
        wr_txn = new();
        rd_txn = new();

        #100ns;
        $finish;
    end

endmodule

