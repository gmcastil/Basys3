library ieee;
use ieee.std_logic_1164.all;

entity user_core is
    port (
        sys_clk             : in    std_logic_vector(5 downto 0);
        sys_rst             : in    std_logic_vector(5 downto 0);

        uart_ready          : in    std_logic;

        uart_rd_data        : in    std_logic_vector(7 downto 0);
        uart_rd_valid       : in    std_logic;
        uart_rd_ready       : out   std_logic;

        uart_wr_data        : out   std_logic_vector(7 downto 0);
        uart_wr_valid       : out   std_logic;
        uart_wr_ready       : in    std_logic;

        uart_mode           : out   std_logic_vector(1 downto 0);

        sseg_digit          : out   std_logic_vector(6 downto 0);
        sseg_dp             : out   std_logic;
        sseg_selectn        : out   std_logic_vector(3 downto 0);

        slider_sw           : in    std_logic_vector(15 downto 0);

        user_led            : out   std_logic_vector(15 downto 0)
    );
end entity user_core;

architecture structural of user_core is

    attribute MARK_DEBUG    : string;
    attribute MARK_DEBUG of uart_rd_data        : signal is "true";
    attribute MARK_DEBUG of uart_rd_valid       : signal is "true";
    attribute MARK_DEBUG of uart_rd_ready       : signal is "true";

begin

--    uart_mode                   <= slider_sw(1 downto 0);
    uart_mode               <= "01";

    user_led(15 downto 2)       <= (others=>'0');
    user_led(1)                 <= uart_ready;

    pwm_i0: entity work.pwm_driver
    generic map(
        PWM_RESOLUTION      => 8
    )
    port map (
        clk                 => sys_clk(0),
        rst                 => sys_rst(0),
        duty_cycle          => x"05",
        pwm_drive           => user_led(0)
    );

    process(sys_clk(0))
    begin
        if rising_edge(sys_clk(0)) then
            if (sys_rst(0) = '1') then
                uart_rd_ready       <= '0';
            else
                if (uart_rd_valid = '1') then
                    uart_rd_ready       <= '1';
                else
                    uart_rd_ready       <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture structural;

