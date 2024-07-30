library ieee;
use ieee.std_logic_1164.all;

entity user_core is
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        uart_rxd            : in    std_logic;
        uart_txd            : out   std_logic;

        sseg_digit          : out   std_logic_vector(6 downto 0);
        sseg_dp             : out   std_logic;
        sseg_selectn        : out   std_logic_vector(3 downto 0);

        heartbeat           : out   std_logic
    );
end entity user_core;

architecture structural of user_core is

    signal uart_rd_data         : std_logic_vector(7 downto 0);
    signal uart_rd_valid        : std_logic;
    signal uart_rd_ready        : std_logic;

    signal uart_wr_data         : std_logic_vector(7 downto 0);
    signal uart_wr_valid        : std_logic;
    signal uart_wr_ready        : std_logic;

begin

    uart_i0: entity work.uart
    port map (
        clk         => clk,
        rst         => rst,

        rd_data     => uart_rd_data,
        rd_valid    => uart_rd_valid,
        rd_ready    => uart_rd_ready,

        wr_data     => uart_wr_data,
        wr_valid    => uart_wr_valid,
        wr_ready    => uart_wr_ready,

        uart_rxd    => uart_rxd,
        uart_txd    => uart_txd
    );

end architecture structural;

