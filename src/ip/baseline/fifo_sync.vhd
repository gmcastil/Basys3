library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xpm;
use xpm.vcomponents.all;

entity fifo_sync is
    generic (
        DEVICE              : string        := "7SERIES";
        -- Symmetric read and write ports
        FIFO_WIDTH          : natural       := 32;
        -- Choice for FIFO depth will impact synthesized results
        FIFO_DEPTH          : natural       := 2048;
        -- Number of output register stages in the read data path (1 to 100) since this components
        -- does not support first-word fallthrough behavior (FWFT)
        FIFO_READ_LATENCY   : natural       := 1
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;
        wr_en               : in    std_logic;
        wr_data             : in    std_logic_vector((FIFO_WIDTH - 1) downto 0);
        rd_en               : in    std_logic;
        rd_data             : out   std_logic_vector((FIFO_WIDTH - 1) downto 0);
        ready               : out   std_logic;
        full                : out   std_logic;
        empty               : out   std_logic
    );

end entity fifo_sync;

architecture structural of fifo_sync is


    signal fifo_rst_done            : std_logic := '0';
    signal rd_rst_busy              : std_logic;
    signal wr_rst_busy              : std_logic;

begin

    ready       <= fifo_rst_done;

    -- The reset requirements for the XPM FIFO macros are significantly easier to manage than
    -- earlier components like the FIFO_SYNC_MACRO. Here we just wait until both the read and write
    -- busy signals are no longer asserted and then register that comparison as the ready signal
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                fifo_rst_done       <= '0';
            else
                if (rd_rst_busy = '0' and wr_rst_busy = '0') then
                    fifo_rst_done       <= '1';
                else
                    fifo_rst_done       <= '0';
                end if;
            end if;
        end if;
    end process;

    xpm_fifo_gen: if (DEVICE = "7SERIES") generate
    begin
        -- For 7-series, we use a very simple, minimally configured FIFO with none of the advanced
        -- features such as read and write counts, programmable full or empty flags, etc. See UG953 for
        -- more details.
        XPM_FIFO_SYNC_i0: XPM_FIFO_SYNC
        generic map (
            CASCADE_HEIGHT          => 0,
            DOUT_RESET_VALUE        => "0",
            ECC_MODE                => "no_ecc",
            EN_SIM_ASSERT_ERR       => "warning",
            FIFO_MEMORY_TYPE        => "block",
            FIFO_READ_LATENCY       => FIFO_READ_LATENCY,
            FIFO_WRITE_DEPTH        => FIFO_DEPTH,
            FULL_RESET_VALUE        => 0,
            PROG_EMPTY_THRESH       => 10,
            PROG_FULL_THRESH        => 10,
            RD_DATA_COUNT_WIDTH     => 1,
            READ_DATA_WIDTH         => FIFO_WIDTH,
            READ_MODE               => "std",
            SIM_ASSERT_CHK          => 1,
            USE_ADV_FEATURES        => "0000",
            WAKEUP_TIME             => 0,
            WRITE_DATA_WIDTH        => FIFO_WIDTH,
            WR_DATA_COUNT_WIDTH     => 1
        )
        port map (
            almost_empty            => open,
            almost_full             => open,
            data_valid              => open,
            dbiterr                 => open,
            dout                    => rd_data,
            empty                   => empty,
            full                    => full,
            overflow                => open,
            prog_empty              => open,
            prog_full               => open,
            rd_data_count           => open,
            rd_rst_busy             => rd_rst_busy,
            sbiterr                 => open,
            underflow               => open,
            wr_ack                  => open,
            wr_data_count           => open,
            wr_rst_busy             => wr_rst_busy,
            din                     => wr_data,
            injectdbiterr           => '0',
            injectsbiterr           => '0',
            rd_en                   => rd_en,
            rst                     => rst,
            sleep                   => '0',
            wr_clk                  => clk,
            wr_en                   => wr_en
        );
    end generate xpm_fifo_gen;
 
end architecture structural;

