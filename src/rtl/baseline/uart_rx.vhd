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

        -- UART received data.  Zero buffering of data is performed by this module. Most normal
        -- applications would probably want to put a FIFO on this interface.
        uart_rd_data    : out   std_logic_vector(7 downto 0);
        uart_rd_valid   : out   std_logic;
        uart_rd_ready   : in    std_logic;

        -- Number of received frames since reset
        rx_frame_cnt    : out   unsigned(31 downto 0);
        -- Number of valid frames received when the external client was not
        -- ready (i.e., dropped frames)
        rx_frame_err    : out   unsigned(31 downto 0);

        -- Should map directly to an input pin
        uart_rxd        : in    std_logic
    );

end entity uart_rx;

architecture behavioral of uart_rx is

    -- Just support 1 start bit, 8 data bigts, no parity, and 1 stop bit for now
    constant RX_FRAME_LEN           : integer   := 10;

    -- Values for the start and stop bits (not the number of start or stop bits)
    constant RX_START_BIT           : std_logic := '0';
    constant RX_STOP_BIT            : std_logic := '1';

    constant BAUD_DIVISOR           : integer   := CLK_FREQ / BAUD_RATE;

    -- Asynchronous serial input needs a couple of flip flops to synchronize
    -- to this domain
    signal  uart_rxd_q              : std_logic;
    signal  uart_rxd_qq             : std_logic;
    signal  uart_rxd_qqq            : std_logic;

    -- Clock the data into this register for now
    signal  rx_data_sr              : std_logic_vector(7 downto 0);
    signal  rx_bit_cnt              : unsigned(3 downto 0);
    signal  baud_tick_cnt           : unsigned(15 downto 0);

    signal  rx_busy                 : std_logic;
    signal  found_start             : std_logic;

begin

    -- First, need to cross the input serial data stream into the native clock
    -- domain for this module
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                uart_rxd_q      <= '1';
                uart_rxd_qq     <= '1';
                uart_rxd_qqq    <= '1';
            else
                uart_rxd_q      <= uart_rxd;
                uart_rxd_qq     <= uart_rxd_q;
                uart_rxd_qqq    <= uart_rxd_qq;
            end if;
        end if;
    end process;

    -- Handle error and frame counts here
    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rx_frame_err        <= (others=>'0');
                rx_frame_cnt        <= (others=>'0');
            else
                if (uart_rd_valid = '1' and uart_rd_ready = '0') then
                    -- Frame errors occur if the UART has a valid data byte and the client is not
                    -- ready for it
                    rx_frame_err        <= rx_frame_err + 1;
                elsif (uart_rd_valid = '1' and uart_rd_ready = '1') then
                    rx_frame_cnt        <= rx_frame_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rx_busy             <= '0';

                baud_tick_cnt       <= (others=>'0');
                rx_bit_cnt          <= (others=>'0');
                found_start         <= '0';

                uart_rd_valid       <= '0';

            else
                -- Looking for the start bit
                if (rx_busy = '0') then
                    if (uart_rxd_qq = '0' and uart_rxd_qqq = '1') then
                        rx_busy             <= '1';
                        rx_bit_cnt          <= (others=>'0');

                        found_start         <= '0';
                        -- For the start bit, we set the counter to half the baud period
                        baud_tick_cnt       <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length) srl 1;

                    end if;
                    uart_rd_valid       <= '0';
                else
                    -- Capture the start bit half a baud period into the transmission and align subsequent samples to this
                    -- point. If we didn't capture a start bit, then back to the idle or not busy condition
                    if ( found_start = '0') then
                        -- When the half counter has expired, we're at the middle of the start bit
                        if ( baud_tick_cnt = 0 ) then
                            -- Unlike in the TX core, we do not bother storing the start and stop bits, we just let them
                            -- steer the control path and then store the actual data later
                            if ( uart_rxd_qqq = RX_START_BIT ) then
                                found_start         <= '1';
                                -- From this point on, we're going to sample everything one full baud period
                                -- apart
                                baud_tick_cnt       <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length);
                                rx_bit_cnt          <= to_unsigned(1, rx_bit_cnt'length);
                            else
                                -- Kick us out of looking for the start bit and back to idle
                                rx_busy             <= '0';
                            end if;
                        else
                            baud_tick_cnt       <= baud_tick_cnt - 1;
                        end if;
                    else
                        -- When the full counter has expired, we're at the middle of a data or stop bit
                        if ( baud_tick_cnt = 0 ) then
                            if ( rx_bit_cnt = to_unsigned(RX_FRAME_LEN - 1, rx_bit_cnt'length) ) then
                                if ( uart_rxd_qqq = RX_STOP_BIT ) then
                                    rx_busy                 <= '0';
                                    uart_rd_data            <= rx_data_sr;
                                    uart_rd_valid           <= '1';
                                else
                                    -- Didn't encounter a stop bit when we should have, so junk this tranmission
                                    -- and return to idle
                                    rx_busy                 <= '0';
                                    uart_rd_valid           <= '0';
                                end if;
                            else
                                -- Reset our counter to sample one full baud period later
                                baud_tick_cnt       <= to_unsigned(BAUD_DIVISOR, baud_tick_cnt'length);
                                rx_bit_cnt          <= rx_bit_cnt + 1;
                                -- The LSB is loaded into the top of the shift register...
                                rx_data_sr(7)       <= uart_rxd_qqq;
                                -- ...and then shifted down
                                rx_data_sr(6 downto 0)  <= rx_data_sr(7 downto 1);
                            end if;
                        else
                            baud_tick_cnt       <= baud_tick_cnt - 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

