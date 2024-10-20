library ieee;
use ieee.std_logic_1164.all;

entity skid_buffer is
    generic (
        DATA_WIDTH      : natural       := 8
    );
    port (
        clk             : in    std_logic;
        rst             : in    std_logic;

        fifo_rd_data    : in    std_logic_vector((DATA_WIDTH - 1) downto 0);
        fifo_rd_en      : out   std_logic := '0';
        fifo_full       : in    std_logic;
        fifo_empty      : in    std_logic;
        fifo_ready      : in    std_logic;

        rd_data         : out   std_logic_vector((DATA_WIDTH - 1) downto 0);
        rd_valid        : out   std_logic := '0';
        rd_ready        : in    std_logic

    );
end entity skid_buffer;

architecture behavioral of skid_buffer is

    -- Indicator that there is valid data from the FIFO. The data flow from the FIFO to the output
    -- is
    --
    --      fifo_rd_valid -> fifo_rd_valid_q -> rd_valid
    --
    -- If the consumer is not ready, then data should move to the skid register with skid_valid to
    -- indicate it is occupied.
    --
    signal fifo_rd_valid            : std_logic;
    signal fifo_rd_valid_q          : std_logic;
    -- Indicator that there is valid data in the skid register
    signal skid_valid               : std_logic;
    signal skid_data                : std_logic_vector((DATA_WIDTH -1) downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                rd_valid            <= '0';
                skid_valid          <= '0';
                fifo_rd_valid       <= '0';
                fifo_rd_valid_q     <= '0';

            else
                -- Simple machine to control the output data interface
                if (rd_valid = '1' and rd_ready = '1') then
                    -- Data in the holding register to send
                    if (skid_valid = '1') then
                        rd_valid            <= '1';
                        rd_data             <= skid_data;
                    -- Data at the FIFO read output to send
                    elsif (fifo_rd_valid_q = '1') then
                        rd_data             <= fifo_rd_data;
                        rd_valid            <= '1';
                    -- No data in either location to send
                    else
                        rd_valid            <= '0';
                    end if;
                elsif (rd_valid = '0') then
                    -- Data in the holding register to send
                    if (skid_valid = '1') then
                        rd_valid            <= '1';
                        rd_data             <= skid_data;
                    -- Data at the FIFO read output to send
                    elsif (fifo_rd_valid_q = '1') then
                        rd_valid            <= '1';
                        rd_data             <= fifo_rd_data;
                    end if;
                end if;

                -- Need to handle the coupling between the two halves of the logic here. Data in
                -- the skid register will always get consumed first when data moves at the output
                if (skid_valid = '1' and rd_valid = '1' and rd_ready = '1') then
                    skid_valid          <= '0';
                -- When we are still reading from the FIFO, there is already data at the FIFO output and
                -- we are presenting data at the output but the consumer is not ready, we will need to stall
                elsif (fifo_rd_en = '1' and fifo_rd_valid_q = '1' and rd_valid = '1' and rd_ready = '0') then
                    skid_valid          <= '1';
                    skid_data           <= fifo_rd_data;
                -- Or, if we are reading from the FIFO and the FIFO goes empty or non-ready
                elsif (fifo_rd_en = '1' and (fifo_empty = '1' or fifo_ready = '0')) then
                    skid_valid          <= '1';
                    skid_data           <= fifo_rd_data;
                end if;

                if (fifo_rd_en = '1') then
                    fifo_rd_valid       <= '1';
                else
                    fifo_rd_valid       <= '0';
                end if;

                fifo_rd_valid_q     <= fifo_rd_valid;
            end if;
        end if;
    end process;

    -- Only read from the FIFO when it is ready, non-empty and we have a spot to put the
    -- data on the next clock cycle
    fifo_rd_en  <= '0' when (fifo_empty = '1' and fifo_rd_en = '1') else
                   '1' when (fifo_ready = '1' and fifo_empty = '0' and rd_valid = '0') else
                   '0';

end architecture behavioral;

