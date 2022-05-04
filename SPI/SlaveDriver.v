module SlaveDriver(
	input i_FPGA_clk,
	input i_FPGA_rst,
	input[7:0] i_RXByte,
	input i_slave_ready,
	input i_RXdv,
	output reg[15:0] wrData,
	output reg[3:0] raddr, waddr,
	input[15:0] reData,
	output reg o_write,
	output[7:0] o_TXByte,
	output reg o_TXdv
	);

reg[7:0] r_CMDADDR; //command and address
reg[7:0] r_rxbyte1; //first data byte
reg[7:0] r_rxbyte2; //second data byte
reg[7:0] r_txbyte; //first data byte
reg[3:0] r_bytecount;
reg[15:0] r_data;//full data
reg[15:0] r_readData; //read data
reg[3:0] r_bytenum; //number to indicate send back byte just for testing
wire r_slaveready;
reg r_dataready;
// store 3 bytes 
always @(posedge i_FPGA_clk or negedge i_FPGA_rst)
begin 
	if(~i_FPGA_rst)
	begin
		r_bytecount <= 3'b000;
		r_CMDADDR <= 8'h00;
		r_rxbyte1 <= 8'h00;
		r_rxbyte2 <= 8'h00;
		r_data <= 16'h0000;
	end
	else
	begin
		case(r_bytecount)
		0:
		begin
			if(i_RXdv)
			begin
				r_dataready <= 0;
				r_bytecount <= r_bytecount + 1;
			end
		end
		1:
		begin
			if(i_RXdv)
			begin
				r_CMDADDR <= i_RXByte;
				r_bytecount <= r_bytecount + 1;
			end
		end
		2:
		begin
			if(i_RXdv)
			begin
				r_rxbyte1 <= i_RXByte;
				r_bytecount <= r_bytecount + 1;
			end
		end
		3:
		begin
			if(i_RXdv)
			begin
				r_rxbyte2 <= i_RXByte;
				r_bytecount <= r_bytecount + 1;
			end
		end
		4:
		begin
			r_data <= {r_rxbyte1,r_rxbyte2};
			r_bytecount <= 0;
			r_dataready <= 1;
		end
		endcase
	end
end


always @(posedge i_FPGA_clk or negedge i_FPGA_rst)
begin
	if(~i_FPGA_rst)
	begin
		waddr <= 4'h0;
		o_write <= 0;
		wrData <= 16'h0000;
		raddr <= 4'h0;
		r_readData <= 16'h0000;
	end
	else
	begin
		case(r_CMDADDR[7:4])
		4'b0000:
		begin
			if (r_dataready)
			begin
				waddr <= r_CMDADDR[3:0];
				o_write <= 1;
				wrData <= r_data;
			end
			else
			begin
				o_write <= 0;
			end

		end
		/*
		4'b1111: //testing only, no operation on real dac
		begin
			raddr <= r_CMDADDR[3:0];
			o_write <= 0;
			//r_readData <= reData;
		end
	*/
		default:
		begin
			waddr <= 4'h0;
			o_write <= 0;
			wrData <= 16'h0000;
			raddr <= 4'h0;
		end
		endcase
	end
end

//transmit last cylces command
always @(posedge i_FPGA_clk or negedge i_FPGA_rst)
begin
	if(~i_FPGA_rst)
	begin
		r_bytenum <= 0;
		o_TXdv <= 0;
		r_txbyte <= 8'h00;
	end
	else
		
		if(i_slave_ready)
		begin
			case(r_bytenum)
			0:
			begin
				r_txbyte <= 8'h00;
				o_TXdv <= 1;
				r_bytenum <= r_bytenum + 1;
			end
			1:
			begin
				r_txbyte <= r_CMDADDR;
				o_TXdv <= 1;
				r_bytenum <= r_bytenum + 1;
			end
			2:
			begin
				r_txbyte <= reData[15:8];
				o_TXdv <= 1;
				r_bytenum <= r_bytenum + 1;
			end
			3:
			begin
				r_txbyte <= reData[7:0];
				o_TXdv <= 1;
				r_bytenum <= 0;
			end
			endcase
		end
		else
		begin
			o_TXdv <= 0;
		end
end

assign o_TXByte = r_txbyte;
endmodule


