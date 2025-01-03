library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;

entity uart_ctrl is
    generic (
        DEBUG_UART_CTRL     : boolean       := false
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        -- Register interface bus 
        reg_addr            : in  unsigned(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : in  std_logic_vector(31 downto 0);
        reg_wren            : in  std_logic;
        reg_be              : in  std_logic_vector(3 downto 0);
        reg_rdata           : out std_logic_vector(31 downto 0);
        reg_req             : in  std_logic;
        reg_ack             : out std_logic;
        reg_err             : out std_logic;

    );

end entity uart_ctrl;

entity reg_block is
    generic (
        REG_ADDR_WIDTH      : natural       := 4;
        NUM_REGS            : natural       := 16;
        -- Identifies which registers can be written to from the bus
        REG_WRITE_MASK      : std_logic_vector(15 downto 0) := (others=>'0')
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;


    );

end entity reg_block;

    -- TODO Merge the uart_reg_map and reg_block into a single module like uart_regs that contains
    -- the reg block and has registered outputs that also can generate events and such for things
    -- like "I just received a THR write and have valid data"
    uart_reg_map_i0: entity work.uart_reg_map
    generic map (
        NUM_REGS            => NUM_REGS,
        RX_ENABLE           => RX_ENABLE,
        TX_ENABLE           => TX_ENABLE,
        DEBUG_UART_AXI      => DEBUG_UART_AXI, 
        DEBUG_UART_CORE     => DEBUG_UART_CORE
    )
    port map (
        rx_rst              => rx_rst,
        rx_en               => rx_en,
        tx_rst              => tx_rst,
        tx_en               => tx_en,
        -- Control
        -- Mode
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        -- Config
        cfg                 => cfg,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        scratch             => scratch,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
    );

        rd_regs             : in  reg_a(NUM_REGS-1 downto 0);
        wr_regs             : out reg_a(NUM_REGS-1 downto 0)

architecture rtl of uart_regs is

    signal rd_regs              : reg_a(NUM_REGS-1 downto 0);
    signal wr_regs              : reg_a(NUM_REGS-1 downto 0);

begin

    uart_regs: entity work.reg_block
    generic map (
        REG_ADDR_WIDTH      => REG_ADDR_WIDTH,
        NUM_REGS            => NUM_REGS,
        REG_WRITE_MASK      => REG_WRITE_MASK
    )
    port map (
        clk                 => clk,
        rst                 => rst,
        reg_addr            => reg_addr,
        reg_wdata           => reg_wdata,
        reg_wren            => reg_wren,
        reg_be              => reg_be,
        reg_rdata           => reg_rdata,
        reg_req             => reg_req,
        reg_ack             => reg_ack,
        reg_err             => reg_err,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
    );

end architecture rtl;


    -- TODO Merge the uart_reg_map and reg_block into a single module like uart_regs that contains
    -- the reg block and has registered outputs that also can generate events and such for things
    -- like "I just received a THR write and have valid data"
    uart_reg_map_i0: entity work.uart_reg_map
    generic map (
        NUM_REGS            => NUM_REGS,
        RX_ENABLE           => RX_ENABLE,
        TX_ENABLE           => TX_ENABLE,
        DEBUG_UART_AXI      => DEBUG_UART_AXI, 
        DEBUG_UART_CORE     => DEBUG_UART_CORE
    )
    port map (
        rx_rst              => rx_rst,
        rx_en               => rx_en,
        tx_rst              => tx_rst,
        tx_en               => tx_en,
        -- Control
        -- Mode
        parity              => parity,
        char                => char,
        nbstop              => nbstop,
        -- Config
        cfg                 => cfg,
        baud_div            => baud_div,
        baud_cnt            => baud_cnt,
        baud_gen_en         => baud_gen_en,
        scratch             => scratch,
        rd_regs             => rd_regs,
        wr_regs             => wr_regs
    );

    -- Instrument the control and status bits at the UART core. This
    -- is intended for driver debug not for general hardware debug.
    -- Generate a different core for that or use MARK_DEBUG attributes
    -- and a post-synthesis ILA.
    g_regs_ila: if (DEBUG_UART_CORE) generate
        uart_core_ila_i0: entity work.uart_core_ila
        port map (
            clk                 => clk,
            probe0(0)           => rst,
            probe1(0)           => rx_rst,
            probe2(0)           => rx_en,
            probe3(0)           => tx_rst,
            probe4(0)           => tx_en,
            probe5              => parity,
            probe6              => char,
            probe7              => nbstop,
            probe8              => std_logic_vector(baud_div),
            probe9              => std_logic_vector(baud_cnt),
            probe10(0)          => baud_gen_en,
            probe11             => cfg,
            probe12             => scratch
        );
    end generate g_regs_ila;

