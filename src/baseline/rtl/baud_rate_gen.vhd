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

    constant BAUD_DIVISOR   : integer   CLK_FREQ / BAUD_RATE;

    signal  tick_cnt        : integer;

begin

    process(clk)
        if rising_edge(clk) then
            if (rst = '1') then
                baud_tick       <= '0';
                tick_cnt        <= (others=>'0');
            else
                if ( tick_cnt = (BAUD_DIVISOR srl 1) ) then
                    baud_tick       <= not baud_tick;
                    tick_cnt        <= (others=>'0');
                else
                    baud_tick       <= baud_tick;
                    tick_cnt        <= tick_cnt + 1;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

