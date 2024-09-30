library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

library xpm;
use xpm.vcomponents.all;

entity fifo_sync is
    generic (
        DEVICE              : string        := "7SERIES";
        -- Symmetric read and write ports
        FIFO_WIDTH          : natural       := 8;
        -- Choice for FIFO depth will impact synthesized results (not applicable to 7-Series
        -- devices)
        FIFO_DEPTH          : natural       := 2048
        --
        -- The FIFO_SIZE parameter is used for 7-series devices to determine the built-in FIFO
        -- primitive to use and as such, there is a required relationship between the FIFO data
        -- width, depth, and counters (which are unused):
        --
        -----------------------------------------------------------------
        -- FIFO_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
        -- ===========|===========|============|=======================--
        --   37-72    |  "36Kb"   |     512    |         9-bit         --
        --   19-36    |  "36Kb"   |    1024    |        10-bit         --
        --   19-36    |  "18Kb"   |     512    |         9-bit         --
        --   10-18    |  "36Kb"   |    2048    |        11-bit         --
        --   10-18    |  "18Kb"   |    1024    |        10-bit         --
        --    5-9     |  "36Kb"   |    4096    |        12-bit         --
        --    5-9     |  "18Kb"   |    2048    |        11-bit         --
        --    1-4     |  "36Kb"   |    8192    |        13-bit         --
        --    1-4     |  "18Kb"   |    4096    |        12-bit         --
        -----------------------------------------------------------------
        --
        -- For now, I think I'm going to just leave this as 18Kb to try to get 
        -- FIFO_SIZE           : string        := "18Kb",
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

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset.
    constant RST_HOLD_CNT           : unsigned(3 downto 0) := x"5";

    -- Per the 7-Series Memory Resources User Guide (UG473) the asynchronous reset should be held
    -- high for five read and write clock cycles to ensure all internal states and flags are reset to
    -- the correct values.  During reset, the write and read enable signals should both be
    -- deasserted and remain deasserted until the reset sequence is complete.
    signal fifo_rst                 : std_logic := '0';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;
    signal fifo_rst_done            : std_logic := '0';

    signal rd_rst_busy              : std_logic;
    signal wr_rst_busy              : std_logic;

begin

    ready       <= fifo_rst_done;

    g_fifo_ultrascale: if (DEVICE = "ULTRASCALE") generate
    begin

        -- The reset requirements for the XPM FIFO macros are significantly easier to manage than
        -- earlier components like the FIFO_SYNC_MACRO. Here we just wait until both the read and write
        -- busy signals are no longer asserted and then register that comparison as the ready signal
        process(clk)
        begin
            if rising_edge(clk) then
                if (fifo_rst = '1') then
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

        -- For Ultrascale, we use a very simple, minimally configured FIFO with none of the advanced
        -- features such as read and write counts, programmable full or empty flags, etc. See UG953 for
        -- more details.
        XPM_FIFO_SYNC_i0: XPM_FIFO_SYNC
        generic map (
            CASCADE_HEIGHT          => 0,
            DOUT_RESET_VALUE        => "0",
            ECC_MODE                => "no_ecc",
            EN_SIM_ASSERT_ERR       => "warning",
            FIFO_MEMORY_TYPE        => "block",
            FIFO_READ_LATENCY       => 1,
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

    end generate g_fifo_ultrascale;

    g_fifo_7series: if (DEVICE = "7SERIES") generate
    begin

        process(clk)
        begin
            if rising_edge(clk) then
                if (rst = '1') then
                    fifo_rst            <= '0';
                    fifo_rst_done       <= '0';
                    fifo_rst_cnt        <= RST_HOLD_CNT;
               else
                    if (fifo_rst_done = '0') then
                        -- A FIFO reset sequence is complete when the write and read enable signals
                        -- have been deasserted prior to assertion of a reset and have remained deasserted
                        -- for RST_HOLD_CNT clocks
                        if (wr_en = '0' and rd_en = '0' and (fifo_rst_cnt = 0) ) then
                            fifo_rst_done        <= '1';
                        else
                            fifo_rst_done        <= '0';
                        end if;

                       -- If either read or write enable are asserted during the reset hold sequence, we
                       -- deassert the reset that we were trying to perform and start all over again.
                       if (wr_en = '1' or rd_en = '1') then
                           fifo_rst_cnt         <= RST_HOLD_CNT;
                           fifo_rst             <= '0';
                       else
                           fifo_rst_cnt         <= fifo_rst_cnt - 1;
                           fifo_rst             <= '1';
                       end if;

                   else
                       fifo_rst             <= '0';
                       fifo_rst_done        <= '1';
                       fifo_rst_cnt         <= RST_HOLD_CNT;
                    end if;
                end if;
            end if;
        end process;

        -- For 7-Series (e.g., Artix-7 or ZYNQ-7000) we use the device macro instantiation template
        -- from Vivado as described in UG953. Note that the Vivado 2024.1 VHDL template omits the
        -- `DO_REG` optional output register generic, which is a rather significant oversight. Let
        -- this be a learning experience to never trust the tool or documentation templates in
        -- actual RTL - go read the source code or the component declaration!
        FIFO_SYNC_MACRO_i0: FIFO_SYNC_MACRO
        generic map (
            ALMOST_FULL_OFFSET      => X"0080",
            ALMOST_EMPTY_OFFSET     => X"0080", 
            DATA_WIDTH              => FIFO_WIDTH, 
            DEVICE                  => "7SERIES",
            DO_REG                  => 1,
            FIFO_SIZE               => "18Kb"
        )
        port map (
            ALMOSTEMPTY             => open,
            ALMOSTFULL              => open, 
            DO                      => rd_data,
            EMPTY                   => empty,
            FULL                    => full,
            RDCOUNT                 => open,
            RDERR                   => open,
            WRCOUNT                 => open,
            WRERR                   => open,
            CLK                     => clk,
            DI                      => wr_data,
            RDEN                    => rd_en,
            RST                     => fifo_rst,
            WREN                    => wr_en
        );

    end generate g_fifo_7series;
 
end architecture structural;

