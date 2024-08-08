library ieee;
use ieee.std_logic_1164.all;

entity clk_rst is
    generic (
        -- How many clocks to assert reset
        RST_LENGTH          : natural       := 10;
        NUM_CLOCKS          : integer       := 6
    );
    port (
        -- External clock, possibly from an oscillator
        clk_ext             : in    std_logic;
        -- External asynchronous reset, possibly from a switch or other source
        -- that needs debouncing
        rst_ext             : in    std_logic;

        sys_clk             : out   std_logic_vector((NUM_CLOCKS - 1) downto 0);
        sys_rst             : out   std_logic_vector((NUM_CLOCKS - 1) downto 0)
    );

end entity clk_rst;

architecture structural of clk_rst is


    -- 100Mhz output clock and synchronous reset
    signal clk_100m00           : std_logic;
    signal rst_100m00           : std_logic;

    -- Reset chain gets initialized to all 1
    signal rst_100m00_chain     : std_logic_vector((RST_LENGTH - 1) downto 0) := (others=>'1');

begin

    -- System clock and reset buses
    sys_clk(0)      <= clk_100m00;
    sys_rst(0)      <= rst_100m00;

    sys_clk((NUM_CLOCKS - 1) downto 1)  <= (others=>'0');
    sys_rst((NUM_CLOCKS - 1) downto 1)  <= (others=>'0');

    -- No need for clocking resources yet, so we just create the 100Mhz from the
    -- input clock. Note that this will still instantiate an IBUFG between the
    -- output of the IBUF and the clock pin of a flip flop.  The 7-Series does
    -- not have an IBUFG primitive in the libraries guide. If a future use case
    -- adds an MMCM, the IBUFG should not be inserted between the clock input
    -- pin and the IBUF (or at least, almost certainly not, unless there is
    -- logic that requires the clock prior to the MMCM).
    clk_100m00      <= clk_ext;

    -- Set the initial reset signal to 0 at the right end of the chain
    rst_100m00_chain(0)         <= '0';
    -- And output the leftmost value as the reset signal for the 100MHz clock domain
    rst_100m00                  <= rst_100m00_chain(RST_LENGTH - 1);

    -- This synthesizes to a chain of RST_LENGTH - 1 FDPE initialized to 1
    process(clk_100m00, rst_ext)
    begin
        if (rst_ext = '1') then
            -- Asynchronus reset, so set the entire chain to 1
            rst_100m00_chain((RST_LENGTH - 1) downto 1) <= (others=>'1');
        else
            if rising_edge(clk_100m00) then
                rst_100m00_chain((RST_LENGTH - 1) downto 1) <= rst_100m00_chain((RST_LENGTH - 2) downto 0);
            end if;
        end if;
    end process;

end architecture structural;
