module counter_top(
	input clk,
	input rst_n,
	input wr_en,
	input rd_en,
	input [9:0] addr,
	input [31:0] wdata,
	output [31:0] rdata
);
	
	wire w1;
	wire w2;
	wire [2:0] w3;
	wire w4;



	register dut_register(
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr_en),
		.rd_en(rd_en),
		.addr(addr),
		.wdata(wdata),
		.overflow(w1),
		.count(w3),
		.rdata(rdata),
		.pulse_en(w2),
		.count_clr(w4)
	);

	counter dut_counter(
		.clk(clk),
		.rst_n(rst_n),
		.count_clr(w4),
		.count_en(w2),
		.count(w3),
		.overflow(w1)
	);






endmodule


