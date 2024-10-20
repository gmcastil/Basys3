library ieee;
use ieee.std_logic_1164.all;

entity basys3_top is
    generic (
        UART_DEBUG          : boolean       := false
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

    -- UART core
    uart_i0: entity work.uart
    generic map (
        CLK_FREQ            => 100000000,
        BAUD_RATE           => 115200,
        DEBUG               => UART_DEBUG
    )
    port map (
        clk                 => clk_100m00,
        rst                 => rst_100m00,
        uart_ready          => uart_ready,
        uart_rd_data        => uart_rd_data,
        uart_rd_valid       => uart_rd_valid,
        uart_rd_ready       => uart_rd_ready,
        uart_wr_data        => uart_wr_data,
        uart_wr_valid       => uart_wr_valid,
        uart_wr_ready       => uart_wr_ready,
        uart_mode           => uart_mode,
        uart_rxd            => uart_rxd,
        uart_txd            => uart_txd
    );

    -- For now, all the LEDs will be routed to the user core
    user_led                <= led;

    -- And for now, we'll drive the SSEG from user core as well, but eventually,
    -- some easier interface would make sense
    sseg_digit              <= (others=>'0');
    sseg_dp                 <= '0';
    sseg_selectn            <= (others=>'1');

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

        uart_mode           => uart_mode,

        sseg_digit          => open,
        sseg_dp             => open,
        sseg_selectn        => open,

        slider_sw           => slider_sw,

        user_led            => user_led
    );

end architecture structural;

