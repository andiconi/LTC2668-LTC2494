library verilog;
use verilog.vl_types.all;
entity SPIDAC is
    generic(
        SPI_MODE        : integer := 0;
        CLKS_PER_HALF_BIT: integer := 4;
        MAIN_CLK_DELAY  : integer := 2;
        MAX_BYTES_PER_CS: integer := 16;
        CS_INACTIVE_CLKS: integer := 0;
        MODE            : integer := 1
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of SPI_MODE : constant is 1;
    attribute mti_svvh_generic_type of CLKS_PER_HALF_BIT : constant is 1;
    attribute mti_svvh_generic_type of MAIN_CLK_DELAY : constant is 1;
    attribute mti_svvh_generic_type of MAX_BYTES_PER_CS : constant is 1;
    attribute mti_svvh_generic_type of CS_INACTIVE_CLKS : constant is 1;
    attribute mti_svvh_generic_type of MODE : constant is 1;
end SPIDAC;
