library ieee;
use ieee.std_logic_1164.all;

entity baud_rate_gen is
    generic (
        CLK_FREQ        : integer       := 100000000;
        BAUD_RATE       : integer       := 115200
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        baud_tick       : out   std_logic
    );

end entity baud_rate_gen;

architecture behavioral of baud_rate_gen is

begin

    baud_tick       <= '0';

end architecture behavioral;

