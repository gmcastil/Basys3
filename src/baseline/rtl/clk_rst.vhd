library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity clk_rst is
    generic (
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

    signal rst_100m00_chain     : std_logic_vector((RST_LENGTH - 1) downto 0);

begin

    -- No need for clocking resources yet, so we just create the 100Mhz from the
    -- input clock. Note that this will still instantiate an IBUFG between the
    -- output of the IBUF and the clock pin of a flip flop.  The 7-Series does
    -- not have an IBUFG primitive in the libraries guide. If a future use case
    -- adds an MMCM, the IBUFG should not be inserted between the clock input
    -- pin and the IBUF (or at least, almost certainly not, unless there is
    -- logic that requires the clock prior to the MMCM).
    clk_100m00      <= clk_ext;

    -- Create a power on reset for the 100MHz domain
    rst_100m00_chain(0)     <= '0';
    rst_100m00              <= rst_100m00_chain(RST_LENGTH - 1);

    g_rst_100m00: for i in 1 to (rst_100m00_chain'length - 1) generate
    begin
        FDPE_i: FDPE
        generic map (
            INIT    => '1'
        )
        port map (
            Q       => rst_100m00_chain(i),
            C       => clk_100m00,
            CE      => '1',
            PRE     => rst_ext,
            D       => rst_100m00_chain(i - 1)
        );
    end generate g_rst_100m00;

end architecture structural;
