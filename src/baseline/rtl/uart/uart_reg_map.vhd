library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.reg_pkg.all;
use work.uart_pkg.all;

entity uart_reg_map is
    generic (
        NUM_REGS        : natural       := 16
    );
    port (
        -- Input control/status signals
        parity          : out std_logic_vector(1 downto 0);
        nbstop          : out std_logic_vector(1 downto 0);
        char            : out std_logic_vector(1 downto 0);

        baud_div        : out unsigned(14 downto 0);
        baud_cnt        : in  unsigned(14 downto 0);
        baud_gen_en     : out std_logic;

        -- Register interface
        rd_regs         : out reg_a(NUM_REGS-1 downto 0);
        wr_regs         : in  reg_a(NUM_REGS-1 downto 0)
    );

end entity uart_reg_map;

architecture arch of uart_reg_map is

    attribute MARK_DEBUG    : string;
    attribute MARK_DEBUG of baud_cnt        : signal is "TRUE";

begin

    -- Register 0: UART control register (0x00000000)

    -- Register 1: UART mode register (0x00000004)
    -- Defines expected parity to check on receive and sent on transmit
    --  00 - Even
    --  01 - Odd
    --  1x - None
    parity          <= wr_regs(MODE_REG)(9 downto 8);
    -- Defines the number of bits to transmit or receive per character
    --  00 - 6 bits
    --  01 - 7 bits
    --  1x - 8 bits
    nbstop          <= wr_regs(MODE_REG)(5 downto 4);
    -- Defines the number of expected stop bits
    --  00 - 1 stop bit
    --  01 - 1.5 stop bits
    --  1x - 2 stop bits
    char            <= wr_regs(MODE_REG)(1 downto 0); 

    -- Register 2: UART status register (0x00000008)
    --
    -- Register 6: Baud rate generator status
    rd_regs(BAUD_GEN_STATUS_REG)(31 downto 15)  <= (others=>'0');
    rd_regs(BAUD_GEN_STATUS_REG)(14 downto 0)   <= std_logic_vector(baud_cnt);

    -- Register 7: Baud rate generator register (0x00000020)
    --          0  Enable = 1, Disable = 0
    --    15 -  1  15 bits for the baud_div
    --    31 - 16  Unused
    baud_div        <= unsigned(wr_regs(BAUD_GEN_CTRL_REG)(15 downto 1));
    baud_gen_en     <= wr_regs(BAUD_GEN_CTRL_REG)(0);

    -- Register 15: UART scratch register (0x000000??)

end architecture arch;
