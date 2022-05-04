//This module contains logic to send data to SPI correctly.
module datadriver(rst, clk,i_MODE,i_ready,i_EOC, o_dataValid, o_DATA);
	input rst, clk ,i_MODE, i_ready, i_EOC; //mode switches between ADC and DAC, EOC is End of Conversion, Ready is from master driver module.
	output o_dataValid; //signal to master driver module to say data is valid
	output [31:0] o_DATA; //Data line. first 8 bits can be used to communicate between datadriver and masterdriver. (currently a 1 in the MSB represents check for conversion)
	reg[31:0] r_data; //register for data
	reg[1:0]bytecount; 
	reg r_dv;
	parameter DAC = 0;
	parameter ADC = 1;
   // Switch between DAC and ADC. DAC = 0, ADC = 1
	
	//FSM
	always @(posedge clk or negedge rst)
	begin
		if(~rst)
		begin
			r_dv <= 0;
			bytecount <= 0;
			r_data <= 32'h00000000;
		end
		else
		begin
			case(i_MODE)
			DAC:
			begin
			//DAC Code
				if(i_ready)
				begin
				//***********modify this code to change how the data is sent ***********\\
					case(bytecount)
					0:
					begin
						r_data <= 32'h00289B7E; //2.13v (Modify to change command)
						r_dv <= 1;
						bytecount <= bytecount + 1;
					end
					1:
					begin
						r_data <= 32'h00F00000; // no op to read back on miso
						r_dv <= 1;
						bytecount <= 0;
					end
					endcase
				//***********************************************************************\\
				end
				else 
				begin
					r_dv <= 0;
				end
			end
			ADC:
			begin
			//ADC Code
				if(i_ready)
				begin
				//***********modify this code to change how the data is sent ***********\\
					case(bytecount)
					0:
					begin
						if(~i_EOC)
						begin            //      |              |
							r_data <= 32'b00000000101000001000000000000000; //in+ at 0 in- at 1 gain of 1 auto calibration
							bytecount <= bytecount + 1;
						end
						else
						begin
							r_data <= 32'b10000000100000000000000000000000; //SET CS LOW TO CHECK FOR EOC (this is necessary for the ADC)
						end
						r_dv <= 1;
					end
					1:
					begin
						r_data <= 32'b00000000100000000000000000000000; //keep previous
						r_dv <= 1;
						bytecount <= 0;
					end
					endcase
				//***********************************************************************\\
				end
				else 
				begin
					r_dv <= 0;
				end
			end
			endcase
		end
	end
	
	assign o_DATA = r_data;
	assign o_dataValid = r_dv;
endmodule
