
module SPI_Slave
  #(parameter SPI_MODE = 3,
	 parameter HALF_BIT_CLKS = 2,
	 parameter BYTEEDGES = 16)
  (
   // Control/Data Signals,
   input            i_Rst_L,    // FPGA Reset
   input            i_Clk,      // FPGA Clock
   output reg       o_RX_DV,    // Data Valid pulse (1 clock cycle)
	output reg 		  o_MISO_ready,//ready single for tx byte
   output reg [7:0] o_RX_Byte,  // Byte received on MOSI
   input            i_TX_DV,    // Data Valid pulse to register i_TX_Byte
   input  [7:0]     i_TX_Byte,  // Byte to serialize to MISO.

   // SPI Interface
   input    i_SPI_Clk,
   output wire o_SPI_MISO,
   input      i_SPI_MOSI,
   input      i_SPI_CS_n

   );


  // SPI Interface (All Runs at SPI Clock Domain)
  wire w_CPOL;     // Clock polarity
  wire w_CPHA;     // Clock phase
  wire w_SPI_Clk;  // Inverted/non-inverted depending on settings
  wire w_SPI_MISO_Mux;
  
  reg [2:0] r_RX_Bit_Count;
  reg [2:0] r_TX_Bit_Count;
  reg [7:0] r_Temp_RX_Byte;
  reg [7:0] r_RX_Byte;
  reg r_RX_Done, r2_RX_Done, r3_RX_Done;
  reg [7:0] r_TX_Byte;
  reg r_SPI_MISO_Bit, r_Preload_MISO;
  reg r_TX_DV;
	wire r_LeadingEdge;
	wire r_TrailingEdge;
	wire ne;
	wire pe;
	reg sig_dly;  
	reg[4:0] r_SPI_Clk_Cnt;
	// CPOL: Clock Polarity
  // CPOL=0 means clock idles at 0, leading edge is rising edge.
  // CPOL=1 means clock idles at 1, leading edge is falling edge.
  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

  // CPHA: Clock Phase
  // CPHA=0 means the "out" side changes the data on trailing edge of clock
  //              the "in" side captures data on leading edge of clock
  // CPHA=1 means the "out" side changes the data on leading edge of clock
  //              the "in" side captures data on the trailing edge of clock
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);

  assign w_SPI_Clk = w_CPOL ? ~i_SPI_Clk : i_SPI_Clk;



  // Purpose: Recover SPI Byte in SPI Clock Domain
  // Samples line on correct edge of SPI Clock
  always @(posedge w_SPI_Clk or posedge i_SPI_CS_n)
  begin
    if (i_SPI_CS_n)
    begin
      r_RX_Bit_Count <= 0;
      r_RX_Done      <= 1'b0;
    end
    else
    begin
      r_RX_Bit_Count <= r_RX_Bit_Count + 1;

      // Receive in LSB, shift up to MSB
      r_Temp_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
    
      if (r_RX_Bit_Count == 3'b111)
      begin
        r_RX_Done <= 1'b1;
        r_RX_Byte <= {r_Temp_RX_Byte[6:0], i_SPI_MOSI};
      end
      else if (r_RX_Bit_Count == 3'b010)
      begin
        r_RX_Done <= 1'b0;        
      end

    end // else: !if(i_SPI_CS_n)
  end // always @ (posedge w_SPI_Clk or posedge i_SPI_CS_n)



  // Purpose: Cross from SPI Clock Domain to main FPGA clock domain
  // Assert o_RX_DV for 1 clock cycle when o_RX_Byte has valid data.
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r2_RX_Done <= 1'b0;
      r3_RX_Done <= 1'b0;
      o_RX_DV    <= 1'b0;
      o_RX_Byte  <= 8'h00;
    end
    else
    begin
      r2_RX_Done <= r_RX_Done;
      r3_RX_Done <= r2_RX_Done;
      if (r3_RX_Done == 1'b0 && r2_RX_Done == 1'b1) // rising edge
      begin
        o_RX_DV   <= 1'b1;  // Pulse Data Valid 1 clock cycle
        o_RX_Byte <= r_RX_Byte;
      end
      else
      begin
        o_RX_DV <= 1'b0;
      end
    end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Bus_Clk)
  
  //decode spi clock	   
	always @ (posedge i_Clk) begin
		sig_dly <= i_SPI_Clk;
	end
    assign ne = ~i_SPI_Clk & sig_dly;  
    assign pe = i_SPI_Clk & ~sig_dly; 
	assign r_LeadingEdge = w_CPOL ? ne : pe;
	assign r_TrailingEdge = w_CPOL ? pe : ne;
	
   //ready signal
	always @(posedge i_Clk or negedge i_Rst_L)
	begin
		if(~i_Rst_L)
		begin
			r_SPI_Clk_Cnt <= BYTEEDGES;
			o_MISO_ready <= 1'b1;
		end
		else 
		begin
			if(ne | pe)
			begin
			r_SPI_Clk_Cnt = r_SPI_Clk_Cnt - 1;
			end
			
			if(i_TX_DV)
			begin
				o_MISO_ready <= 0;
				r_SPI_Clk_Cnt <= BYTEEDGES;
			end
			
			else if(r_SPI_Clk_Cnt == 0)
			begin
				r_SPI_Clk_Cnt <= BYTEEDGES;
				o_MISO_ready <= 1'b1;
			end
			else if (r_SPI_Clk_Cnt > 0)
			begin
				o_MISO_ready <= 1'b0;
			end
			else
			begin
				o_MISO_ready <= 1'b1;
			end
		end
	end
	
	
	//data valid signal
	always @(posedge i_Clk or negedge i_Rst_L)
	begin
		if(~i_Rst_L) begin
			r_TX_Byte <= 8'h00;
			r_TX_DV <= 1'b0;
		end
		else
		begin
			r_TX_DV <= i_TX_DV;
			if (i_TX_DV) begin
			r_TX_Byte <= i_TX_Byte;
			end
		end
	end

	//transmit data
	always @(posedge i_Clk or negedge i_Rst_L)
	begin
		
		if(~i_Rst_L) begin
			r_SPI_MISO_Bit <= 1'b0;
			r_TX_Bit_Count <= 3'b111;
		end
		else
		begin
			if(o_MISO_ready) begin
				r_TX_Bit_Count <= 3'b111;	
			end
			
			else if (r_TX_DV)
			begin
				r_SPI_MISO_Bit <= r_TX_Byte[3'b111];
				r_TX_Bit_Count <= 3'b110;
			end
			else if((r_LeadingEdge & ~w_CPHA) | (r_TrailingEdge & w_CPHA))begin
				r_SPI_MISO_Bit <= r_TX_Byte[r_TX_Bit_Count];
				r_TX_Bit_Count <= r_TX_Bit_Count - 1;
			end
		end	
	end
	//assign high impedence when cs high
  assign o_SPI_MISO = i_SPI_CS_n ? 1'bZ : r_SPI_MISO_Bit;

endmodule // SPI_Slave