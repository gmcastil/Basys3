library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library unimacro;
use unimacro.vcomponents.all;

entity fifo_sync is
    generic (
        DEVICE          : string        := "7SERIES";
        -- FIFO parameters are related by the desired DATA_WIDTH, FIFO depth, and
        -- desired primitive:
        --
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
        --
        DATA_WIDTH      : integer       := 32;
        FIFO_SIZE       : string        := "36Kb";
        -- Enable FIFO output register
        DO_REG          : integer       := 1
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;
        wr_en           : in    std_logic;
        wr_data         : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_en           : in    std_logic;
        rd_data         : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        ready           : out   std_logic;
        full            : out   std_logic;
        empty           : out   std_logic
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
    signal rst_done                 : std_logic := '0';

begin

    ready   <= rst_done;

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                fifo_rst        <= '0';
                rst_done        <= '0';
                fifo_rst_cnt    <= RST_HOLD_CNT;
            else
                if (rst_done = '0') then
                    -- A FIFO reset sequence is complete when the write and read enable signals
                    -- have been deasserted prior to assertion of a reset and have remained deasserted
                    -- for RST_HOLD_CNT clocks
                    if (wr_en = '0' and rd_en = '0' and (fifo_rst_cnt = 0) ) then
                        rst_done        <= '1';
                    else
                        rst_done        <= '0';
                    end if;

                    -- If either read or write enable are asserted during the reset hold sequence, we
                    -- deassert the reset that we were trying to perform and start all over again.
                    if (wr_en = '1' or rd_en = '1') then
                        fifo_rst_cnt    <= RST_HOLD_CNT;
                        fifo_rst        <= '0';
                    else
                        fifo_rst_cnt    <= fifo_rst_cnt - 1;
                        fifo_rst        <= '1';
                    end if;

                else
                    fifo_rst        <= '0';
                    rst_done        <= '1';
                    fifo_rst_cnt    <= RST_HOLD_CNT;
                end if;
            end if;
        end if;
    end process;

    g_fifo_sync: if (DEVICE = "7SERIES") generate
    begin
        -- For 7-Series (e.g., Artix-7 or ZYNQ-7000) we use the device macro instantiation template
        -- from Vivado as described in UG953. Note that the Vivado 2024.1 VHDL template omits the
        -- `DO_REG` optional output register generic, which is a rather significant oversight. Let
        -- this be a learning experience to never trust the tool or documentation templates in
        -- actual RTL - go read the source code or the component declaration!
        FIFO_SYNC_MACRO_inst: FIFO_SYNC_MACRO
        generic map (
            ALMOST_FULL_OFFSET      => X"0080",
            ALMOST_EMPTY_OFFSET     => X"0080", 
            DATA_WIDTH              => DATA_WIDTH,
            DEVICE                  => "7SERIES",
            DO_REG                  => 1,
            FIFO_SIZE               => FIFO_SIZE
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
            RDEN                    => rd_en,       -- 1-bit input read enable
            RST                     => fifo_rst,    -- 1-bit input reset
            WREN                    => wr_en        -- 1-bit input write enable
        );
    end generate g_fifo_sync;

end architecture structural;

