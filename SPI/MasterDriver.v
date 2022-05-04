module MasterDriver(
	input i_FPGA_clk, //clock
	input i_FPGA_rst, //reset
	output[4:0] o_MOSI_count,//bytecount
	output[7:0] inputByte, //output mosi byte to master module
	output reg o_MOSIdv, //mosi data valid
	output o_CS, //CS control for ADC
	output o_ready, //ready signal for higher level
	output o_EOC_L,//End of Conversion for datadriver
	input i_MOSI_ready,//ready signal from spi module
	input i_DataValid, // data valid from higher level
	input[31:0] i_DAC_DATA, //dat from higher level
	input i_MISO //miso line to monitor for EOC for ADC
	);
	
	reg[7:0] r_byte; //register for byte to MASTER
	reg[31:0] r_DAC_Byte; //register from datadriver
	reg [3:0] bytecount = 0; //state machine counter
	reg r_ready; 
	reg r_EOC_L;
	reg r_CS;
	
	//Goes through DAC byte and controls master module properly
	always @(posedge i_FPGA_clk or negedge i_FPGA_rst) 
	begin 
		if(~i_FPGA_rst) 
		begin
			o_MOSIdv <= 0;
			r_byte <= 8'h00;
			r_DAC_Byte <= 32'h00000000;
			bytecount <= 0;
			r_ready <= 1;
			r_CS <= 1;
		end
		else
		begin 
			if(i_MOSI_ready)
			begin	
				case(bytecount)
				0:
				begin
					if(i_DataValid)
					begin
						/////////////Check for end of conversion. only for adc/////////
						if(i_DAC_DATA[31] && r_CS) 	
						begin
							r_CS <= 0;
							bytecount <= 3;
						end
						///////////////////////////////////////////////////////////////
						else
						begin
							r_byte <= i_DAC_DATA[23:16]; //send first byte
							r_DAC_Byte <= i_DAC_DATA; //save input to register
							o_MOSIdv <= 1;
							r_ready <= 0;
							bytecount <= bytecount + 1;
							r_CS <= 1;
						end
					end
				end
				1:
				begin
					r_byte <= r_DAC_Byte[15:8];
					o_MOSIdv <= 1;
					bytecount <= bytecount + 1;
				end
				2:
				begin
					r_byte <= r_DAC_Byte[7:0];
					o_MOSIdv <= 1;
					bytecount <= bytecount + 1;
				end
				3:
				begin
				r_ready <= 1;
				bytecount <= 0;
				r_CS <= 1;
				end
				endcase
			end
		else
		begin					
			o_MOSIdv <= 0;
		end
		end
		
	end

	assign o_ready = i_DataValid ? 0:r_ready; // as soon as datadriver sets datavalid high, ready signal goes low
	assign o_MOSI_count = 3; //count for bytes ADC and DAC both use 24bits or 3 bytes
	assign o_CS = r_CS; //Chip select control for ADC
	assign o_EOC_L = (~r_CS && ~i_MISO) ? 0:1; 	//Check for end of conversion. only for adc
	assign inputByte = r_byte; 
endmodule
	