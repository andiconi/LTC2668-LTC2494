library verilog;
use verilog.vl_types.all;
entity MasterDriver is
    port(
        i_FPGA_clk      : in     vl_logic;
        i_FPGA_rst      : in     vl_logic;
        o_MOSI_count    : out    vl_logic_vector(4 downto 0);
        inputByte       : out    vl_logic_vector(7 downto 0);
        o_MOSIdv        : out    vl_logic;
        o_CS            : out    vl_logic;
        o_ready         : out    vl_logic;
        o_EOC_L         : out    vl_logic;
        i_MOSI_ready    : in     vl_logic;
        i_DataValid     : in     vl_logic;
        i_DAC_DATA      : in     vl_logic_vector(31 downto 0);
        i_MISO          : in     vl_logic
    );
end MasterDriver;
