`timescale 1ns / 1ps

import axi4l_pkg::*;

module axi4l_regs_tb ();

    parameter int RST_ASSERT_CNT    = 10;

    parameter int AXI_ADDR_WIDTH    = 32;
    parameter int AXI_DATA_WIDTH    = 32;
    // These require that the register details in the DUT are set as constants or brought in as an
    // external package with a configuration. For now, set these here and then later we'll deal with
    // the complexity of configuration (and especially those in a mixedsvvh environment).
    parameter int REG_ADDR_WIDTH    = 16;
    parameter int REG_DATA_WIDTH    = 32;

    parameter int NUM_REGS                          = 4;
    parameter logic [NUM_REGS-1:0] REG_WRITE_MASK   = 4'b1011;

    logic axi4l_aclk = 0;
    logic axi4l_arstn = 1;

    // Register Interface Signals
    logic [REG_ADDR_WIDTH-1:0]      reg_addr;
    logic [REG_DATA_WIDTH-1:0]      reg_wdata;
    logic                           reg_wren;
    logic [(REG_DATA_WIDTH/8)-1:0]  reg_be;
    logic [REG_DATA_WIDTH-1:0]      reg_rdata;
    logic                           reg_rden;
    logic                           reg_req;
    logic                           reg_ack;
    logic                           reg_err;

    logic [NUM_REGS-1:0][REG_DATA_WIDTH-1:0]    rd_regs;
    logic [NUM_REGS-1:0][REG_DATA_WIDTH-1:0]    wr_regs;

    // Registers that will be read back external sources. With the write mask we selected,
    // register 2 would be a readable hardware register
    assign rd_regs[2] = 32'h0000FFFF;

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
    logic [31:0] addr;

    initial begin
        $display("Starting simulation...");

        m_bfm = new(axi4l_if_i0.master);

        @(posedge axi4l_arstn);
        repeat (10) @(axi4l_if_i0.cb);

        for (int i = 0; i < 5; i++) begin
            addr = 32'h80000000 + (4 * i);
            $display("Starting read at address %h", addr);
            rd_txn = new(addr, AXI4L_READ);
            m_bfm.read(rd_txn);
            rd_txn.display();
        end
        $fflush();

        for (int i = 0; i < 5; i++) begin
            addr = 32'h80000000 + (4 * i);
            $display("Starting writes at address %h", addr);
            wr_txn = new(addr, AXI4L_WRITE);
            m_bfm.write(wr_txn);
            wr_txn.display();
        end

        for (int i = 0; i < 4; i++) begin
            addr = 32'h80000000 + (4 * i);
            rd_txn = new(addr, AXI4L_READ);
            m_bfm.read(rd_txn);
            $display("Addr: 0x%08h Data: 0x%08h", rd_txn.addr, rd_txn.data);
        end

        wr_txn = new(32'h80000000, AXI4L_WRITE);
        rd_txn = new(32'h80000004, AXI4L_READ);
        fork
            begin
                m_bfm.write(wr_txn);
            end begin
                m_bfm.read(rd_txn);
            end
        join

        $finish;
    end

    axi4l_regs #(
        .BASE_OFFSET                    (32'h80000000),
        .BASE_OFFSET_MASK               (32'h0000FFFF),
        .REG_ADDR_WIDTH                 (REG_ADDR_WIDTH)
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
        .reg_be                         (reg_be),
        .reg_rdata                      (reg_rdata),
        .reg_req                        (reg_req),
        .reg_ack                        (reg_ack),
        .reg_err                        (reg_err)
    );

    reg_block #(
        .REG_ADDR_WIDTH                 (REG_ADDR_WIDTH),
        .NUM_REGS                       (NUM_REGS),
        .REG_WRITE_MASK                 (REG_WRITE_MASK)
    )
    reg_block_i0 (
        .clk                            (axi4l_aclk),
        .rst                            (~axi4l_arstn),
        .reg_addr                       (reg_addr),
        .reg_wdata                      (reg_wdata),
        .reg_wren                       (reg_wren),
        .reg_be                         (reg_be),
        .reg_rdata                      (reg_rdata),
        .reg_req                        (reg_req),
        .reg_ack                        (reg_ack),
        .reg_err                        (reg_err),
        .rd_regs                        (rd_regs),
        .wr_regs                        (wr_regs)
    );



endmodule

