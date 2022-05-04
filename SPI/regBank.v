//16 x 16 bit register bank
module regBank(clk, reset,rData, wData, raddr, waddr, write);
	input clk, write, reset;
	input[3:0] raddr, waddr;
	input[15:0] wData;
	output[15:0] rData;
	integer k;

	reg[15:0] regfile[0:15];
	
	assign rData = regfile[raddr];
	
	always @ (posedge clk)
	begin
		if(~reset)
		begin
			for (k = 0; k < 16; k = k + 1)
			begin
				regfile[k] <= 0;
			end
		end
		else if(write)
		begin
			regfile[waddr] <= wData;
		end
	end
endmodule
