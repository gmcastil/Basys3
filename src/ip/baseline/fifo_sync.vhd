library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity fifo_sync is
    generic (
        -- Support for 7SERIES and ULTRASCALE devices
        DEVICE              : string        := "7SERIES";
        -- Symmetric read and write ports
        FIFO_WIDTH          : natural       := 8;
        -- Can be either 18Kb or 36Kb - note that the FIFO depth is implicitly defined by
        -- the choice of FIFO primitive and width of the data ports
        FIFO_SIZE           : string        := "18Kb";
        --
        -- The FIFO_SIZE and FIFO_WIDTH parameters deterine the depth provided by the FIFO.
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
        -- Enable output register
        DO_REG              : natural       := 0
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

    signal fifo_rst                 : std_logic := '1';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;

begin

    ready       <= fifo_rst;

    -- Per the 7-Series Memory Resources User Guide (UG473) section 'FIFO Operations', the
    -- asynchronous FIFO reset should be held high for five read and write clock cycles to ensure
    -- all internal states and flags are reset to the correct values.  During reset, the write and
    -- read enable signals should both be deasserted and remain deasserted until the reset sequence
    -- is complete.
    process (clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                fifo_rst            <= '1';
                fifo_rst_cnt        <= RST_HOLD_CNT;
           else
                if fifo_rst = '1' then
                    -- A FIFO reset sequence is complete when the write and read enable signals
                    -- have been deasserted prior to assertion of a reset and have remained deasserted
                    -- for RST_HOLD_CNT clocks
                    if wr_en = '0' and rd_en = '0' and fifo_rst_cnt = 0 then
                        fifo_rst            <= '0';
                    else
                        fifo_rst            <= '1'; 
                    end if;

                    -- If either read or write enable are asserted during the reset hold sequence, we
                    -- deassert the reset that we were trying to perform and start all over again.
                    if wr_en = '1' or rd_en = '1' then
                        fifo_rst_cnt        <= RST_HOLD_CNT;
                    else
                        fifo_rst_cnt        <= fifo_rst_cnt - 1;
                    end if;

                else
                    fifo_rst            <= '0';
                    fifo_rst_cnt        <= RST_HOLD_CNT;
                end if;
            end if;
        end if;
    end process;
 
end architecture structural;

