library ieee;
use ieee.std_logic_1164.all;

entity skid_buffer is
    generic (
        DATA_WIDTH      : natural       := 8
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        fifo_rd_data    : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        fifo_rd_enable  : out   std_logic := '0';
        fifo_full       : in    std_logic;
        fifo_empty      : in    std_logic;
        fifo_ready      : in    std_logic;
        
        rd_data         : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_valid        : out   std_logic := '0';
        rd_ready        : in    std_logic

    );
end entity skid_buffer;

architecture behavioral of skid_buffer is

    constant S0         : std_logic_vector(7 downto 0) := x"0";
    constant S1         : std_logic_vector(7 downto 0) := x"1";
    constant S2         : std_logic_vector(7 downto 0) := x"2";

    -- Indicator that there is valid data from the FIFO
    signal fifo_valid   : std_logic;
    -- Indicator that there is valid data in the skid register
    signal skid_valid   : std_logic;

    signal skid_data    : std_logic_vector((DATA_WIDTH -1) downto 0);

    signal state        : std_logic_vector(7 downto 0);

begin

    process(clk)
        if rising_edge(clk) then
            if (rst = '1') then
                state               <= S0;

                fifo_rd_enable      <= '0';
                rd_valid            <= '0';

                skid_valid          <= '0';

            else
                case state is

                    when S0 =>

                        if (fifo_ready and not fifo_empty) then
                            state               <= S1;
                            fifo_rd_enable      <= '1';
                        else
                            state               <= S0;
                            fifo_rd_enable      <= '0';
                        end if;

                    when S1 =>
                        state               <= S2;

                        fifo_rd_enable      <= '1';

                end case;
            end if;
        end if;
    end process;

end architecture behavioral;

