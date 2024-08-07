library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_driver is
    generic (
        -- Number of bits for the duty cycle or resolution
        PWM_RESOLUTION      : integer   8
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;
        -- Duty cycle for PWM output to be driven (1023 - 0). 0 indicates
        -- completely off and 1023 indicates completely on
        duty_cycle          : in    unsigned((PWM_RESOLUTION - 1) downto 0);
        pwm_drive           : out   std_logic
    );

end entity pwm_driver;

    -- Initialize this counter to zero with no reset necessary
    --signal  pwm_cnt         : unsigned((PWM_RESOLUTION - 1) downto 0) := (others=>'0');
    signal  pwm_cnt         : unsigned((PWM_RESOLUTION - 1) downto 0);

architecture behavioral of pwm_driver is

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                pwm_cnt     <= (others=>'0');
                pwm_drive   <= '0';
            else
                -- Rollover behavior is well-defined for unsigned values in VHDL, so
                -- we can just increment this every clock cycle
                pwm_cnt         <= pwm_cnt + 1;
                -- For the case of a zero duty cycle, this never fires
                -- because we're dealing with unsigned numbers
                if pwm_cnt < duty_cycle then
                    pwm_drive       <= '1';
                else
                    pwm_drive       <= '0';
                end if;
            end if
        end if;
    end process;

end architecture behavioral;

