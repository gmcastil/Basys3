library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity basys3_top is
    generic (
        UART_RX_FIFO_DO_REG     : natural   := 0;
        UART_TX_FIFO_DO_REG     : natural   := 0;
        UART_BASE_OFFSET        : unsigned(31 downto 0) := x"80000000";
        UART_BASE_OFFSET_MASK   : unsigned(31 downto 0) := x"00000FFF";
        DEBUG_UART_AXI          : boolean   := false;
        DEBUG_UART_CORE         : boolean   := false
    );
    port (
        -- 100MHz external clock
        clk_ext_pad         : in    std_logic;

        -- Slider switches
        slider_sw_pad       : in    std_logic_vector(15 downto 0);

        -- Pushbutton switches
        pushb_sw_pad        : in    std_logic_vector(4 downto 0);

        -- User LED
        led_pad             : out   std_logic_vector(15 downto 0);

        -- Seven-segment (SSEG) display
        sseg_digit_pad      : out   std_logic_vector(6 downto 0);
        sseg_dp_pad         : out   std_logic;
        sseg_selectn_pad    : out   std_logic_vector(3 downto 0);

        -- FTDI FT2232HQ USB-to-UART bridge.  Two onboard status LED provide
        -- visual feedback on UART traffic: the transmit LED (LD18) and the
        -- receive LED (LD17). Signal names on the board are from perspective
        -- of the data terminal equipment (e.g., a PC). These are in addition
        -- to the user LEDs and are not connected to fabric logic.
        uart_rxd_pad        : in    std_logic;
        uart_txd_pad        : out   std_logic
    );

end entity basys3_top;

architecture structural of basys3_top is

    -- Clocks and reset
    signal clk_ext              : std_logic;
    signal rst_ext              : std_logic;

    signal clk_100m00           : std_logic;
    signal rst_100m00           : std_logic;

    signal sys_clk              : std_logic_vector(5 downto 0);
    signal sys_rst              : std_logic_vector(5 downto 0);

    -- Bells and whistles
    signal slider_sw            : std_logic_vector(15 downto 0);
    signal pushb_sw             : std_logic_vector(4 downto 0);
    signal led                  : std_logic_vector(15 downto 0);
    signal user_led             : std_logic_vector(15 downto 0);

    -- Seven segment display
    signal sseg_digit           : std_logic_vector(6 downto 0);
    signal sseg_dp              : std_logic;
    signal sseg_selectn         : std_logic_vector(3 downto 0);

    -- UART
    signal uart_ready           : std_logic;
    signal uart_rd_data         : std_logic_vector(7 downto 0);
    signal uart_rd_valid        : std_logic;
    signal uart_rd_ready        : std_logic;
    signal uart_wr_data         : std_logic_vector(7 downto 0);
    signal uart_wr_valid        : std_logic;
    signal uart_wr_ready        : std_logic;
    signal uart_mode            : std_logic_vector(1 downto 0);
    signal uart_rxd             : std_logic;
    signal uart_txd             : std_logic;

    signal jtag_axi4l_awvalid   : std_logic;
    signal jtag_axi4l_awready   : std_logic;
    signal jtag_axi4l_awaddr    : std_logic_vector(31 downto 0);
    signal jtag_axi4l_wvalid    : std_logic;
    signal jtag_axi4l_wready    : std_logic;
    signal jtag_axi4l_wdata     : std_logic_vector(31 downto 0);
    signal jtag_axi4l_wstrb     : std_logic_vector(3 downto 0);
    signal jtag_axi4l_bvalid    : std_logic;
    signal jtag_axi4l_bready    : std_logic;
    signal jtag_axi4l_bresp     : std_logic_vector(1 downto 0);
    signal jtag_axi4l_arvalid   : std_logic;
    signal jtag_axi4l_arready   : std_logic;
    signal jtag_axi4l_araddr    : std_logic_vector(31 downto 0);
    signal jtag_axi4l_rvalid    : std_logic;
    signal jtag_axi4l_rready    : std_logic;
    signal jtag_axi4l_rdata     : std_logic_vector(31 downto 0);
    signal jtag_axi4l_rresp     : std_logic_vector(1 downto 0);

begin

    -- IO ring
    basys3_io_i0: entity work.basys3_io
    port map (

        clk_ext_pad         => clk_ext_pad,
        clk_ext             => clk_ext,

        slider_sw_pad       => slider_sw_pad,
        slider_sw           => slider_sw,

        pushb_sw_pad        => pushb_sw_pad,
        pushb_sw            => pushb_sw,

        led_pad             => led_pad,
        led                 => led,

        sseg_digit_pad      => sseg_digit_pad,
        sseg_digit          => sseg_digit,

        sseg_dp_pad         => sseg_dp_pad,
        sseg_dp             => sseg_dp,

        sseg_selectn_pad    => sseg_selectn_pad,
        sseg_selectn        => sseg_selectn,

        uart_rxd_pad        => uart_rxd_pad,
        uart_rxd            => uart_rxd,

        uart_txd_pad        => uart_txd_pad,
        uart_txd            => uart_txd
    );

    -- Clock and reset generator
    clk_rst_i0: entity work.clk_rst
    generic map (
        RST_LENGTH          => 10,
        NUM_CLOCKS          => 6
    )
    port map (
        clk_ext             => clk_ext,
        rst_ext             => pushb_sw(0),

        sys_clk             => sys_clk,
        sys_rst             => sys_rst
    );

    -- Not every module in the baseline top level design needs or should have every clock and reset
    -- routed to it (this inhibits reuse), so break them out individually here.
    clk_100m00          <= sys_clk(0);
    rst_100m00          <= sys_rst(0);

    -- Top level UART with AXI4-Lite interface
    uart_i0: entity work.uart_top
    generic map (
        DEVICE              => "7SERIES",
        CLK_FREQ            => 100000000,
        BASE_OFFSET         => UART_BASE_OFFSET,
        BASE_OFFSET_MASK    => UART_BASE_OFFSET_MASK,
        DEBUG_UART_AXI      => DEBUG_UART_AXI,
        DEBUG_UART_CORE     => DEBUG_UART_CORE
    )
    port map (
        clk                 => clk_100m00,
        rst                 => rst_100m00,
        axi4l_awvalid       => jtag_axi4l_awvalid,
        axi4l_awready       => jtag_axi4l_awready,
        axi4l_awaddr        => jtag_axi4l_awaddr,
        axi4l_wvalid        => jtag_axi4l_wvalid,
        axi4l_wready        => jtag_axi4l_wready,
        axi4l_wdata         => jtag_axi4l_wdata,
        axi4l_wstrb         => jtag_axi4l_wstrb,
        axi4l_bvalid        => jtag_axi4l_bvalid,
        axi4l_bready        => jtag_axi4l_bready,
        axi4l_bresp         => jtag_axi4l_bresp,
        axi4l_arvalid       => jtag_axi4l_arvalid,
        axi4l_arready       => jtag_axi4l_arready,
        axi4l_araddr        => jtag_axi4l_araddr,
        axi4l_rvalid        => jtag_axi4l_rvalid,
        axi4l_rready        => jtag_axi4l_rready,
        axi4l_rdata         => jtag_axi4l_rdata,
        axi4l_rresp         => jtag_axi4l_rresp,
        irq                 => open,
        rxd                 => uart_rxd,
        txd                 => uart_txd
    );

    -- For now, all the LEDs will be routed to the user core
    user_led                <= led;

    -- And for now, we'll drive the SSEG from user core as well, but eventually,
    -- some easier interface would make sense
    sseg_digit              <= (others=>'0');
    sseg_dp                 <= '0';
    sseg_selectn            <= (others=>'1');

    jtag_uart_i0: entity work.jtag_uart
    port map (
        aclk                => clk_100m00,
        aresetn             => not rst_100m00,
        m_axi_awaddr        => jtag_axi4l_awaddr,
        m_axi_awprot        => open,
        m_axi_awvalid       => jtag_axi4l_awvalid,
        m_axi_awready       => jtag_axi4l_awready,
        m_axi_wdata         => jtag_axi4l_wdata,
        m_axi_wstrb         => jtag_axi4l_wstrb,
        m_axi_wvalid        => jtag_axi4l_wvalid,
        m_axi_wready        => jtag_axi4l_wready,
        m_axi_bresp         => jtag_axi4l_bresp,
        m_axi_bvalid        => jtag_axi4l_bvalid,
        m_axi_bready        => jtag_axi4l_bready,
        m_axi_araddr        => jtag_axi4l_araddr,
        m_axi_arprot        => open,
        m_axi_arvalid       => jtag_axi4l_arvalid,
        m_axi_arready       => jtag_axi4l_arready,
        m_axi_rdata         => jtag_axi4l_rdata,
        m_axi_rresp         => jtag_axi4l_rresp,
        m_axi_rvalid        => jtag_axi4l_rvalid,
        m_axi_rready        => jtag_axi4l_rready
    );

    -- User core
    user_core_i0: entity work.user_core
    port map (
        sys_clk             => sys_clk,
        sys_rst             => sys_rst,

        uart_ready          => uart_ready,

        uart_rd_data        => uart_rd_data,
        uart_rd_valid       => uart_rd_valid,
        uart_rd_ready       => uart_rd_ready,

        uart_wr_data        => uart_wr_data,
        uart_wr_valid       => uart_wr_valid,
        uart_wr_ready       => uart_wr_ready,

        sseg_digit          => open,
        sseg_dp             => open,
        sseg_selectn        => open,

        slider_sw           => slider_sw,

        user_led            => user_led
    );

end architecture structural;

