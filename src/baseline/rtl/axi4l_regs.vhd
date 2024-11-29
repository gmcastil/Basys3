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
        reg_addr            : out std_logic_vector(integer(ceil(log2(real(NUM_REGS))))-1 downto 0);
        reg_wdata           : out std_logic_vector(DATA_WIDTH-1 downto 0);
        reg_wstrb           : out std_logic_vector((DATA_WIDTH/8)-1 downto 0);
        reg_wren            : out std_logic;
        reg_rdata           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        reg_rden            : out std_logic
    );

end entity axi4l_regs;

architecture behavioral of axi4l_regs is

    constant RESP_OKAY          : std_logic_vector(1 downto 0) := b"00";
    constant RESP_EXOKAY        : std_logic_vector(1 downto 0) := b"01";
    constant RESP_SLVERR        : std_logic_vector(1 downto 0) := b"10";
    constant RESP_DECERR        : std_logic_vector(1 downto 0) := b"11";

    -- assert here about NUM_REGS relative to address
    signal  rd_addr             : std_logic_vector(integer(ceil(log2(real(NUM_REGS))))-1 downto 0);
    -- Busy servicing an AXI read. Only deasserted when the response and data are received by the
    -- master
    signal  rd_busy             : std_logic;
    -- Done reading internal register
    signal  reg_rd_done         : std_logic;

    -- Returns true if address is aligned to 32 or 64-bit access
    function is_aligned(addr : std_logic_vector) return boolean is
        variable addr_int : integer;
        variable align_to : integer;
    begin
        addr_int := to_integer(unsigned(addr));
        if (DATA_WIDTH = 32) then
            align_to := 4;
        elsif (DATA_WIDTH = 64) then
            align_to := 8;
        else
            return false;
        end if;
        return (addr_int mod align_to = 0);

    end function;

    -- Returns true if address is serviceable
    function is_serviceable(addr : std_logic_vector) return boolean is
    begin
        return true;
    end function;

begin

    process(clk)
    begin
        if (rstn = '0') then
            s_axi_arready       <= '0';
            s_axi_rvalid        <= '0';
            s_axi_rresp         <= (others=>'0');

            rd_busy             <= '0';
        else

            if (s_axi_arvalid = '1' and s_axi_arready = '0' and rd_busy = '0') then
                s_axi_arready       <= '1';
                rd_addr             <= s_axi_araddr;
                rd_busy             <= '1';
            elsif (s_axi_arvalid = '1' and s_axi_arready = '1' and rd_busy = '1') then
                s_axi_arready       <= '0';
            end if;

            if (rd_busy = '1') then
                -- Address is one that we are going to service
                if (is_serviceable(rd_addr) and is_aligned(rd_addr)) then
                    -- Have not asserted valid to the master yet
                    if (s_axi_rvalid = '0') then
                        -- Have not read the value from the register bank yet
                        if (reg_rd_done = '0') then
                            reg_rden            <= '1';
                            reg_addr            <= rd_addr;
                            reg_rd_done         <= '1';
                        -- Have a value from the register bank now
                        else
                            reg_rden            <= '0';
                            s_axi_rdata         <= reg_rdata;
                            s_axi_rresp         <= RESP_OKAY;
                            s_axi_rvalid        <= '1';
                        end if;
                    -- Read response handshake is complete
                    elsif (s_axi_rvalid = '1' and s_axi_rready = '1') then
                        s_axi_rvalid        <= '0';
                        rd_busy             <= '0';
                    end if;
                -- Not an address we can service
                else
                    -- Have not asserted valid to the master yet
                    if (s_axi_rvalid = '0') then
                        s_axi_rvalid        <= '1';
                        s_axi_rresp         <= RESP_SLVERR;
                    -- Read response handshake is complete
                    elsif (s_axi_rvalid = '1' and s_axi_rready = '1') then
                        s_axi_rvalid        <= '0';
                        rd_busy             <= '0';
                    end if;
                end if;
            end if;

        end if;
    end process;

end architecture behavioral;

