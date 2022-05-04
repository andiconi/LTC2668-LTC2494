
///////////////////////////////////////////////////////////////////////////////
// Description:      TESTBENCH FOR SENDING OVER DAC AND ADC PROTOCOL
///////////////////////////////////////////////////////////////////////////////

module SPIDAC();
  
  parameter SPI_MODE = 0;           // CPOL = 1, CPHA = 1
  parameter CLKS_PER_HALF_BIT = 4;  // 6.25 MHzo
  parameter MAIN_CLK_DELAY = 2;     // 25 MHz
  parameter MAX_BYTES_PER_CS = 16;   // 16 bytes per chip select
  parameter CS_INACTIVE_CLKS = 0;  // Adds delay between bytes
  parameter MODE = 1;

  logic r_Rst_L     = 1'b0;  
  logic w_SPI_Clk;
  logic r_Clk       = 1'b0;
  logic w_SPI_CS_n;
  logic w_SPI_MOSI;
  // Master Specific
  logic [7:0] r_Master_TX_Byte;
  logic r_Master_TX_DV;
  logic w_Master_TX_Ready;
  logic w_Master_RX_DV;
  logic [7:0] w_Master_RX_Byte;
  logic [4:0] w_Master_RX_Count, r_Master_TX_Count;
	
  logic[31:0] DAC_DATA;

	logic w_EOC_L;
	integer i;
	logic w_MISO;
	
	logic CS1;
	logic CS2;

  
  logic d_clk;
  logic mode;
  // Clock Generators:
  always #(MAIN_CLK_DELAY) r_Clk = ~r_Clk;

////////////////////////////instantiations//////////////////////////////
//MASTER
  // Instantiate UUT
  SPIMasterCS
  #(.SPI_MODE(SPI_MODE),
    .HALF_BIT_CLKS(CLKS_PER_HALF_BIT),
    .BYTES_PER_CS(MAX_BYTES_PER_CS),
    .CS_INACTIVE_CLKS(CS_INACTIVE_CLKS)
    ) UUT
  (
   // Control/Data Signals,
   .i_FPGA_rst(r_Rst_L),     // FPGA Reset
   .i_FPGA_clk(d_clk),         // FPGA Clock
   
   // TX (MOSI) Signals
   .i_MOSI_count(r_Master_TX_Count),   // Number of bytes per CS
   .i_MOSI(r_Master_TX_Byte),     // Byte to transmit on MOSI
   .i_MOSIdv(r_Master_TX_DV),         // Data Valid Pulse with i_TX_Byte
   .o_MOSI_ready(w_Master_TX_Ready),   // Transmit Ready for Byte
   
   // RX (MISO) Signals
   .o_MISO_count(w_Master_RX_Count), // Index of RX'd byte
   .o_MISOdv(w_Master_RX_DV),       // Data Valid pulse (1 clock cycle)
   .o_MISO(w_Master_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_clk(w_SPI_Clk),
   .i_SPI_MISO(w_SPI_MISO),
   .o_SPI_MOSI(w_SPI_MOSI),
   .o_SPI_CS(CS1)
   );


	MasterDriver MSPI_Driver_UUT
	(
	.i_FPGA_clk(d_clk),
	.i_FPGA_rst(r_Rst_L),
	.inputByte(r_Master_TX_Byte), //mosi byte
	.o_MOSI_count(r_Master_TX_Count),
	.i_DAC_DATA(DAC_DATA),
	.o_EOC_L(w_EOC_L),
	.o_CS(CS2),
	.o_MOSIdv(r_Master_TX_DV), //mosi data valid
	.i_MOSI_ready(w_Master_TX_Ready),
	.o_ready(driverready),
	.i_DataValid(datavalid),
	.i_MISO(w_MISO)
	);


	datadriver	data_UUT
	(
	.clk(d_clk),
	.rst(r_Rst_L),
	.i_MODE(mode),
	.i_ready(driverready),
	.o_dataValid(datavalid),
	.o_DATA(DAC_DATA),
	.i_EOC(w_EOC_L)
	);

	
	Clock_divider div_UUT
	(
	 .clock_in(r_Clk),
    .enable(mode),
    .clock_out(d_clk)
	 );
	 
	 ////////////////////////////////////////////////////////////////////
	 
//this is setup to test EOC working.  
  initial
    begin
		i = 0;
		w_MISO = 1;
		mode = 0;
		/////////Do not change//////////////
      repeat(10) @(posedge r_Clk);
      r_Rst_L  = 1'b0;
      repeat(10) @(posedge r_Clk);
      r_Rst_L = 1'b1;
		////////////////////////////////////
		repeat(20) @(posedge r_Clk);
		w_MISO <= 0;
		repeat(400) @(posedge r_Clk);
		w_MISO <= 1;
		repeat(400) @(posedge r_Clk);
		w_MISO <= 0;
		mode = 1;
    end // initial begin
assign w_SPI_MISO = w_MISO;
assign w_SPI_CS_n = CS1 && CS2;
endmodule // SPI_Master_With_Single_CS_TB






