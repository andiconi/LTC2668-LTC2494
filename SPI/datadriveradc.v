//module if for testing should be done at higher level

module datadriver(clk, rst,i_ready, o_dataValid, o_DATA);
	input clk, rst , i_ready;
	output o_dataValid;
	reg r_dv;
	output [31:0] o_DATA;
	reg[31:0] r_data;
	reg[1:0]bytecount;
	
	always @(posedge clk or negedge rst)
	begin
		if(~rst)
		begin
			r_dv <= 0;
			bytecount <= 0;
			r_data <= 32'b10000000000000000000000000000000;
		end
		else
		begin
			if(i_ready)
			begin
				case(bytecount)
				0:
				begin
					r_data <= 32'b10100101100001010000000000000000; //gain of 64 on address 101
					r_dv <= 1;
					bytecount <= bytecount + 1;
				end
				1:
				begin
					r_data <= 32'b10000000000000000000000000000000;
					r_dv <= 1;
					bytecount <= 0;
				end
				endcase
			end
			else 
			begin
				r_dv <= 0;
			end
		end
	end
	
	assign o_DATA = r_data;
	assign o_dataValid = r_dv;
endmodule
