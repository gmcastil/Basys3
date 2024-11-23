library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity axi4l_regs is
    generic (
        -- Width of AXI address bus
        ADDR_WIDTH          : natural       := 32;
        -- Width of AXI and register data bus. Should be either 32-bit or 64-bit
        DATA_WIDTH          : natural       := 32;
        -- Number of 32 or 64-bit registers to support
        NUM_REGS            : natural       := 16
    );
    port (
        clk                 : in  std_logic;
        rstn                : in  std_logic;

        -- AXI4-Lite slave interface
        s_axi_awaddr        : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        s_axi_awvalid       : in  std_logic;
        s_axi_awready       : out std_logic;

        s_axi_wdata         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axi_wstrb         : in  std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        s_axi_wvalid        : in  std_logic;
        s_axi_wready        : out std_logic;

        s_axi_bresp         : out std_logic_vector(1 downto 0);
        s_axi_bvalid        : out std_logic;
        s_axi_bready        : in  std_logic;

        s_axi_araddr        : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        s_axi_arvalid       : in  std_logic;
        s_axi_arready       : out std_logic;

        s_axi_rdata         : out std_logic_vector(DATA_WIDTH-1 downto 0);
        s_axi_rresp         : out std_logic_vector(1 downto 0);
        s_axi_rvalid        : out std_logic;
        s_axi_rready        : in  std_logic;

        -- Register interface
        reg_addr            : out unsigned(integer(ceil(log2(real(NUM_REGS))))-1 downto 0);
        reg_wdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        reg_wstrb           : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        reg_write_en        : out std_logic;
        reg_rdata           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        reg_read_en         : out std_logic
    );

end entity axi4l_regs;

architecture behavioral of axi4l_regs is
    -- assert here about NUM_REGS relative to address
begin

end architecture behavioral;

