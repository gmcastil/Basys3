library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
    generic (
        -- Input clock frequency
        CLK_FREQ    : integer       := 100000000;
        -- Desired baud rate
        BAUD_RATE   : integer       := 115200 
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        uart_rd_data    : out   std_logic_vector(7 downto 0);
        uart_rd_valid   : out   std_logic;
        uart_rd_ready   : in    std_logic;

        uart_rxd        : in    std_logic
    );

end entity uart_rx;

architecture behavioral of uart_rx is

    -- Just support 1 start bit, 8 data bigts, no parity, and 1 stop bit for now
    constant RX_FRAME_LEN           : integer := 10;

    constant BAUD_DIVISOR           : integer   := CLK_FREQ / BAUD_RATE;

    -- Asynchronous serial input needs a couple of flip flops to synchronize
    -- to this domain
    signal  uart_rxd_q              : std_logic;
    signal  uart_rxd_qq             : std_logic;
    signal  uart_rxd_qqq            : std_logic;

    -- Clock the data into this register for now
    signal  rx_data_sr              : std_logic_vector((RX_FRAME_LEN - 1) downto 0);
    signal  rx_bit_cnt              : unsigned(3 downto 0);
    signal  baud_tick_cnt           : unsigned(15 downto 0);

    signal  rx_busy                 : std_logic;
    signal  rx_done                 : std_logic;

begin

    -- First, need to cross the input serial data stream into the native clock
    -- domain for this module
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                uart_rxd_q      <= '0';
                uart_rxd_qq     <= '0';
                uart_rxd_qqq    <= '0';
            else
                uart_rxd_q      <= uart_rxd;
                uart_rxd_qq     <= uart_rxd_q;
                uart_rxd_qqq    <= uart_rxd_qq;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rx_busy             <= '0';
                rx_done             <= '0';

                baud_tick_cnt       <= (others=>'0');
                rx_bit_cnt          <= (others=>'0');

                uart_rd_valid       <= '0';

            else
                -- Looking for the start bit
                if (rx_busy = '0') then
                    if (uart_rxd_qq = '1' and uart_rxd_qqq = '0') then
                        rx_busy             <= '1';
                        baud_tick_cnt       <= (others=>'0');
                        rx_bit_cnt          <= (others=>'0');
                        -- Load whatever was captured as the start bit into the bottom
                        -- of the shift register. Should always be a 0 since this was fired on the
                        -- falling edge
                        rx_data_sr(0)       <= uart_rxd_qqq;
                    end if;
                    -- FIXME
                    uart_rd_valid       <= '0';
                else
                    -- Everything is gated off the baud tick equaling half of the baud rate
                    if ( baud_tick_cnt = (to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length) srl 1) ) then
                        if ( rx_done = '1' ) then
                            rx_busy             <= '0';
                            rx_done             <= '0';
                            rx_bit_cnt          <= (others=>'0');
                            -- Data has been received and we can strobe valid (for now) - this needs to
                            -- go somewhere else so we. FIXME WITH A FIFO!
                            uart_rd_data        <= rx_data_sr((RX_FRAME_LEN - 2) downto 1);
                            uart_rd_valid       <= '1';
                        else
                            -- SHift in next the next data bit
                            rx_data_sr(9 downto 1)  <= rx_data_sr(8 downto 0);
                            rx_data_sr(0)           <= uart_rxd_qqq;
                            if (rx_bit_cnt = RX_FRAME_LEN) then
                                rx_done             <= '1';
                            else
                                rx_done             <= '0';
                                rx_bit_cnt          <= rx_bit_cnt + 1;
                            end if;
                            -- FIXME
                            uart_rd_valid       <= '0';
                        end if;
                    else
                        if ( baud_tick_cnt = BAUD_DIVISOR ) then
                            baud_tick_cnt       <= (others=>'0');
                        else
                            baud_tick_cnt       <= baud_tick_cnt + 1;
                        end if
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

