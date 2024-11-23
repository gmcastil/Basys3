library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic (
        DEVICE              : string            := "7SERIES";
        CLK_FREQ            : integer           := 100000000;
        DEBUG_UART_AXI      : boolean           := false;
        DEBUG_UART_CORE     : boolean           := false
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

begin

    uart_core_i0: entity work.uart_core
    generic (
        DEVICE              = DEVICE,
        CLK_FREQ            = CLK_FREQ,
        DEBUG               = DEBUG_UART_CORE
    );
    port (
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

    g_debug_uart_axi: if (DEBUG_UART_AXI = true) generate

    end generate g_debug_uart_axi;

end architecture structural;
