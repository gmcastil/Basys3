library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;

entity reg_block is
    generic (
        REG_ADDR_WIDTH      : natural       := 4;
        REG_DATA_WIDTH      : natural       := 32
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;

        reg_addr            : in  std_logic_vector(REG_ADDR_WIDTH-1 downto 0);
        reg_wdata           : in  std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        reg_wren            : in  std_logic;
        reg_rdata           : out std_logic_vector(REG_DATA_WIDTH-1 downto 0);
        reg_req             : in  std_logic;
        reg_ack             : out std_logic
    );

end entity reg_block;

architecture behavioral of reg_block is

    -- ----- start package / configuration values
    -- These need to go in a package (and eventually with different configurations)
    -- Number of 32 or 64-bit registers to support
    constant NUM_REGS           : natural       := 4;
    -- ----- end package / configuration values

    subtype reg_t is std_logic_vector(REG_DATA_WIDTH-1 downto 0);
    type reg_a is array (natural range<>) of reg_t;

    signal REG_ARRAY    : reg_a(0 to NUM_REGS-1) := (
        0       => x"12341234",
        1       => x"00000001",
        2       => x"00000000",
        3       => x"12341234"
    );

    signal busy             : std_logic;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if (rst = '1') then
                reg_ack         <= '0';
                busy            <= '0';
            else
                -- Not servicing a register access
                if (busy = '0') then
                    -- Access requested
                    if (reg_req = '1') then
                        -- Read was requested
                        if (reg_wren = '0') then
                            -- Service the register read
                            if (reg_req = '1' and reg_ack = '0') then
                                reg_ack         <= '1';
                                reg_rdata       <= REG_ARRAY(to_integer(unsigned(reg_addr)));
                            -- Terminate the register read
                            elsif (reg_req = '1' and reg_ack = '1') then
                                reg_ack         <= '0';
                                busy            <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture behavioral;

