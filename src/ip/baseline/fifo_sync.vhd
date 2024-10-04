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
        -- FIFO_WIDTH | FIFO_SIZE | BRAM Width | FIFO Depth
        -- ------------------------------------------------
        --    1 - 4   |   18Kb    |    4       |   4096
        --    1 - 4   |   36Kb    |    4       |   8192
        --    5 - 9   |   18Kb    |    8       |   2048
        --    5 - 9   |   36Kb    |    8       |   4096
        --   10 - 18  |   18Kb    |    16      |   1024
        --   10 - 18  |   36Kb    |    16      |   2048
        --   19 - 36  |   18Kb    |    32      |   512 
        --   19 - 36  |   36Kb    |    32      |   1024
        --   36 - 72  |   36Kb    |    64      |   512 
        --
        FIFO_SIZE           : string        := "18Kb";

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

    -- Print out an error message
    procedure print_error(
        msg         : in string
    ) is
    begin
        assert false
        report "Error: " & msg
        severity error;
    end procedure;

    -- Determine FIFO mode value based on the desired user FIFO size and FIFO width. Also checks to
    -- see that the FIFO_SIZE is a legitimate value (other functions all assume the user has
    -- provided the correct FIFO_SIZE string).
    function get_fifo_mode(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return string is
        variable fifo_mode  : string;
    begin
        if (fifo_size = "18Kb") then
            if (fifo_width > 36) then
                print_error("FIFO width cannot exceed 36 for FIFO18E1");
                fifo_mode := "none";
            elsif (fifo_width = 36) then
                fifo_mode := "FIFO18_36";
            else
                fifo_mode := "FIFO18";
            end if;
        elsif (fifo_size = "36Kb") then
            if (fifo_width > 72) then
                print_error("FIFO width cannot exceed 72 for FIFO36E1");
                fifo_mode := "none";
            elsif (fifo_width = 72) then
                fifo_mode := "FIFO36_72";
            else
                fifo_mode := "FIFO36";
            end if;
        else
            print_error("FIFO size must be either 18Kb or 36Kb");
            fifo_mode := "";
        end if;
        return fifo_mode;
    end function;

    -- Determine DATA_WIDTH FIFO generic based on desired top-level FIFO width. The DATA WIDTH
    -- generic to the FIFO primitive is the number of data and parity bits that will be interpreted
    -- as data
    function get_data_width(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return natural is
        variable data_width : natural;
    begin
        case fifo_width is
            when 0 to 4     => data_width := 4;
            when 5 to 9     => data_width := 9;
            when 10 to 18   => data_width := 18;
            when 19 to 36   => data_width := 36;
            when 37 to 72   =>
                if fifo_size = "36Kb" then
                    data_width := 72;
                else
                    print_error("FIFO width cannot exceed 36 for FIFO18E1");
                    data_width := 0;
                end if;
            when others     =>
                print_error("FIFO width cannot exceed 72 for FIFO36E1 or 36 for FIFO18E1");
                data_width := 0;
        end case;
        return data_width;
    end function;

    -- Determines the number of bits from the data port that are used as data
    function get_eff_data_width(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return natural is
        variable eff_data_width
    begin
        case fifo_width is
            when 0 to 4     => eff_data_width := 4;
            when 5 to 9     => eff_data_width := 8;
            when 10 to 18   => eff_data_width := 16;
            when 19 to 36   => eff_data_width := 32;
            when 37 to 72   =>
                if (fifo_size = "36Kb") then
                    eff_data_width := 64;
                else
                    print_error("FIFO width cannot exceed 36 for FIFO18E1");
                    eff_data_width := 0;
                end if;
            when others     =>
                print_error("FIFO width cannot exceed 72 for FIFO36E1 or 36 for FIFO18E1");
                eff_data_width := 0;
        end case;
        return eff_data_width;
    end function;

    -- The reason that we dont use 10 bits out of a 16-bit data bus is because that would kill the
    -- depth.  Instead, we use an 8-bit data bus and the 2 bits of parity. This is a bit of a drag
    -- for things like a 19-bit bus, where you have to use the 32-bit data port (which nerfs the
    -- depth) and then only use the bottom 16-bits of it and then 
    --
    -- Determines the number of bits from the parity port that are used as data
    function get_eff_parity_width(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return natural is
        variable eff_parity_width
    begin
        case fifo_width is
            when 0 to 4     => eff_parity_width := 0;
            when 5 to 9     => eff_parity_width := 1;
            when 10 to 18   => eff_parity_width := 2;
            when 19 to 36   => eff parity_width := 4;
            when 37 to 72   =>
                if (fifo_size = "36Kb") then
                    eff_parity_width := 8;
                else
                    print_error("FIFO width cannot exceed 36 for FIFO18E1");
                    eff_parity_width := 0;
                end if;
            when others     =>
                print_error("FIFO width cannot exceed 72 for FIFO36E1 or 36 for FIFO18E1");
                eff_parity_width := 0;
        end case
        return eff_parity_width;
    end function;


    constant FIFO_MODE              : string    := get_fifo_mode(FIFO_SIZE, FIFO_WIDTH);
    constant DATA_WIDTH             : natural   := get_data_width(FIFO_SIZE, FIFO_WIDTH);

    -- Actual physical data and parity port widths to the FIFO primitive
    constant DATA_PORT_WIDTH        : natural   := 64 when (FIFO_SIZE = "36Kb") else 32;
    constant PARITY_PORT_WIDTH      : natural   := 8 when (FIFO_SIZE = "36Kb") else 4;

    -- Maximum number of bits that can be used from the data and parity ports of the FIFO primitive
    constant EFF_DATA_PORT_WIDTH    : natural   := get_eff_data_width(FIFO_WIDTH);
    constant EFF_PARITY_PORT_WIDTH  : natural   := get_eff_parity_width(FIFO_WIDTH);

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset.
    constant RST_HOLD_CNT           : unsigned(3 downto 0) := x"5";

    signal fifo_rst                 : std_logic := '1';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;

    -- Output register clock enable and reset
    signal regce                    : std_logic;
    signal regrst                   : std_logic;

    -- FIFO read and write data port widths are more complicated than just wiring up module ports

    -- The FIFO primitives use the DATA_WIDTH generic to determine how deep a FIFO they can
    -- construct (probably by using the underlying BRAM more efficiently).  This is why we don't
    -- just concatenate the two buses together as a 36-bit or 72-bit data, downsize to whatever our
    -- desired width is, and then slice accordingly; it would affect the desired FIFO depth.  So,
    -- for a given top-level desired FIFO width, we need to calculate the actual number of bits to
    -- use from the input and output data ports (which are fixed at either 32 or 64-bits).  That
    -- choice for the actual number of data bits also determines the number of bits of the parity
    -- port to use.
    --
    -- So, as an example, imagine a desired FIFO_WIDTH of 9-bits and a FIFO_SIZE of "18Kb". This
    -- would be implemented with a DATA_WIDTH of 8, and then we would use 8 of the 32-bits of the
    -- FIFO data bus and 1 bit from the 4-bit parity bus.  Or, if we were using a "36Kb" FIFO_SIZE
    -- we would use the same dimensions, but out of a 64 and 8-bit data and parity bus.  This is
    -- further complicated in one way, which is the FIFO_MODE, which needs to be set to different
    -- values when we are at the upper end of the capacity (e.g., FIFO18_36 for 36-bits and
    -- FIFO36_72 for 72-bits).
    --
    -- These are the actual FIFO input signals, but we will need to populate them appropriately
    -- later based on the effective data and parity port widths.
    signal fifo_wr_data         : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_wr_parity       : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_data         : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_parity       : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);

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
    regce           <= '1' when (DO_REG = 1) else '0';
    regrst          <= '1' when (DO_REG = 0) else '1';

    -- What's that you say?  These don't look like the FIFO primitives you saw in the libraries
    -- guide?  That's because the libraries guide is wrong and apparently the crackheads that wrote
    -- the FIFO wrappers don't read their source code.  The instantiation templates are not to be
    -- trusted. You have to read the component definitions!!! 
    g_fifo_7series: if (DEVICE = "7SERIES") and (FIFO_SIZE = "18Kb") generate
    begin
        FIFO18E1_i0: FIFO18E1
        generic map (
            ALMOST_EMPTY_OFFSET         => X"0080",
            ALMOST_FULL_OFFSET          => X"0080",
            DATA_WIDTH                  => DATA_WIDTH,
            DO_REG                      => DO_REG,
            EN_SYN                      => true,
            FIFO_MODE                   => FIFO_MODE,
            FIRST_WORD_FALL_THROUGH     => false,
            INIT                        => X"000000000",
            IS_RDCLK_INVERTED           => '0',
            IS_RDEN_INVERTED            => '0',
            IS_RSTREG_INVERTED          => '0',
            IS_RST_INVERTED             => '0',
            IS_WRCLK_INVERTED           => '0',
            IS_WREN_INVERTED            => '0',
            SIM_DEVICE                  => "7SERIES",
            SRVAL                       => X"000000000"
        )
        port map (
            ALMOSTEMPTY                 => open,
            ALMOSTFULL                  => open,
            DO                          => fifo_rd_data,
            DOP                         => fifo_rd_parity,
            EMPTY                       => empty,
            FULL                        => full,
            RDCOUNT                     => open,
            RDERR                       => open,
            WRCOUNT                     => open,
            WRERR                       => open,
            DI                          => fifo_wr_data,
            DIP                         => fifo_wr_parity,
            RDCLK                       => clk,
            RDEN                        => rd_en,
            REGCE                       => regce,
            RST                         => rst,
            RSTREG                      => regrst,
            WRCLK                       => clk,
            WREN                        => wr_en
        );

    end generate;

end architecture structural;

