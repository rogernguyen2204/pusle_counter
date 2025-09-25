module counter(
	input clk,
	input rst_n,
	input count_clr,
	input count_en,
	output [2:0] count,
	output overflow
);
	// Variable declare
	reg [2:0] cnt;
	wire [2:0] cnt_pre;

	// Counter
	assign cnt_pre = count_clr ? 3'h0 : 
			 count_en  ? cnt + 3'h1 :
			 cnt;
	always @(posedge clk or negedge rst_n) begin
		if ((rst_n == 1'b1) && (overflow == 1'b0)) begin
			cnt <= cnt_pre;
		end else begin
			cnt <= 3'h0;
		end
	end

	assign count = cnt;
	assign overflow = ((count == 3'h7) && (count_en == 1'b1));
	
	



endmodule
