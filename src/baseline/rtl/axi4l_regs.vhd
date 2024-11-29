library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity axi4l_regs is
    generic (
        --AXI bus details
        AXI_ADDR_WIDTH      : natural       := 32;
        AXI_DATA_WIDTH      : natural       := 32;
        REG_ADDR_WIDTH      : natural       := 4;
        REG_DATA_WIDTH      : natural       := 32
    );
    port (
        clk                 : in  std_logic;
        rstn                : in  std_logic;

        -- AXI4-Lite slave interface
        s_axi_awaddr        : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        s_axi_awvalid       : in  std_logic;
        s_axi_awready       : out std_logic;

        s_axi_wdata         : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        s_axi_wstrb         : in  std_logic_vector((AXI_DATA_WIDTH/8)-1 downto 0);
        s_axi_wvalid        : in  std_logic;
        s_axi_wready        : out std_logic;

        s_axi_bresp         : out std_logic_vector(1 downto 0);
        s_axi_bvalid        : out std_logic;
        s_axi_bready        : in  std_logic;

        s_axi_araddr        : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        s_axi_arvalid       : in  std_logic;
        s_axi_arready       : out std_logic;

        s_axi_rdata         : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        s_axi_rresp         : out std_logic_vector(1 downto 0);
        s_axi_rvalid        : out std_logic;
        s_axi_rready        : in  std_logic;

        -- Register interface
        reg_addr            : out std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : out std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        reg_wren            : out std_logic;
        reg_rdata           : in  std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        reg_rden            : out std_logic;
        reg_req             : out std_logic;
        reg_ack             : in  std_logic
    );

end entity axi4l_regs;

architecture behavioral of axi4l_regs is

    -- Design notes:
    --   - The AXI bridge should complete reads and writes but indicate errors in the response
    --     when attempting to write a value that is not writeabled
    --   - All register access is handled in this module (i.e., if register access is made on the
    --     register interface, it is expected to complete)
    --   - Register access is centralized in this module because it already has to be done to
    --     conform to the AXI spec and it register access in the internal register block, which makes
    --     implementing it something like BRAM easier later
    --   - Addresses get converted to unsigned internally so we can start using them to do math on
    --     like subtracting base addresses, shifting, etc. and then back to standard logic at the
    --     edges

    constant RESP_OKAY          : std_logic_vector(1 downto 0) := b"00";
    constant RESP_EXOKAY        : std_logic_vector(1 downto 0) := b"01";
    constant RESP_SLVERR        : std_logic_vector(1 downto 0) := b"10";
    constant RESP_DECERR        : std_logic_vector(1 downto 0) := b"11";

    -- ----- start package / configuration values
    -- These need to go in a package (and eventually with different configurations)
    -- Number of 32 or 64-bit registers to support
    constant NUM_REGS           : natural       := 8;
    -- Access control mask. Each bit: '1' = writable, '0' = read-only
    constant ACCESS_CTRL        : std_logic_vector(NUM_REGS-1 downto 0) := (others=>'1');
    -- This will need to bo into a package configuration too, since it is dependent upon the AXI
    -- width, so in the package, it'll just be a number and be made to match the width manually
    -- (configuration).  Here we can set it to 32 and then only use 32-bit in our testbench (we
    -- coudl get more sophisticated probably but this is good for now).
    constant BASE_ADDR          : unsigned(AXI_ADDR_WIDTH-1 downto 0) := x"80000000";
    -- ----- end package / configuration values

    -- Value read from AXI that is going to get used internally and eventually converted to an
    -- output address
    signal  rd_addr             : unsigned(AXI_ADDR_WIDTH-1 downto 0);
    -- Busy servicing an AXI read. Only deasserted when the response and data are received by the
    -- master
    signal  rd_busy             : std_logic;
    -- Done reading internal register
    signal  reg_rd_done         : std_logic;

    -- Returns true if address is aligned to 32 or 64-bit access
    function is_aligned(addr : unsigned) return boolean is
        variable align_to : natural;
    begin
        if (AXI_DATA_WIDTH = 32) then
            align_to := 4;
        elsif (AXI_DATA_WIDTH = 64) then
            align_to := 8;
        else
            return false;
        end if;

        if (addr mod align_to = 0) then
            return true;
        else
            return false;
        end if;
    end function;

    -- Returns true if address is readable
    function is_readable(addr : unsigned) return boolean is
        variable addr_idx : natural;
    begin
        if (AXI_DATA_WIDTH = 32) then
            addr_idx := to_integer((addr - BASE_ADDR) srl 3);
        elsif (AXI_DATA_WIDTH = 64) then
            addr_idx := to_integer((addr - BASE_ADDR) srl 4);
        else
            return false;
        end if;

        if (addr_idx <= (ACCESS_CTRL'length - 1)) then
            return true;
        else
            return false;
        end if;

    end function;

    -- Returns true if address is writable
    function is_writable(addr : unsigned) return boolean is
        variable addr_idx : natural;
    begin
        if (AXI_DATA_WIDTH = 32) then
            addr_idx := to_integer((addr - BASE_ADDR) srl 3);
        elsif (AXI_DATA_WIDTH = 64) then
            addr_idx := to_integer((addr - BASE_ADDR) srl 4);
        else
            return false;
        end if;

        if (ACCESS_CTRL(addr_idx) = '1') then
            return true;
        else
            return false;
        end if;
    end function;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (rstn = '0') then
                s_axi_arready       <= '0';
                s_axi_rvalid        <= '0';
                s_axi_rresp         <= (others=>'0');

                s_axi_awready       <= '0';
                s_axi_wready        <= '0';
                s_axi_bresp         <= (others=>'0');

                rd_busy             <= '0';
            else

                if (s_axi_arvalid = '1' and s_axi_arready = '0' and rd_busy = '0') then
                    s_axi_arready       <= '1';
                    rd_addr             <= unsigned(s_axi_araddr);
                    rd_busy             <= '1';
                elsif (s_axi_arvalid = '1' and s_axi_arready = '1' and rd_busy = '1') then
                    s_axi_arready       <= '0';
                end if;

                if (rd_busy = '1') then
                    -- Address is one that we can service
                    if (is_readable(rd_addr) and is_aligned(rd_addr)) then
                        -- Have not asserted valid to the master yet
                        if (s_axi_rvalid = '0') then
                            -- Have not read the value from the register bank yet
                            if (reg_rd_done = '0') then
                                reg_rden            <= '1';
                                reg_addr            <= std_logic_vector(rd_addr);
                                reg_rd_done         <= '1';
                            -- Have a value from the register bank now
                            else
                                reg_rden            <= '0';
                                --s_axi_rdata         <= x"12341234"; -- reg_rdata;
                                s_axi_rresp         <= RESP_OKAY;
                                s_axi_rvalid        <= '1';
                            end if;
                        -- Read response handshake is complete
                        elsif (s_axi_rvalid = '1' and s_axi_rready = '1') then
                            s_axi_rdata         <= x"12341234";
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
        end if;
    end process;

end architecture behavioral;

