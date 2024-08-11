library ieee;
use ieee.std_logic_1164.all;

entity user_core is
    port (
        sys_clk             : in    std_logic_vector(5 downto 0);
        sys_rst             : in    std_logic_vector(5 downto 0);

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

        user_led            : out   std_logic_vector(15 downto 0)
    );
end entity user_core;

architecture structural of user_core is

begin

    uart_wr_valid               <= '1';
    uart_wr_data                <= x"48";

    uart_rd_ready               <= '1';

    uart_mode                   <= (others=>'0');

    user_led(15 downto 1)       <= (others=>'0');

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

end architecture structural;

