-- Contains all FIFO logic and data between input data and UART core
-- Notional design for now since I"m not sure what the pipe is going to look like yet, so this might
-- be generic between the TX and RX side or it might become a TX FIFO module only (and then need a
-- variant to creater the RX side)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO name changed for consistency?
entity uart_sync_fifo is
    generic (
        DEVICE              : string    := "7SERIES",
        FIFO_SIZE           : string    := "18Kb"
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        parity              : in    std_logic_vector(1 downto 0);
        char                : in    std_logic_vector(1 downto 0);
        nbstop              : in    std_logic_vector(1 downto 0);

        tx_data             : in    std_logic_vector(7 downto 0);
        tx_data_valid       : in    std_logic;
        tx_data_ready       : out   std_logic;

end entity uart_sync_fifo;

architecture structural of uart_core is

    -- Enable the internal FIFO output register for timing purposes
    -- (affects the skid buffer and the FIFO output as well).
    constant DO_REG         : natural := 1;

begin

    fifo_tx_i0: entity work.fifo_sync
    generic map (
        DEVICE          => DEVICE,
        FIFO_WIDTH      => 8,
        FIFO_SIZE       => FIFO_SIZE,
        FWFT            => false,
        DO_REG          => DO_REG,
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

    skid_buffer_tx: entity work.skid_buffer
    generic map (
        DATA_WIDTH      => 8,
        DO_REG          => DO_REG
    )
    port map (
        clk             => clk,
        rst             => rst,
        fifo_rd_data    => tx_fifo_rd_data,
        fifo_rd_en      => tx_fifo_rd_en,
        fifo_empty      => tx_fifo_empty,
        fifo_ready      => tx_fifo_ready,
        rd_data         => tx_data,
        rd_valid        => tx_valid,
        rd_ready        => tx_ready
    );

end architecture structural;
