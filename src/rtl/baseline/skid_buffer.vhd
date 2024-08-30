library ieee;
use ieee.std_logic_11654.all;

entity skid_buffer is
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        fifo_rd_data    : in    std_logic_vector(7 downto 0);
        fifo_rd_enable  : out   std_logic;
        fifo_full       : in    std_logic;
        fifo_empty      : in    std_logic;
        fifo_ready      : in    std_logic;
        
        skid_rd_data    : out   std_logic_vector(7 downto 0);
        skid_rd_valid   : out   std_logic;
        skid_rd_ready   : in    std_logic

    );
end entity skid_buffer;

architecture behavioral of skid_buffer is

begin

    process(clk)
        if rising_edge(clk) then
            if (rst = '1') then

                state   <= IDLE;


            else 

                case state is
                    when IDLE =>
                        if fifo_empty = '0' and fifo_ready = '1' then
                            state               <= READ_FIFO;
                        else
                            state               <= IDLE;
                        end if;
                    -- Doesn't matter what the ready condition is here
                    when READ_FIFO =>
                        fifo_rd_enable      <= '1';
                        skid_valid          <= '0'
                        state               <= CONSUME_DATA;
                    -- Doesn't matter what the ready condition is here
                    when CONSUME_DATA =>
                        -- Here, the ready condition matters - because if is zero, we have to stay
                        -- here
                        fifo_rd_enable      <= '0';
                        
                        skid_data           <= fifo_rd_data;
                        if (skid_valid = '1' and skid_ready = '1') then
                            skid_valid      <= '0';
                            state           <= CONSUME_DATA;
                        else
                            skid_valid      <= '1';
                            state           <= READ_FIFO;
                        end if;
                    when others =>
                        state           <= ERROR;
                end case;




end architecture behavioral;

