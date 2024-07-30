library ieee;
use ieee.std_logic_1164.all;

entity basys3_top is
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

        -- FTDI FT2232HQ USB-to-UART bridge
        uart_rxd_pad        : in    std_logic;
        uart_txd_pad        : out   std_logic
    );

end entity basys3_top;
        
architecture structural of basys3_top is

    component basys3_io is
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
    end component basys3_io;

    component clk_rst is
        port (
            clk_ext             : in    std_logic;
            rst_ext             : in    std_logic;

            clk_100m00          : out   std_logic;
            rst_100m00          : out   std_logic
        );
    end component clk_rst;

    signal clk_ext              : std_logic;
    signal rst_ext              : std_logic;

    signal slider_sw            : std_logic_vector(15 downto 0);
    signal pushb_sw             : std_logic_vector(4 downto 0);
    signal led                  : std_logic_vector(15 downto 0);
    signal sseg_digit           : std_logic_vector(6 downto 0);
    signal sseg_dp              : std_logic;
    signal sseg_selectn         : std_logic_vector(3 downto 0);
    signal uart_rxd             : std_logic;
    signal uart_txd             : std_logic;

    signal clk_100m00           : std_logic;
    signal rst_100m00           : std_logic;

begin

    -- IO ring
    basys3_io_i0: basys3_io
    port map (
		clk_ext_pad			=> clk_ext_pad,
		clk_ext		    	=> clk_ext,

		slider_sw_pad		=> slider_sw_pad,
		slider_sw			=> slider_sw,

		pushb_sw_pad		=> pushb_sw_pad,
		pushb_sw			=> pushb_sw,

		led_pad		    	=> led_pad,
		led		        	=> led,
    
		sseg_digit_pad		=> sseg_digit_pad,
		sseg_digit			=> sseg_digit,

		sseg_dp_pad			=> sseg_dp_pad,
		sseg_dp		    	=> sseg_dp,

		sseg_selectn_pad	=> sseg_selectn_pad,
		sseg_selectn		=> sseg_selectn,

		uart_rxd_pad		=> uart_rxd_pad,
		uart_rxd		    => uart_rxd,

		uart_txd_pad		=> uart_txd_pad,
		uart_txd		    => uart_txd
    );

    -- Clock and reset generator
    clk_rst_i0: clk_rst
    port map (
        clk_ext             => clk_ext,
        rst_ext             => rst_ext,

        clk_100m00          => clk_100m00,
        rst_100m00          => rst_100m00
    );

    -- User core include:
    --   UART core
    --   Heartbeat LED
    --   SSEG display
    user_core_i0: entity work.user_core
    port map (
        clk                 => clk_100m00,
        rst                 => rst_100m00,

        uart_rxd            => uart_rxd,
        uart_txd            => uart_txd,

        sseg_digit          => sseg_digit,
        sseg_dp             => sseg_dp,
        sseg_selectn        => sseg_selectn,

        heartbeat           => open
    );

end architecture structural;

