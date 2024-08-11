library ieee;
use ieee.std_logic_1164.all;

entity uart is
    generic (
        -- Input clock frequency
        CLK_FREQ    : integer       := 100000000;
        -- Desired baud rate
        BAUD_RATE   : integer       := 115200
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        uart_rd_data        : out   std_logic_vector(7 downto 0);
        uart_rd_valid       : out   std_logic;
        uart_rd_ready       : in    std_logic;

        uart_wr_data        : in    std_logic_vector(7 downto 0);
        uart_wr_valid       : in    std_logic;
        uart_wr_ready       : out   std_logic;

        -- uart_parity_err
        -- uart_frame_err
        -- uart_overrun_err
        --
        -- uart_cts
        -- uart_rts
        --
        -- uart_rx_busy
        -- uart_wr_busy
        --
        -- uart_break_detect
        --
        --
        -- interrupt out

        -- Operational mode:
        --   00 = normal UART operation
        --   01 = hardware loopback
        --   10 = reserved
        --   11 = reserved
        --
        -- In hardware loopback, the TXD and RXD ports function as in normal mode, and the values
        -- read from RXD port are sent immediately through the TXD port.
        --
        -- In normal operation....we need some FIFOs....
        uart_mode           : in    std_logic_vector(1 downto 0);

        -- These need to be initialized to 1 so we don't put junk on the lines.
        uart_rxd            : in    std_logic;
        uart_txd            : out   std_logic
    );

end entity uart;

architecture structural of uart is

    constant UART_MODE_NORMAL       : std_logic_vector(1 downto 0) := "00";
    constant UART_MODE_LOOPBACK     : std_logic_vector(1 downto 0) := "01";

    signal baud_tick                : std_logic;

    -- Local UART signals
    signal uart_rd_data_l           : std_logic_vector(7 downto 0);
    signal uart_rd_valid_l          : std_logic;
    signal uart_rd_ready_l          : std_logic;

    signal uart_wr_data_l           : std_logic_vector(7 downto 0);
    signal uart_wr_valid_l          : std_logic;
    signal uart_wr_ready_l          : std_logic;

begin

    baud_rate_gen_i0: entity work.baud_rate_gen
    generic map (
        CLK_FREQ        => CLK_FREQ,
        BAUD_RATE       => BAUD_RATE
    )
    port map (
        clk             => clk,
        rst             => rst,
        baud_tick       => baud_tick
    );

    uart_rx_i0: entity work.uart_rx
    generic map (
        CLK_FREQ        => CLK_FREQ,
        BAUD_RATE       => BAUD_RATE
    )
    port map (
        clk             => clk,
        rst             => rst,

        uart_rd_data    => uart_rd_data_l,
        uart_rd_valid   => uart_rd_valid_l,
        uart_rd_ready   => uart_rd_ready_l,

        uart_rxd        => uart_rxd
    );

    -- Should add frame counts to the RX and TX cores here
    uart_tx_i0: entity work.uart_tx
    port map (
        clk             => clk,
        rst             => rst,
        baud_tick       => baud_tick,

        uart_wr_data    => uart_wr_data_l,
        uart_wr_valid   => uart_wr_valid_l,
        uart_wr_ready   => uart_wr_ready_l,

        uart_txd        => uart_txd
    );

    -- In hardware loopback mode, the TX and RX function normally (i.e., the data terminal equipment
    -- sends data to the RX port and can receive data from the TX port) and the external write and
    -- read interfaces are ignored entirely. This is done for several reasons. for
    -- reusability purposes, since it allows the loopback functionality to travel with the UART
    -- core, and second, because it requires no change to user core code to test or debug the serial
    -- interface.

    uart_rd_data        <= (others=>'0') when uart_mode = UART_MODE_LOOPBACK else uart_rd_data_l;
    uart_rd_valid       <= '0' when uart_mode = UART_MODE_LOOPBACK else uart_rd_valid_l;
    uart_wr_ready       <= '0' when uart_mode = UART_MODE_LOOPBACK else uart_wr_ready_l;

    uart_wr_data_l      <= uart_rd_data_l when uart_mode = UART_MODE_LOOPBACK else uart_wr_data;
    uart_wr_valid_l     <= uart_rd_valid_l when uart_mode = UART_MODE_LOOPBACK else uart_wr_valid;

end architecture structural;

