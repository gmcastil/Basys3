library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_types_pkg.all;

entity uart_top is
    generic (
        DEVICE              : string                := "7SERIES";
        CLK_FREQ            : integer               := 100000000;
        BASE_OFFSET         : unsigned(31 downto 0) := (others=>'0');
        BASE_OFFSET_MASK    : unsigned(31 downto 0) := (others=>'0');
        DEBUG_UART_AXI      : boolean               := false;
        DEBUG_UART_CORE     : boolean               := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- AXI4-Lite register interface
        axi4l_awvalid       : in    std_logic;
        axi4l_awready       : out   std_logic;
        axi4l_awaddr        : in    std_logic_vector(31 downto 0);

        axi4l_wvalid        : in    std_logic;
        axi4l_wready        : out   std_logic;
        axi4l_wdata         : in    std_logic_vector(31 downto 0);
        axi4l_wstrb         : in    std_logic_vector(3 downto 0);

        axi4l_bvalid        : out   std_logic;
        axi4l_bready        : in    std_logic;
        axi4l_bresp         : out   std_logic_vector(1 downto 0);

        axi4l_arvalid       : in    std_logic;
        axi4l_arready       : out   std_logic;
        axi4l_araddr        : in    std_logic_vector(31 downto 0);

        axi4l_rvalid        : out   std_logic;
        axi4l_rready        : in    std_logic;
        axi4l_rdata         : out   std_logic_vector(31 downto 0);
        axi4l_rresp         : out   std_logic_vector(1 downto 0)

        -- IRQ to global interrupt controller (GIC)
        irq                 : out   std_logic;

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic
    );

end entity uart_top;

architecture structural of uart_top is

    constant REG_ADDR_WIDTH     := 4;
    constant NUM_REGS           := 16;
    constant REG_WRITE_MASK     := (others=>'0');

    signal reg_addr             : unsigned(REG_ADDR_WIDTH-1 downto 0);
    signal reg_wdata            : std_logic_vector(31 downto 0);
    signal reg_wren             : std_logic;
    signal reg_be               : std_logic_vector(3 downto 0);
    signal reg_rdata            : std_logic_vector(31 downto 0);
    signal reg_req              : std_logic;
    signal reg_ack              : std_logic;
    signal reg_err              : std_logic;

    signal rd_regs              : reg_a(NUM_REGS-1 downto 0);
    signal wr_regs              : reg_a(NUM_REGS-1 downto 0);

begin

    uart_core_i0: entity work.uart_core
    generic map (
        DEVICE              => DEVICE,
        CLK_FREQ            => CLK_FREQ,
        DEBUG               => DEBUG_UART_CORE
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        rx_rst              => rx_rst,
        tx_rst              => tx_rst,
        rx_enable           => rx_enable,
        tx_enable           => tx_enable,
        parity              => parity,
        char                => char,
        hw_flow_enable      => hw_flow_enable,
        hw_flow_rts         => hw_flow_rts,
        hw_flow_cts         => hw_flow_cts,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        irq_enable          => irq_enable,
        irq_mask            => irq_mask,
        irq_clear           => irq_clear,
        irq_active          => irq_active,
        rx_data             => rx_data,
        tx_data             => tx_data,
        rxd                 => rxd,
        txd                 => txd
    );

    axi4l_regs_i0: entity work.axi4l_regs
    generic map (
        BASE_OFFSET         => BASE_OFFSET,
        BASE_OFFSET_MASK    => BASE_OFFSET_MASK,
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH
    )
    port map (
        clk                 => clk,
        rstn                => rstn,
        s_axi_awaddr        => s_axi_awaddr,
        s_axi_awvalid       => s_axi_awvalid,
        s_axi_awready       => s_axi_awready,
        s_axi_wdata         => s_axi_wdata,
        s_axi_wstrb         => s_axi_wstrb,
        s_axi_wvalid        => s_axi_wvalid,
        s_axi_wready        => s_axi_wready,
        s_axi_bresp         => s_axi_bresp,
        s_axi_bvalid        => s_axi_bvalid,
        s_axi_bready        => s_axi_bready,
        s_axi_araddr        => s_axi_araddr,
        s_axi_arvalid       => s_axi_arvalid,
        s_axi_arready       => s_axi_arready,
        s_axi_rdata         => s_axi_rdata,
        s_axi_rresp         => s_axi_rresp,
        s_axi_rvalid        => s_axi_rvalid,
        s_axi_rready        => s_axi_rready,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err
    );

    uart_regs: entity work.reg_block
    generic map (
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH,
        NUM_REGS            => NUM_REGS,
        REG_WRITE_MASK      => REG_WRITE_MASK
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs,
    );

end architecture structural;
