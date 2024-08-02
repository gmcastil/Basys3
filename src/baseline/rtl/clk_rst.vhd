library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity clk_rst is
    generic (
        -- If desired, an IBUF can be inserted on the input clock
        ADD_CLK_IBUF        : boolean       := false;
        -- How many clocks to assert reset
        RST_LENGTH          : natural       := 10
    );
    port (
        -- External clock, possibly from an oscillator
        clk_ext             : in    std_logic;
        -- External asynchronous reset, possibly from a switch or other source
        -- that needs debouncing
        rst_ext             : in    std_logic;

        -- 100Mhz output clock and synchronous reset
        clk_100m00          : out   std_logic;
        rst_100m00          : out   std_logic
    );

end entity clk_rst;

architecture structural of clk_rst is

    signal rst_100m00_chain     : std_logic_vector(RST_LENGTH downto 0);

begin

    -- No need for clocking resources yet, so we just create the 100Mhz from the
    -- input clock. Note that this will still instantiate an IBUFG between the
    -- output of the IBUF and the clock pin of a flip flop.  The 7-Series does
    -- not have an IBUFG primitive in the libraries guide. If a future use case
    -- adds an MMCM, the IBUFG should not be inserted between the clock input
    -- pin and the IBUF (or at least, almost certainly not, unless there is
    -- logic that requires the clock prior to the MMCM).
    g_clk_ext: if ADD_CLK_IBUF generate
        IBUF_clk_ext: IBUF
        generic map (
            IBUF_LOW_PWR    => TRUE,
            IOSTANDARD      => "DEFAULT"
        )
        port map (
            I               => clk_ext,
            O               => clk_100m00
        );
    else generate
        clk_100m00          <= clk_ext;
    end generate g_clk_ext;

    -- Create a power on reset for the 100MHz domain
    g_rst_100m00: for i in 0 to (RST_LENGTH - 1) generate
        FDPE_i: FDPE
        generic map (
            INIT    => '1'
        )
        port map (
            Q       => rst_100m00_chain(i + 1),
            C       => clk_100m00,
            CE      => '1',
            PRE     => not rst_ext,
            D       => rst_100m00_chain(i)
        );
    end generate g_rst_100m00;

    rst_100m00_chain(0)     <= '0';
    rst_100m00              <= rst_100m00_chain(RST_LENGTH);

end architecture structural;
