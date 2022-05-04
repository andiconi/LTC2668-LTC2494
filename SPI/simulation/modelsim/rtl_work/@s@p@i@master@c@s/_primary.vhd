library verilog;
use verilog.vl_types.all;
entity SPIMasterCS is
    generic(
        SPI_MODE        : integer := 0;
        HALF_BIT_CLKS   : integer := 2;
        BYTES_PER_CS    : integer := 16;
        CS_INACTIVE_CLKS: integer := 0
    );
    port(
        i_FPGA_rst      : in     vl_logic;
        i_FPGA_clk      : in     vl_logic;
        i_MOSI_count    : in     vl_logic_vector(4 downto 0);
        i_MOSI          : in     vl_logic_vector(7 downto 0);
        i_MOSIdv        : in     vl_logic;
        o_MOSI_ready    : out    vl_logic;
        o_MISO_count    : out    vl_logic_vector(4 downto 0);
        o_MISOdv        : out    vl_logic;
        o_MISO          : out    vl_logic_vector(7 downto 0);
        o_SPI_clk       : out    vl_logic;
        i_SPI_MISO      : in     vl_logic;
        o_SPI_MOSI      : out    vl_logic;
        o_SPI_CS        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SPI_MODE : constant is 1;
    attribute mti_svvh_generic_type of HALF_BIT_CLKS : constant is 1;
    attribute mti_svvh_generic_type of BYTES_PER_CS : constant is 1;
    attribute mti_svvh_generic_type of CS_INACTIVE_CLKS : constant is 1;
end SPIMasterCS;
