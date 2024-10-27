library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is
    generic (
        DEVICE              : string            := "7SERIES";
        CLK_FREQ            : integer           := 100000000;
        DEBUG_ILA           : boolean           := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic
    );

end entity uart_core;

architecture structural of uart_core is

begin

    -- Interrupt processing

    -- Baud rate generator

    -- RX FIFO

    -- TX FIFO

    -- UART RX

    -- UART TX

end architecture structural;
