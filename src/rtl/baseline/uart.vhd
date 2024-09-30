library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
        -- Input clock frequency
        CLK_FREQ    : integer       := 100000000;
        -- Desired baud rate
        BAUD_RATE   : integer       := 115200;
        UART_DEBUG  : string        := "false"
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

        -- In hardware loopback mode, the TX and RX function normally (i.e., the data terminal
        -- equipment sends data to the RX port and can receive data from the TX port) and the
        -- external write and read interfaces are ignored entirely. This is done for several
        -- reasons. for reusability purposes, since it allows the loopback functionality to travel
        -- with the UART core, and second, because it requires no change to user core code to test
        -- or debug the serial interface.
        --
        -- Operational mode:
        --   00 = normal UART operation
        --   01 = reserved
        --   10 = reserved
        --   11 = reserved
        --
        uart_mode           : in    std_logic_vector(1 downto 0);

        uart_rxd            : in    std_logic;
        uart_txd            : out   std_logic
    );

end entity uart;

architecture structural of uart is

    -- UART mode select options
    constant UART_MODE_NORMAL       : std_logic_vector(1 downto 0) := "00";
    constant UART_MODE_LOOPBACK     : std_logic_vector(1 downto 0) := "01";

    -- Width of the FIFO data ports
    constant TX_DATA_WIDTH          : integer := 8;
    constant RX_DATA_WIDTH          : integer := 8;

    signal baud_tick                : std_logic;

    -- UART FIFO signals
    signal tx_fifo_wr_en            : std_logic;
    signal tx_fifo_wr_data          : std_logic_vector((TX_DATA_WIDTH - 1) downto 0);
    signal tx_fifo_rd_en            : std_logic;
    signal tx_fifo_rd_data          : std_logic_vector((TX_DATA_WIDTH - 1) downto 0);
    signal tx_fifo_ready            : std_logic;
    signal tx_fifo_full             : std_logic;
    signal tx_fifo_empty            : std_logic;

    signal rx_fifo_wr_en            : std_logic;
    signal rx_fifo_wr_data          : std_logic_vector((RX_DATA_WIDTH - 1) downto 0);
    signal rx_fifo_rd_en            : std_logic;
    signal rx_fifo_rd_data          : std_logic_vector((RX_DATA_WIDTH - 1) downto 0);
    signal rx_fifo_ready            : std_logic;
    signal rx_fifo_full             : std_logic;
    signal rx_fifo_empty            : std_logic;

    -- Local UART signals
    signal uart_rd_data_l           : std_logic_vector((RX_DATA_WIDTH - 1) downto 0);
    signal uart_rd_valid_l          : std_logic;
    signal uart_rd_ready_l          : std_logic;

    signal uart_wr_data_l           : std_logic_vector((TX_DATA_WIDTH - 1) downto 0);
    signal uart_wr_valid_l          : std_logic;
    signal uart_wr_ready_l          : std_logic;

    -- RX registers
    signal rx_frame_err             : unsigned(31 downto 0);
    signal rx_frame_cnt             : unsigned(31 downto 0);

    -- TX registers
    signal tx_frame_cnt             : unsigned(31 downto 0);

    attribute MARK_DEBUG            : string;

    -- Mark TX FIFO signals
    attribute MARK_DEBUG of tx_fifo_wr_en           : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_fifo_wr_data         : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_fifo_rd_en           : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_fifo_rd_data         : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_fifo_full            : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_fifo_empty           : signal is UART_DEBUG;
    -- Mark RX FIFO signals
    attribute MARK_DEBUG of rx_fifo_wr_en           : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_fifo_wr_data         : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_fifo_rd_en           : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_fifo_rd_data         : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_fifo_full            : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_fifo_empty           : signal is UART_DEBUG;

    attribute MARK_DEBUG of rx_frame_err            : signal is UART_DEBUG;
    attribute MARK_DEBUG of rx_frame_cnt            : signal is UART_DEBUG;
    attribute MARK_DEBUG of tx_frame_cnt            : signal is UART_DEBUG;

begin

    -- I think this is something that needs to be changed entirely, but for now, just using the
    -- reset to determine if the external reader is ready to drive the UART_RX module is probably
    -- ok. Key idea here is that the external reader needs to be reading entirely from the skid
    -- buffer, and not have any involvement with the uart_rx.  Looking at the elaborated design in
    -- Vivado, I'm not entirely sure that I actually need a ready input to the RX side of the UART.
    -- It might be a lot simpler to just have a clock, reset, and the RXD line.  Then it just spits
    -- out bytes and valid strobes.  I need to decide where / how I want to do error checking as
    -- well as defining a control register interface because, eventually, I'm going to want ot write
    -- a driver for this thing.  So, perhaps a good thing to do would be to look at the driver
    -- source code for other UART devices.
    uart_rd_ready_l     <= not rst;

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
        rx_frame_cnt    => rx_frame_cnt,
        rx_frame_err    => rx_frame_err,
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
        tx_frame_cnt    => tx_frame_cnt,
        uart_txd        => uart_txd
    );

    fifo_tx_i0: entity work.fifo_sync
    generic map (
        DEVICE              => "7SERIES",
        FIFO_WIDTH          => TX_DATA_WIDTH,
        FIFO_DEPTH          => 2048,
        FIFO_READ_LATENCY   => 1
    )
    port map (
        clk                 => clk,                 -- in    std_logic;
        rst                 => rst,                 -- in    std_logic;
        wr_en               => tx_fifo_wr_en,       -- in    std_logic;
        wr_data             => tx_fifo_wr_data,     -- in    std_logic_vector((FIFO_WIDTH - 1) downto 0);
        rd_en               => tx_fifo_rd_en,       -- in    std_logic;
        rd_data             => tx_fifo_rd_data,     -- out   std_logic_vector((FIFO_WIDTH - 1) downto 0);
        ready               => tx_fifo_ready,       -- out   std_logic;
        full                => tx_fifo_full,        -- out   std_logic;
        empty               => tx_fifo_empty        -- out   std_logic
    );

    fifo_rx_i0: entity work.fifo_sync
    generic map (
        DEVICE              => "7SERIES",
        FIFO_WIDTH          => RX_DATA_WIDTH,
        FIFO_DEPTH          => 2048,
        FIFO_READ_LATENCY   => 1
    )
    port map (
        clk                 => clk,                 -- in    std_logic;
        rst                 => rst,                 -- in    std_logic;
        wr_en               => uart_rd_valid_l,     -- in    std_logic;
        wr_data             => uart_rd_data_l,      -- in    std_logic_vector((FIFO_WIDTH - 1) downto 0);
        rd_en               => rx_fifo_rd_en,       -- in    std_logic;
        rd_data             => rx_fifo_rd_data,     -- out   std_logic_vector((FIFO_WIDTH - 1) downto 0);
        ready               => rx_fifo_ready,       -- out   std_logic;
        full                => rx_fifo_full,        -- out   std_logic;
        empty               => rx_fifo_empty        -- out   std_logic
    );

    skid_buffer_rx: entity work.skid_buffer
    generic map (
        DATA_WIDTH      => RX_DATA_WIDTH
    )
    port map (
        clk             => clk,                 -- in    std_logic;
        rst             => rst,                 -- in    std_logic;
        fifo_rd_data    => rx_fifo_rd_data,     -- in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        fifo_rd_en      => rx_fifo_rd_en,       -- out   std_logic := '0';
        fifo_full       => rx_fifo_full,        -- in    std_logic;
        fifo_empty      => rx_fifo_empty,       -- in    std_logic;
        fifo_ready      => rx_fifo_ready,       -- in    std_logic;
        rd_data         => uart_rd_data,        -- out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_valid        => uart_rd_valid,       -- out   std_logic := '0';
        rd_ready        => uart_rd_ready        -- in    std_logic
    );

end architecture structural;

