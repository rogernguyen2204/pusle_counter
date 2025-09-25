module register(
	input clk,
	input rst_n,
	input wr_en,
	input rd_en,
	input [9:0] addr,
	input [31:0] wdata,
	input overflow,
	input [2:0] count,
	output [31:0] rdata,
	output pulse_en,
	output count_clr
);
	// Parmeter
	parameter ADDR_CR = 10'h0;
	parameter ADDR_SR = 10'h4;

	// Pulse
	wire wrenAddr;
	assign wrenAddr = ((wr_en) && (addr == ADDR_CR));
	assign pulse_en = ((wdata[0] == 1'b1) && wrenAddr);
	
	// Count_clr
	wire count_clr_pre;
	reg clr;

	assign count_clr_pre = (wrenAddr) ? wdata[1] : clr ;

	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 1'b1) begin
			clr <= count_clr_pre;
		end else begin
			clr <= 1'b0;
		end
	end

	assign count_clr = clr;

	// Overflow
	wire wrenAddr2;
	assign wrenAddr2 = ((wr_en) && (addr == ADDR_SR));
	wire ovf_clear;
	wire ovf_set;
	assign ovf_clear = (wrenAddr2 && (wdata[3] == 1'b0));
	
	reg overflowRd;
	wire overflowRd_pre;

	assign ovf_set = (overflow) ? 1'b1 : overflowRd;
	assign overflowRd_pre = (ovf_clear) ? 1'b0 : ovf_set;

	always @(posedge clk or negedge rst_n) begin
		if (rst_n == 1'b1) begin
			overflowRd <= overflowRd_pre;
		end else begin
			overflowRd <= 1'b0;
		end
	end

	reg [31:0]  rd_pre;

	// Read logic
	always @(*) begin
		if (rd_en == 1'b1) begin
			case (addr)
				ADDR_CR: rd_pre = {30'h0, count_clr, 1'h0};
				ADDR_SR: rd_pre = {28'h0, overflowRd, count[2:0]};
				default: rd_pre = 32'h0;
			endcase
		end else begin
			rd_pre = 32'h0;
		end
	end

	assign rdata = rd_pre;

	





	



endmodule
