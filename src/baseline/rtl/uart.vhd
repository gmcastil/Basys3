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
        -- mode select:
        --   - loopback
        --   - flow control?
        --
        -- interrupt out

        uart_rxd            : in    std_logic;
        uart_txd            : out   std_logic
    );

end entity uart;

architecture structural of uart is

    signal baud_tick        : std_logic;

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
    
        uart_rd_data    => uart_rd_data,
        uart_rd_valid   => uart_rd_valid,
        uart_rd_ready   => uart_rd_ready,

        uart_rxd        => uart_rxd
    );

    uart_tx_i0: entity work.uart_tx
    port map (
        clk             => clk,
        rst             => rst,
    
        baud_tick       => baud_tick,
        
        uart_wr_data    => uart_wr_data,
        uart_wr_valid   => uart_wr_valid,
        uart_wr_ready   => uart_wr_ready,

        uart_txd        => uart_txd
    );

end architecture structural;

