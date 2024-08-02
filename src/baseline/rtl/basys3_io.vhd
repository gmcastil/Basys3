library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity basys3_io is
        port (
            clk_ext_pad         : in    std_logic;
            clk_ext             : out   std_logic;

            slider_sw_pad       : in    std_logic_vector(15 downto 0);
            slider_sw           : out   std_logic_vector(15 downto 0);

            pushb_sw_pad        : in    std_logic_vector(4 downto 0);
            pushb_sw            : out   std_logic_vector(4 downto 0);

            led_pad             : out   std_logic_vector(15 downto 0);
            led                 : in    std_logic_vector(15 downto 0);
        
            sseg_digit_pad      : out   std_logic_vector(6 downto 0);
            sseg_digit          : in    std_logic_vector(6 downto 0);

            sseg_dp_pad         : out   std_logic;
            sseg_dp             : in    std_logic;

            sseg_selectn_pad    : out   std_logic_vector(3 downto 0);
            sseg_selectn        : in    std_logic_vector(3 downto 0);

            uart_rxd_pad        : in    std_logic;
            uart_rxd            : out   std_logic;

            uart_txd_pad        : out   std_logic;
            uart_txd            : in    std_logic
        );

end entity basys3_io;

architecture structural of basys3_io is

begin

    -- The external clock signal is treated specially and does not include an
    -- IBUF or BUFG instance in the IO ring.  All clock buffering is performed
    -- in the clock and reset module. For consistency in naming, we simply pass
    -- it through this module.
    clk_ext         <= clk_ext_pad;

    -- Push button and slider switches need to be debounced at some point after
    -- the IO ring.
    g_slider_sw: for i in 0 to 15 generate
        IBUF_slider_sw: IBUF
        generic map (
            IBUF_LOW_PWR    => TRUE,
            IOSTANDARD      => "DEFAULT"
        )
        port map (
           I                => slider_sw_pad(i),
           O                => slider_sw(i)
        );
    end generate g_slider_sw;

    g_pushb_sw: for i in 0 to 4 generate
        IBUF_pushb_sw: IBUF
        generic map (
            IBUF_LOW_PWR    => TRUE,
            IOSTANDARD      => "DEFAULT"
        )
        port map (
           I                => pushb_sw_pad(i),
           O                => pushb_sw(i)
        );
    end generate g_pushb_sw;

    -- Onboard LED bank
    g_led: for i in 0 to 15 generate
        OBUF_led: OBUF
        generic map (
            DRIVE           => 12,
            IOSTANDARD      => "DEFAULT",
            SLEW            => "SLOW"
        )
        port map (
            O               => led_pad(i),
            I               => led(i)
        );
    end generate g_led;

    -- Seven segment (SSEG) display module - controller performs pin
    -- muxing
    g_sseg_digit: for i in 0 to 6 generate
        OBUF_sseg_digit: OBUF
        generic map (
            DRIVE           => 12,
            IOSTANDARD      => "DEFAULT",
            SLEW            => "SLOW"
        )
        port map (
            O               => sseg_digit_pad(i),
            I               => sseg_digit(i)
        );
    end generate g_sseg_digit;

    OBUF_sseg_dp: OBUF
    generic map (
        DRIVE           => 12,
        IOSTANDARD      => "DEFAULT",
        SLEW            => "SLOW"
    )
    port map (
        O               => sseg_dp_pad,
        I               => sseg_dp
    );

    g_sseg_selectn: for i in 0 to 3 generate
        OBUF_sseg_selectn: OBUF
        generic map (
            DRIVE           => 12,
            IOSTANDARD      => "DEFAULT",
            SLEW            => "SLOW"
        )
        port map (
            O               => sseg_selectn_pad(i),
            I               => sseg_selectn(i)
        );
    end generate g_sseg_selectn;

    -- UART RXD and TXD pins
    IBUF_uart_rxd: IBUF
    generic map (
        IBUF_LOW_PWR    => TRUE,
        IOSTANDARD      => "DEFAULT"
    )
    port map (
        I               => uart_rxd_pad,
        O               => uart_rxd
    );

    OBUF_uart_txd: OBUF
    generic map (
        DRIVE           => 12,
        IOSTANDARD      => "DEFAULT",
        SLEW            => "SLOW"
    )
    port map (
        O               => uart_txd_pad,
        I               => uart_txd
    );

end architecture structural;
