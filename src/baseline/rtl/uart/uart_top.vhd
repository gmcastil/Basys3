library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;
use work.uart_pkg.all;

entity uart_top is
    generic (
        DEVICE              : string                := "7SERIES";
        -- This will need to correspond to a clock frequency property in the device tree
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
        axi4l_rresp         : out   std_logic_vector(1 downto 0);

        -- IRQ to global interrupt controller (GIC)
        irq                 : out   std_logic;

        -- Serial input ports (should map to a pad or an IBUF / OBUF)
        rxd                 : in    std_logic;
        txd                 : out   std_logic
    );

end entity uart_top;

architecture structural of uart_top is

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

    signal parity               : std_logic_vector(1 downto 0);
    signal char                 : std_logic_vector(1 downto 0);
    signal nbstop               : std_logic_vector(1 downto 0);

    signal baud_div             : unsigned(14 downto 0);
    signal baud_cnt             : unsigned(14 downto 0);
    signal baud_gen_en          : std_logic;

    -- attribute MARK_DEBUG                        : string;
    -- attribute MARK_DEBUG of rd_regs              : signal is "TRUE";
    -- attribute MARK_DEBUG of wr_regs              : signal is "TRUE";

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
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        rxd                 => rxd,
        txd                 => txd
    );

    uart_reg_map_i0: entity work.uart_reg_map
    generic map (
        NUM_REGS            => NUM_REGS
    )
    port map (
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
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
        wr_regs             => wr_regs
    );

    axi4l_regs_i0: entity work.axi4l_regs
    generic map (
        BASE_OFFSET         => BASE_OFFSET,
        BASE_OFFSET_MASK    => BASE_OFFSET_MASK,
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH
    )
    port map (
        clk                 => clk,
        rstn                => not rst,
        s_axi_awaddr        => axi4l_awaddr,
        s_axi_awvalid       => axi4l_awvalid,
        s_axi_awready       => axi4l_awready,
        s_axi_wdata         => axi4l_wdata,
        s_axi_wstrb         => axi4l_wstrb,
        s_axi_wvalid        => axi4l_wvalid,
        s_axi_wready        => axi4l_wready,
        s_axi_bresp         => axi4l_bresp,
        s_axi_bvalid        => axi4l_bvalid,
        s_axi_bready        => axi4l_bready,
        s_axi_araddr        => axi4l_araddr,
        s_axi_arvalid       => axi4l_arvalid,
        s_axi_arready       => axi4l_arready,
        s_axi_rdata         => axi4l_rdata,
        s_axi_rresp         => axi4l_rresp,
        s_axi_rvalid        => axi4l_rvalid,
        s_axi_rready        => axi4l_rready,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err
    );

    uart_axi4l_ila: entity work.axi4l_ila
    port map (
        clk                 => clk,
        probe0(0)           => rst,
        probe1(0)           => axi4l_awvalid,
        probe2(0)           => axi4l_awready,
        probe3              => axi4l_awaddr,
        probe4(0)           => axi4l_wvalid,
        probe5(0)           => axi4l_wready,
        probe6              => axi4l_wdata,
        probe7              => axi4l_wstrb,
        probe8(0)           => axi4l_bvalid,
        probe9(0)           => axi4l_bready,
        probe10             => axi4l_bresp,
        probe11(0)          => axi4l_arvalid,
        probe12(0)          => axi4l_arready,
        probe13             => axi4l_araddr,
        probe14(0)          => axi4l_rvalid,
        probe15(0)          => axi4l_rready,
        probe16             => axi4l_rdata,
        probe17             => axi4l_rresp,
        probe18             => std_logic_vector(reg_addr),
        probe19             => reg_wdata,
        probe20(0)          => reg_wren,
        probe21             => reg_be,
        probe22             => reg_rdata,
        probe23(0)          => reg_req,
        probe24(0)          => reg_ack,
        probe25(0)          => reg_err
    );

end architecture structural;

