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

    logic [31:0] raddr = 0;
    // Main testbench body
    initial begin
        $display("Starting simulation...");
        m_bfm = new(axi4l_if_i0);

        @(posedge axi4l_arstn);

        @(axi4l_if_i0.cb);

        for (int i = 0; i < 4; i++) begin
            rd_txn = new(raddr);
            m_bfm.read(rd_txn);
            raddr++;
        end

        $finish;
    end

    // Super sloppy and non-compliant axi slave to wiggle my tasks
    logic [31:0] rdata = 0;

    always @(axi4l_if_i0.cb) begin
        if (axi4l_arstn == 1'b0) begin
            axi4l_if_i0.arready <= 1'b0;
            axi4l_if_i0.rdata <= 32'h0;
            axi4l_if_i0.rvalid <= 1'b0;
        end else begin
            if (axi4l_if_i0.arvalid && !axi4l_if_i0.arready) begin
                axi4l_if_i0.arready <= 1'b1;
                axi4l_if_i0.rdata <= rdata;
                rdata++;
                axi4l_if_i0.rvalid <= 1'b1;
            end else begin
                if (axi4l_if_i0.arvalid && axi4l_if_i0.arready) begin
                    axi4l_if_i0.arready <= 1'b0;
                    axi4l_if_i0.rdata <= 32'hdeadbeef;
                end
            end
        end
    end

endmodule

