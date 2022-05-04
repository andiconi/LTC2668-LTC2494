library verilog;
use verilog.vl_types.all;
entity datadriver is
    generic(
        DAC             : integer := 0;
        ADC             : integer := 1
    );
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        i_MODE          : in     vl_logic;
        i_ready         : in     vl_logic;
        i_EOC           : in     vl_logic;
        o_dataValid     : out    vl_logic;
        o_DATA          : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DAC : constant is 1;
    attribute mti_svvh_generic_type of ADC : constant is 1;
end datadriver;
