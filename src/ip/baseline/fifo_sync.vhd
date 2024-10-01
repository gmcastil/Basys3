library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity fifo_sync is
    generic (
        -- Support for 7SERIES and ULTRASCALE devices
        DEVICE              : string        := "7SERIES";
        -- Width of the input and output FIFO data ports at the top level of the entity and can be
        -- 1-36 when selecting 18Kb FIFO primitive and 1-72 for 36Kb primitives
        FIFO_WIDTH          : natural       := 8;
        -- Can be either 18Kb or 36Kb - note that the FIFO depth is implicitly defined
        -- by the choice of FIFO primitive and desired width of the data ports
        --
        -- FIFO_WIDTH | FIFO_SIZE | FIFO Depth
        -- ===========|===========|===========
        --   37-72    |  "36Kb"   |     512
        --   19-36    |  "36Kb"   |    1024
        --   19-36    |  "18Kb"   |     512
        --   10-18    |  "36Kb"   |    2048
        --   10-18    |  "18Kb"   |    1024
        --    5-9     |  "36Kb"   |    4096
        --    5-9     |  "18Kb"   |    2048
        --    1-4     |  "36Kb"   |    8192
        --    1-4     |  "18Kb"   |    4096
        --------------------------------------
        FIFO_SIZE           : string        := "18Kb";
        --
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

    -- Determine FIFO mode value based on the desired FIFO size and FIFO width
    function get_fifo_mode(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return string is
    begin
        if (fifo_size = "18Kb") then
            if (fifo_width > 36) then
                assert false
                report "Error: FIFO width cannot exceed 36 for FIFO18E1"
                severity error;
            elsif (fifo_width = 36) then
                return "FIFO18_36";
            else
                return "FIFO18";
            end if;
        elsif (fifo_size = "36Kb") then
            if (fifo_width > 72) then
                assert false
                report "Error: FIFO width cannot exceed 72 for FIFO36E1"
                severity error;
            elsif (fifo_width = 72) then
                return "FIFO36_72";
            else
                return "FIFO36";
            end if;
        else
            assert false
            report "Error: FIFO size must be either 18Kb or 36Kb"
            severity error;
        end if;
    end function;

    -- Determine DATA_WIDTH value based on desired FIFO size FIFO width
    function get_fifo_data_width(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return natural is
        variable data_width : natural;
    begin
        case fifo_width is
            when 0 to 4 =>
                data_width := 4;
            when 5 to 9 =>
                data_width := 9;
            when 10 to 18 =>
                data_width := 18;
            when 19 to 36 =>
                data_width := 36;
            when 37 to 72   =>
                if fifo_size = "36Kb" then
                    data_width := 72;
                else
                    assert false
                    report "Error: FIFO width cannot exceed 36 for FIFO18E1"
                    severity error;
                end if;
            when others     =>
                assert false
                report "Error: FIFO width cannot exceed 72 for FIFO36E1"
                severity error;
        end case;
        return data_width;
    end function;

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset.
    constant RST_HOLD_CNT       : unsigned(3 downto 0) := x"5";

    signal fifo_rst             : std_logic := '1';
    signal fifo_rst_cnt         : unsigned(3 downto 0) := RST_HOLD_CNT;

    constant FIFO_MODE          : string := get_fifo_mode(FIFO_SIZE, FIFO_WIDTH);
    constant DATA_WIDTH         : natural := get_fifo_data_width(FIFO_SIZE, FIFO_WIDTH);

    -- Output register clock enable and reset
    signal regce                : std_logic;
    signal regrst               : std_logic;

    -- FIFO read and write data port widths are more complicated than just wiring up module ports
    signal fifo_rd_data         : std_logic_vector();
    signal fifo_rd_parity       : std_logic_vector();
    signal fifo_wr_data         : std_logic_vector();
    signal fifo_wr_parity       : std_logic_vector();

begin

    ready       <= fifo_rst;

    -- Per the 7-Series Memory Resources User Guide (UG473) section 'FIFO Operations', the
    -- asynchronous FIFO reset should be held high for five read and write clock cycles to ensure
    -- all internal states and flags are reset to the correct values.  During reset, the write and
    -- read enable signals should both be deasserted and remain deasserted until the reset sequence
    -- is complete.
    p_fifo_rst: process (clk)
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
    end process p_fifo_rst;

    -- This is where the FIFO_SYNC_MACRO from the Xilinx UNIMACRO simulation library is wrong
    -- and inadvertently holds the output register in reset when DO_REG is set.
    regce       <= '1' when (DO_REG = 1) else '0';
    regrst      <= '1' when (DO_REG = 0) else '1';

    g_fifo_7series: if DEVICE = "7SERIES" and FIFO_SIZE = "18Kb" generate
    begin

            FIFO18E1_i0: FIFO18E1
            generic map (
               ALMOST_EMPTY_OFFSET      => X"0080",
               ALMOST_FULL_OFFSET       => X"0080",
               DATA_WIDTH               => DATA_WIDTH,
               DO_REG                   => DO_REG,
               EN_SYN                   => TRUE,
               FIFO_MODE                => FIFO_MODE,
               FIRST_WORD_FALL_THROUGH  => FALSE,
               INIT                     => X"000000000",
               SIM_DEVICE               => "7SERIES",
               SRVAL                    => X"000000000"
            )
            port map (
               DO                       => fifo_rd_data,
               DOP                      => fifo_rd_parity,
               ALMOSTEMPTY              => open,
               ALMOSTFULL               => open,
               EMPTY                    => empty,
               FULL                     => full,
               RDCOUNT                  => open,
               RDERR                    => open,
               WRCOUNT                  => open,
               WRERR                    => open,
               RDEN                     => rd_en,
               REGCE                    => '1',
               RST                      => fifo_rst,
               RSTREG                   => '0',
               WRCLK                    => clk,
               WREN                     => wr_en,
               DI                       => fifo_wr_data,
               DIP                      => fifo_wr_parity
            );
        end generate;

end architecture structural;

