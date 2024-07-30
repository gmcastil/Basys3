library ieee;
use ieee.std_logic_1164.all;

entity clk_rst is
    port (
        clk_ext             : in    std_logic;
        rst_ext             : in    std_logic;

        clk_100m00          : out   std_logic;
        rst_100m00          : out   std_logic
    );

end entity clk_rst;

architecture structural of clk_rst is

begin

end architecture structural;
