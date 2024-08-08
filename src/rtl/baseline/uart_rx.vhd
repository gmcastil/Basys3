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

    constant RX_START_BIT           : std_logic := '0';
    constant RX_STOP_BIT            : std_logic := '1';

    constant BAUD_DIVISOR   : integer   := CLK_FREQ / BAUD_RATE;

    -- Asynchronous serial input needs a couple of flip flops to synchronize
    -- to this domain
    signal  uart_rxd_q              : std_logic;
    signal  uart_rxd_qq             : std_logic;
    signal  uart_rxd_qqq            : std_logic;

    -- Clock the data into this register for now
    signal  rx_data_sr              : std_logic_vector((RX_FRAME_LEN - 1) downto 0);
    signal  rx_bit_cnt              : unsigned(3 downto 0);
    signal  tick_cnt                : unsigned(15 downto 0);

    signal  found_start             : std_logic;

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
                found_start         <= '0';

                tick_cnt            <= (others=>'0');
                rx_bit_cnt          <= (others=>'0');

            else
                -- Looking for the start bit
                if (found_start = '0') then
                    if (uart_rxd_qqq = '1' and uart_rxd_qq = '0') then
                        tick_cnt            <= (others=>'0');
                        found_start         <= '1';
                        rx_bit_cnt          <= rx_bit_cnt + 1;
                        -- Load whatever was captured as the start bit into the bottom
                        -- of the shift register
                        if (uart_rxd_qqq = RX_START_BIT) then
                            rx_data_sr(0)       <= uart_rxd_qqq;
                            -- this should always be a 0 since we fired this on the falling edge
                        end if;
                    end if;
                -- Sampling data bits
                elsif ( rx_bit_cnt <= (RX_FRAME_LEN - 2) ) then
                    if ( tick_cnt = (to_unsigned(BAUD_DIVISOR, rx_bit_cnt'length) srl 1) ) then
                        tick_cnt            <= (others=>'0');
                        rx_bit_cnt          <= rx_bit_cnt + 1;

                        -- Keep loading into the shift register
                        rx_data_sr(0)       <= uart_rxd_qqq;
                        rx_data_sr((RX_FRAME_LEN - 1) downto 1)
                                            <= rx_data_sr(RX_FRAME_LEN - 2 downto 0);
                    else
                        tick_cnt            <= tick_cnt + 1;
                        rx_bit_cnt          <= rx_bit_cnt;
                    end if;
                -- Sample the stop bit
                else
                    if ( tick_cnt = (to_unsigned(BAUD_DIVISOR, rx_bit_cnt'length) srl 1) ) then
                        tick_cnt            <= (others=>'0');

                        -- Capture the last bit we received
                        rx_data_sr(0)       <= uart_rxd_qqq;
    --                        if (uart_rxd_qqq = RX_STOP_BIT) then
                            -- basically need to handle the fact that we found the stop bit,
                            -- all the other bits in between the start and here
                            -- Then the qeustion becomes how to handle the fact that we've found
                            -- all the bits in the transmitted word, but the receiver might not be
                            -- ready yet.... i like the idea of a busy.  But, the right way to
                            -- handle this is eventually FIFOing somewhere:
                        rx_data_sr((RX_FRAME_LEN - 1) downto 1)
                                            <= rx_data_sr(RX_FRAME_LEN - 2 downto 0);

                        -- All done and can start on the next one
                        found_start         <= '0';
                        rx_bit_cnt          <= (others=>'0');
                    else
                        tick_cnt            <= tick_cnt + 1;
                        rx_bit_cnt          <= rx_bit_cnt;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

