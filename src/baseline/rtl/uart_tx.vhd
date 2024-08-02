library ieee;
use ieee.std_logic_1164.all;

entity uart_tx is
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;
        
        baud_tick       : in    std_logic;

        uart_wr_data    : in    std_logic_vector(7 downto 0);
        uart_wr_valid   : in    std_logic;
        uart_wr_ready   : out   std_logic;

        uart_txd        : out   std_logic
    );

end entity uart_tx;

architecture behavioral of uart_tx is

begin

    uart_wr_ready   <= '0';
    uart_txd        <= '0';

end architecture behavioral;

