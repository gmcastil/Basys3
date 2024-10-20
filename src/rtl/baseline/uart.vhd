library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic (
        -- Target device
        DEVICE              : string        := "7SERIES";
        -- Input clock frequency
        CLK_FREQ            : integer       := 100000000;
        -- Desired baud rate
        BAUD_RATE           : integer       := 115200;
        UART_DEBUG          : string        := "false"
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        uart_ready          : out   std_logic;

        uart_rd_data        : out   std_logic_vector(7 downto 0);
        uart_rd_valid       : out   std_logic;
        uart_rd_ready       : in    std_logic;

        uart_wr_data        : in    std_logic_vector(7 downto 0);
        uart_wr_valid       : in    std_logic;
        uart_wr_ready       : out   std_logic;

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
    constant TX_DATA_WIDTH          : natural := 8;
    constant RX_DATA_WIDTH          : natural := 8;

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

    -- The UART is ready to send and receive data once we're out of reset
    -- and the RX and TX FIFO are ready.  There is some internal housekeeping that
    -- Xilinx FIFOs have which creates a gap between when the reset is deasserted
    -- and the FIFO wrapper is actually ready to receive data.
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                uart_ready          <= '0';
                uart_rd_ready_l     <= '0';
            else
                -- We can read from UART RX when the read FIFO is ready
                uart_rd_ready_l     <= rx_fifo_ready;

                -- External ready is asserted when both RX and TX are ready
                if (rx_fifo_ready = '1' and tx_fifo_ready = '1') then
                    uart_ready          <= '1';
                else
                    uart_ready          <= '0';
                end if;

            end if;
        end if;
    end process;

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

    -- The RX and TX FIFO are each configured as standard FIFO primitives (i.e., not first-word
    -- fall-through) and each has the internal output register enabled, so there are two clocks of
    -- latency between when the read enable is asserted and data is available at the FIFO output
    fifo_tx_i0: entity work.fifo_sync
    generic map (
        DEVICE          => DEVICE,
        FIFO_WIDTH      => TX_DATA_WIDTH,
        FIFO_SIZE       => "18Kb",
        FWFT            => false,
        DO_REG          => 0,
        DEBUG           => false
    )
    port map (
        clk             => clk,
        rst             => rst,
        wr_en           => tx_fifo_wr_en,
        wr_data         => tx_fifo_wr_data,
        rd_en           => tx_fifo_rd_en,
        rd_data         => tx_fifo_rd_data,
        ready           => tx_fifo_ready,
        full            => tx_fifo_full,
        empty           => tx_fifo_empty
    );

    fifo_rx_i0: entity work.fifo_sync
    generic map (
        DEVICE          => DEVICE,
        FIFO_WIDTH      => RX_DATA_WIDTH,
        FIFO_SIZE       => "18Kb",
        FWFT            => false,
        DO_REG          => 0,
        DEBUG           => false
    )
    port map (
        clk             => clk,
        rst             => rst,
        wr_en           => uart_rd_valid_l,
        wr_data         => uart_rd_data_l,
        rd_en           => rx_fifo_rd_en,
        rd_data         => rx_fifo_rd_data,
        ready           => rx_fifo_ready,
        full            => rx_fifo_full,
        empty           => rx_fifo_empty
    );

    skid_buffer_rx: entity work.skid_buffer
    generic map (
        DATA_WIDTH      => RX_DATA_WIDTH
    )
    port map (
        clk             => clk,
        rst             => rst,
        fifo_rd_data    => rx_fifo_rd_data,
        fifo_rd_en      => rx_fifo_rd_en,
        fifo_full       => rx_fifo_full,
        fifo_empty      => rx_fifo_empty,
        fifo_ready      => rx_fifo_ready,
        rd_data         => uart_rd_data,
        rd_valid        => uart_rd_valid,
        rd_ready        => uart_rd_ready
    );

end architecture structural;

