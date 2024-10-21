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
        -- Enable loopback mode (data received on RXD will be sent out TXD)
        UART_MODE           : string        := "NORMAL"
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

        -- Interesting, for registers to start defining, add the RX and TX frame counts, errors,
        -- also add an indicator for NULL status or at least just wire out pins for status (e.g.,
        -- some higher level system register map or soemthing)  I can see wanting to NULL out the
        -- UART, not have to include the registers that it contains, and then wirtin gthe UART
        -- status that it was built with out to a system register or something
        -- uart_status         : out   std_logic_vector(31 downto 0);

        uart_rxd            : in    std_logic;
        uart_txd            : out   std_logic
    );

end entity uart;

architecture structural of uart is

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

    -- Local UART signals
    signal uart_rd_data_l           : std_logic_vector((RX_DATA_WIDTH - 1) downto 0);
    signal uart_rd_valid_l          : std_logic;
    signal uart_rd_ready_l          : std_logic;

    signal uart_wr_data_l           : std_logic_vector((TX_DATA_WIDTH - 1) downto 0);
    signal uart_wr_valid_l          : std_logic;
    signal uart_wr_ready_l          : std_logic;

    -- RX registers
    signal rx_ready                 : std_logic;
    signal rx_overflow              : std_logic;
    signal rx_frame_err             : unsigned(31 downto 0);
    signal rx_frame_cnt             : unsigned(31 downto 0);

    -- TX registers
    signal tx_frame_cnt             : unsigned(31 downto 0);

begin

    g_uart_ports: if (UART_MODE = "NULL") generate

        uart_rd_data        <= (others=>'0');
        uart_rd_valid       <= '0';
        uart_wr_ready       <= '0';

    elsif (UART_MODE = "LOOPBACK") generate

        uart_rd_data        <= (others=>'0');
        uart_rd_valid       <= '0';
        uart_rd_ready_l     <= uart_wr_ready_l;

        uart_wr_data_l      <= uart_rd_data_l;
        uart_wr_valid_l     <= uart_rd_valid_l;
        uart_wr_ready       <= '0';

    elsif (UART_MODE = "NORMAL") generate

        uart_wr_data_l      <= uart_wr_data;
        uart_wr_valid_l     <= uart_wr_valid;
        uart_wr_ready       <= uart_wr_ready_l;

        uart_rd_data        <= uart_rd_data_l;
        uart_rd_valid       <= uart_rd_valid_l;
        uart_rd_ready_l     <= uart_rd_ready;

    end generate g_uart_ports;

    -- UART components only get instantiated when the UART was synthesized in loopback or normal
    -- mode, but the ports get hooked up differently.  If we are nulling out the UART, then
    -- obviously don't instantiate anything.
    g_uart_comps: if (UART_MODE = "LOOPBACK" or UART_MODE = "NORMAL") generate

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
            CLK_FREQ            => CLK_FREQ,
            BAUD_RATE           => BAUD_RATE,
            DEVICE              => DEVICE,
            FIFO_SIZE           => "18Kb"
        )
        port map (
            clk                 => clk,
            rst                 => rst,
            rd_data             => uart_rd_data_l,
            rd_valid            => uart_rd_valid_l,
            rd_ready            => uart_rd_ready_l,
            rx_ready            => rx_ready,
            rx_overflow         => rx_overflow,
            rx_frame_cnt        => rx_frame_cnt,
            rx_frame_err        => rx_frame_err,
            uart_rxd            => uart_rxd
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

    end generate g_uart_comps;

end architecture structural;

