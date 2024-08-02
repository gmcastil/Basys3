library ieee;
use ieee.std_logic_1164.all;

entity uart_rx is
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;
        
        baud_tick       : in    std_logic;

        uart_rd_data    : out   std_logic_vector(7 downto 0);
        uart_rd_valid   : out   std_logic;
        uart_rd_ready   : in    std_logic;

        uart_rxd        : in    std_logic
    );

end entity uart_rx;

architecture behavioral of uart_rx is

begin

    uart_rd_valid       <= '0';
    uart_rd_data        <= x"AA";

end architecture behavioral;

