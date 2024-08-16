library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity fifo_sync is
    generic (
        DEVICE          : string        := "7SERIES";
        DATA_WIDTH      : natural       := 32;
        FIFO_SIZE       : string        := "36Kb";
        COUNT_WIDTH     : natural       := 10
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;
        wr_en           : in    std_logic;
        wr_data         : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_en           : in    std_logic;
        rd_data         : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        full            : out   std_logic;
        empty           : out   std_logic
    );

end entity fifo_sync;

architecture structural of fifo_sync is

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset.
    -- For example, when this is set to 5, the FIFO reset and its inputs will be held in the reset
    -- condition for an additional 5 clock cycles after the deassertion of the input reset.
    constant RST_HOLD_CNT           : unsigned(3 downto 0) := x"5";

    signal fifo_rst                 : std_logic := '1';
    signal fifo_rd_en               : std_logic := '0';
    signal fifo_wr_en               : std_logic := '0';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;

begin

    -- Per the 7-Series Memory Resources User Guide (UG473) the asynchronous reset should be held
    -- high for five read and write clock cycles to ensure all internal states and flags are reset to
    -- the correct values.  During reset, the write and read enable signals should both be
    -- deasserted.
    process(clk)
    begin
        if (rst = '1') then
            fifo_rst_cnt        <= RST_HOLD_CNT;

            fifo_rst            <= '1';
            fifo_rd_en          <= '0';
            fifo_wr_en          <= '0';
        else
            if (fifo_rst_cnt = 0) then
                fifo_rst_cnt    <= (others=>'0');

                fifo_rst        <= '0';
                fifo_rd_en      <= rd_en;
                fifo_wr_en      <= wr_en;

            else
                fifo_rst_cnt    <= fifo_rst_cnt - 1;

                fifo_rst        <= '1';
                fifo_rd_en      <= '0';
                fifo_wr_en      <= '0';
            end if;
        end if;
    end process;

    -- For 7-Series (e.g., Artix-7 or ZYNQ-7000) we use the device macro instantiation template
    -- from Vivado as described in UG953.

    -- FIFO_SYNC_MACRO: Synchronous First-In, First-Out (FIFO) RAM Buffer
    --                  Artix-7
    -- Xilinx HDL Language Template, version 2024.1

    -- Note -  This Unimacro model assumes the port directions to be "downto".
    --         Simulation of this model with "to" in the port directions could lead to erroneous results.

    -----------------------------------------------------------------
    -- DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width --
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

    FIFO_SYNC_MACRO_inst : FIFO_SYNC_MACRO
    generic map (
        DEVICE                  => "7SERIES",   -- Target Device: "VIRTEX5, "VIRTEX6", "7SERIES"
        ALMOST_FULL_OFFSET      => X"0080",     -- Sets almost full threshold
        ALMOST_EMPTY_OFFSET     => X"0080",     -- Sets the almost empty threshold
        DATA_WIDTH              => DATA_WIDTH,  -- Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
        FIFO_SIZE               => FIFO_SIZE    -- Target BRAM, "18Kb" or "36Kb"
    )
    port map (
        ALMOSTEMPTY             => open,        -- 1-bit output almost empty
        ALMOSTFULL              => open,        -- 1-bit output almost full
        DO                      => rd_data,     -- Output data, width defined by DATA_WIDTH parameter
        EMPTY                   => empty,       -- 1-bit output empty
        FULL                    => full,        -- 1-bit output full
        RDCOUNT                 => open,        -- Output read count, width determined by FIFO depth
        RDERR                   => open,        -- 1-bit output read error
        WRCOUNT                 => open,        -- Output write count, width determined by FIFO depth
        WRERR                   => open,        -- 1-bit output write error
        CLK                     => clk,         -- 1-bit input clock
        DI                      => wr_data,     -- Input data, width defined by DATA_WIDTH parameter
        RDEN                    => fifo_rd_en,  -- 1-bit input read enable
        RST                     => fifo_rst,    -- 1-bit input reset
        WREN                    => fifo_wr_en   -- 1-bit input write enable
    );
    -- End of FIFO_SYNC_MACRO_inst instantiation

end architecture structural;

