library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

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
        DO_REG              : natural       := 0;
        -- Enable debug output for simulation purposes
        DEBUG               : boolean       := false
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

    -- Print out a failure message
    procedure print_failure(
        msg         : in string
    ) is
    begin
        assert false
        report "Failure: " & msg
        severity failure;
    end procedure;

    -- Print out FIFO generics and configuration constants for debugging purposes
    procedure print_debug_info(
        device              : in string;
        fifo_width          : in natural;
        fifo_size           : in string;
        do_reg              : in natural;
        fifo_mode           : in string;
        data_width          : in natural;
        data_port_width     : in natural;
        parity_port_width   : in natural
    ) is
        variable msg : line;
    begin
        -- Building a single message string so that the simulator reports everything at the same
        -- instance without separating them by delta cycles
        write(msg, string'("Debug: DEVICE = " & device));
        write(msg, string'(LF & "Debug: FIFO_SIZE = " & fifo_size));
        write(msg, string'(LF & "Debug: FIFO_WIDTH = " & integer'image(fifo_width)));
        write(msg, string'(LF & "Debug: DO_REG = " & integer'image(do_reg)));
        write(msg, string'(LF & "Debug: FIFO_MODE = " & fifo_mode));
        write(msg, string'(LF & "Debug: DATA_WIDTH = " & integer'image(data_width)));
        write(msg, string'(LF & "Debug: DATA_PORT_WIDTH = " & integer'image(data_port_width)));
        write(msg, string'(LF & "Debug: PARITY_PORT_WIDTH = " & integer'image(parity_port_width)));

        -- Now write it to stdout
        writeline(output, msg);

    end procedure;

    -- Determine FIFO mode value based on the desired user FIFO size and FIFO width.
    function get_fifo_mode(
        fifo_size   : in string;
        fifo_width  : in natural
    ) return string is
    begin
        if (fifo_size = "36Kb") then
            if (fifo_width > 36 and fifo_width <= 72) then
                return "FIFO36_72";
            else
                return "FIFO36";
            end if;
        else
            if (fifo_width > 18 and fifo_width <= 36) then
                return "FIFO18_36";
            else
                return "FIFO18";
            end if;
        end if;
    end function;

    -- Determine DATA_WIDTH FIFO generic based on desired top-level FIFO width. The DATA_WIDTH
    -- generic to the FIFO primitives fundamentally determines the width that the BRAM should be
    -- configured to operate at.  This is why FIFO depth is dependent upon the choice of this
    -- generic. This is not entirely clear from the documentation. The Xilinx generic name is
    -- terrible - it should really be called the BRAM_DATA_WIDTH or something like that, but to
    -- avoid even more confusion, I'm sticking with the nomenclature that they use.
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
            when 37 to 72   => data_width := 72;
                if fifo_size = "36Kb" then
                    data_width := 72;
                else
                    print_failure("FIFO width cannot exceed 36 for FIFO18E1");
                    data_width := 0;
                end if;
            when others     =>
                print_failure("FIFO width cannot exceed 72 for FIFO36E1 or 36 for FIFO18E1");
                data_width := 0;
        end case;
        return data_width;
    end function;

    -- Returns the width of the input and output data port to the FIFO primitive
    function get_data_port_width(
        fifo_size : in string
    ) return natural is
    begin
        if (FIFO_SIZE = "36Kb") then
            return 64;
        else
            return 32;
        end if;
    end function;

    -- Returns the width of the input and output parity port to the FIFO primitive
    function get_parity_port_width(
        fifo_size : in string
    ) return natural is
    begin
        if (FIFO_SIZE = "36Kb") then
            return 8;
        else
            return 4;
        end if;
    end function;

    -- Determines the number of parity bits required to represent FIFO_WIDTH bits at the input to
    -- the FIFO primitive.  If the value is zero, then no parity is required. This function
    -- implicitly determines whether or not FIFO_WIDTH is such that we only need to use the data
    -- port of the FIFO primitive or whether parity is required AND if required, how many bits are
    -- required.  For comparison purposes, the Xilinx UNIMACRO library has a separate function to
    -- determine if a particular width requires data or both data and parity bits.
    function get_parity_width(
        fifo_width  : in natural
    ) return natural is
        variable parity_width : natural;
    begin
        case fifo_width is
            -- For 0-4 use 4-bit data width, no parity
            -- For 5-8 use 8-bit data width, no parity
            when 9          => parity_width := 1;
            -- For 10-16 use 16-bit data width, no parity
            when 17         => parity_width := 1;
            when 18         => parity_width := 2;
            -- For 19-32 use 32-bit data width, no parity
            when 33         => parity_width := 1;
            when 34         => parity_width := 2;
            when 35         => parity_width := 3;
            -- For 36-64 use 64-bit data width, no parity
            when 65	        => parity_width := 1;
            when 66	        => parity_width := 2;
            when 67	        => parity_width := 3;
            when 68	        => parity_width := 4;
            when 69	        => parity_width := 5;
            when 70	        => parity_width := 6;
            when 71	        => parity_width := 7;
            when 72	        => parity_width := 8;
            -- For the indicated ranges, no parity bits are used
            when others     => parity_width := 0;
        end case;
        return parity_width;
    end function;

    -- FIFO18 and FIFO36 generics (see UG953 for details)
    constant FIFO_MODE              : string    := get_fifo_mode(FIFO_SIZE, FIFO_WIDTH);
    constant DATA_WIDTH             : natural   := get_data_width(FIFO_SIZE, FIFO_WIDTH);

    -- Actual physical data and parity port widths to the FIFO primitive - these are fixed at either
    -- of the two sizes based upon the FIFO primitive.  However, based upon the BRAM configuration
    -- which is determined by the misleadingly named DATA_WIDTH generic, only a subset of the data
    -- port will actually be used (e.g., DATA_WIDTH = 4 with FIFO_SIZE = 36Kb will only use 4 of the
    -- available 64-bits on the data bus).  The parity port is treated similarly, but for many
    -- desired FIFO_WIDTH values will not be used.
    constant DATA_PORT_WIDTH        : natural   := get_data_port_width(FIFO_SIZE);
    constant PARITY_PORT_WIDTH      : natural   := get_parity_port_width(FIFO_SIZE);

    -- Number of actual bits of parity required to represent FIFO_WIDTH bits. If zero, no parity is
    -- required
    constant PARITY_WIDTH           : natural   := get_parity_width(FIFO_WIDTH);

    -- Number of clocks to hold the FIFO reset past the deassertion of the external reset. Xilinx
    -- FIFO primitives have very specific requirements for reset (which are ignored by everyone,
    -- hence newer macros that do it transparently). See 'FIFO Operations' in UG473 for details.
    constant RST_HOLD_CNT           : unsigned(3 downto 0) := x"5";

    signal fifo_rst                 : std_logic := '1';
    signal fifo_rst_cnt             : unsigned(3 downto 0) := RST_HOLD_CNT;

    -- Output register clock enable and reset
    signal regce                    : std_logic;
    signal regrst                   : std_logic;

    -- These are the actual FIFO input signals, but we will need to populate them appropriately
    -- later based on the effective data and parity port widths.
    signal fifo_wr_data             : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_wr_parity           : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_data             : std_logic_vector((DATA_PORT_WIDTH - 1) downto 0);
    signal fifo_rd_parity           : std_logic_vector((PARITY_PORT_WIDTH - 1) downto 0);

begin

    -- In general, we assume that all generics are provided with acceptable values to make functions
    -- simpler and easier to understand. Conditionals are all written assuming 18Kb is the default
    -- size.  Rather than checking in every function for every combination of generics, we instead
    -- perform assertions here and then charge ahead with the knowledge the instance has been
    -- configured appropriately.

    -- Assert FIFO size was provided correctly
    assert (FIFO_SIZE = "18Kb" or FIFO_SIZE = "36Kb")
        report "Error: Invalid FIFO_SIZE supplied. " &
            "Desired FIFO primitive must be 18Kb or 36Kb."
        severity error;

    -- Different assertions depending upon the FIFO primitive in use
    g_asserts: if (FIFO_SIZE = "36Kb") generate
    begin
        assert(FIFO_WIDTH > 0 and FIFO_WIDTH <= 72)
        report "Error: Invalid FIFO_WIDTH supplied. " &
            "Desired FIFO width must be between 1 and 72-bits for 36Kb"
        severity error;
    else generate
        assert (FIFO_WIDTH > 0 and FIFO_WIDTH <= 36)
        report "Error: Invalid FIFO_WIDTH supplied. " &
            "Desired FIFO width must be between 1 and 36-bits for 36Kb"
        severity error;
    end generate g_asserts;

    ready       <= fifo_rst;

    process
    begin
        if (DEBUG = true) then
            print_debug_info(
                DEVICE,
                FIFO_WIDTH, 
                FIFO_SIZE, 
                DO_REG, 
                FIFO_MODE, 
                DATA_WIDTH, 
                DATA_PORT_WIDTH, 
                PARITY_PORT_WIDTH
            );
        end if;
        wait;
    end process;

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
    regrst          <= '0' when (DO_REG = 1) else '1';

    -- There are three widths here and for the sake of my own sanity in the future, it makes sense to summarize them
    -- here:
    --
    -- FIFO_WIDTH - The physical port width of the desired FIFO at the top of the module
    -- DATA_PORT_WIDTH - The width of the actual port to the FIFO primitive
    -- PARITY_WIDTH - The number of parity bits actually used for a specific FIFO_WIDTH value
    g_fifo_wr: if (PARITY_WIDTH > 0) generate
    begin
        fifo_wr_data((DATA_PORT_WIDTH - 1) downto 0)    <= wr_data((DATA_PORT_WIDTH - 1) downto 0);
        fifo_wr_parity((PARITY_WIDTH - 1) downto 0)     <= wr_data((FIFO_WIDTH - 1) downto DATA_PORT_WIDTH);
    else generate
        fifo_wr_data((FIFO_WIDTH - 1) downto 0)         <= wr_data;
        fifo_wr_parity                                  <= (others=>'0'); 
    end generate g_fifo_wr;

    g_fifo_rd: if (PARITY_WIDTH > 0) generate
    begin
        rd_data             <= fifo_rd_parity((PARITY_WIDTH - 1) downto 0) & fifo_rd_data((DATA_PORT_WIDTH - 1) downto 0);
    else generate
        rd_data             <= fifo_rd_data((FIFO_WIDTH - 1) downto 0);
    end generate g_fifo_rd;

    -- What's that you say?  These don't look like the FIFO primitives you saw in the libraries
    -- guide?  That's because the libraries guide is wrong and apparently the crackhead that wrote
    -- the FIFO wrappers didn't read the source code.  The instantiation templates are not to be
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

