library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_top is
    generic (
        DEVICE              : string            := "7SERIES";
        CLK_FREQ            : integer           := 100000000;
        DEBUG_ILA           : boolean           := false
    );
    port (
        clk                 : in    std_logic;
        rst                 : in    std_logic;

        -- AXI4-Lite register interface
        axi4l_awvalid       : in    std_logic;
        axi4l_awready       : out   std_logic;
        axi4l_awaddr        : in    std_logic_vector(31 downto 0);

        axi4l_wvalid        : in    std_logic;
        axi4l_wready        : out   std_logic;
        axi4l_wdata         : in    std_logic_vector(31 downto 0);
        axi4l_wstrb         : in    std_logic_vector(3 downto 0);

        axi4l_bvalid        : out   std_logic;
        axi4l_bready        : in    std_logic;
        axi4l_bresp         : out   std_logic_vector(1 downto 0);

        axi4l_arvalid       : in    std_logic;
        axi4l_arready       : out   std_logic;
        axi4l_araddr        : in    std_logic_vector(31 downto 0);

        axi4l_rvalid        : out   std_logic;
        axi4l_rready        : in    std_logic;
        axi4l_rdata         : out   std_logic_vector(31 downto 0);
        axi4l_rresp         : out   std_logic_vector(1 downto 0);

        irq                 : out   std_logic;

        rxd                 : in    std_logic;
        txd                 : out   std_logic
    );
    
end entity uart_top;

architecture structural of uart_top is

begin

end architecture structural;
