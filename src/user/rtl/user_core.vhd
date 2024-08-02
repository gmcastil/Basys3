library ieee;
use ieee.std_logic_1164.all;

entity user_core is
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        uart_rd_data        : in    std_logic_vector(7 downto 0);
        uart_rd_valid       : in    std_logic;
        uart_rd_ready       : out   std_logic;

        uart_wr_data        : out   std_logic_vector(7 downto 0);
        uart_wr_valid       : out   std_logic;
        uart_wr_ready       : in    std_logic;

        sseg_digit          : out   std_logic_vector(6 downto 0);
        sseg_dp             : out   std_logic;
        sseg_selectn        : out   std_logic_vector(3 downto 0);

        heartbeat           : out   std_logic
    );
end entity user_core;

architecture structural of user_core is

begin

end architecture structural;

