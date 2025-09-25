module test_bench;

	parameter ADDR_CR = 10'h0;
	parameter ADDR_SR = 10'h4;

	// driving signals
	reg clk;
	reg rst_n;
	reg wr_en;
	reg rd_en;
	reg [9:0] addr;
	reg [31:0] wdata;
	wire [31:0] rdata;

	counter_top dut(
		.clk(clk),
		.rst_n(rst_n),
		.wr_en(wr_en),
		.rd_en(rd_en),
		.addr(addr),
		.wdata(wdata),
		.rdata(rdata)
	);

	initial begin
		clk = 0;
		forever #25 clk = ~clk;
	end

	initial begin
		rst_n = 0;
		#50 rst_n = 1;
	end

	initial begin

		#1;
		wr_en = 1'b0;
		rd_en = 1'b0;
		addr = ADDR_CR;
		wdata = 32'h0;

		#100;
		// RESET VALUE CHECK
		@(negedge clk);
		#1 rst_n = 0;
		@(posedge clk);
		#1;
		$display("------------------ TEST BEGIN ---------------");
		$display("1. RESET VALUE TEST");
		$display("1.1 CR register");
		rd_en = 1'b1;
		#1;

		if (rdata === 32'h0) begin
			$display("Time: %4t | RESET VALUE TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | RESET VALUE TEST: FAILED. EXPECTED VALUE: 32'h0. ACTUAL VALUE: 32'h%h.", $time, rdata);
		end 

		@(posedge clk);
		#1 rd_en = 1'b0;
		addr = ADDR_SR;
		$display("1.2 SR register");

		@(posedge clk);
		#1 rd_en = 1'b1;
		#1;
		
		if (rdata === 32'h0) begin
			$display("Time: %4t | RESET VALUE TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | RESET VALUE TEST: FAILED. EXPECTED VALUE: 32'h0. ACTUAL VALUE: 32'h%h.", $time, rdata);
		end 
	
		@(posedge clk);
		#1 rd_en = 1'b0;
		rst_n = 1'b1;
		
		// RESERVED BIT TEST	
		@(posedge clk);
		#1;
		$display("2. RESERVED BIT  TEST");
		$display("2.1 CR register");
		write(ADDR_CR, 32'hffff_fffc);	
		#1;
			
		if (rdata === 32'h0) begin
			$display("Time: %4t | RESERVED BIT TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | RESERVED BIT TEST: FAILED. EXPECTED VALUE: 32'h0. ACTUAL VALUE: 32'h%h.", $time, rdata);
		end 

		@(posedge clk);
		#1 rd_en = 1'b0;
		$display("2.2 SR register");
		write(ADDR_SR, 32'hffff_fff0);

		#1;
		
		if (rdata === 32'h0) begin
			$display("Time: %4t | RESERVED BIT TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | RESERVED BIT TEST: FAILED. EXPECTED VALUE: 32'h0. ACTUAL VALUE: 32'h%h.", $time, rdata);
		end 
			
		// WRITE/READ ACCESS
		@(posedge clk);
		#1 $display("3. WRITE/READ ACCESS TEST");
		$display("3.1 CR register");
		$display("WRITE/READ DEFAULT VALUE");
		write(ADDR_CR,32'h0);	
		read(ADDR_CR, 32'h0);

		$display("WRITE/READ pulse_en");
		write(ADDR_CR, 32'h0000_0001);
		read(ADDR_CR, 32'h0000_0000);
		$display("WRITE/READ Count_clr");
		write(ADDR_CR, 32'h0000_0002);
		read(ADDR_CR,32'h0000_0002);
		
		$display("3.2 SR register");
		$display("WRITE/READ overflow");
		write(ADDR_SR, 32'h0000_0000);
		read(ADDR_SR,32'h0000_0000);

		// RESERVED ADDRESS CHECK
		$display("4. RESERVED ADDRESS CHECK");
		write(10'h10, 32'haaaa_aaaa);
		read(10'h10, 32'h0000_0000);
		write(10'h50, 32'haaaa_aaaa);
		read(10'h50, 32'h0000_0000);
		write(10'h3fc, 32'haaaa_aaaa);
		read(10'h3fc, 32'h0000_0000);

		// PULSE GENERATE and COUNT TEST
		write(ADDR_CR, 32'h0000_0000);
		#1;
		$display("5. PULSE GENERATE AND COUNT TEST");
		@(posedge clk);
		#1 rd_en = 1'b1;
		pulseGenerate(1);
		countValue(32'h0000_0001);
		pulseGenerate(3);
		countValue(32'h0000_0004);
		pulseGenerate(2);
		countValue(32'h0000_0006);

		//Overflow Test
		@(posedge clk);
		#1;
		$display("6. OVEFLOW FLAG TEST");
		pulseGenerate(1);
		pulseGenerate(1);

		@(posedge clk);
		#1;
		addr = ADDR_SR;
		#1;

		if (rdata[3] === 1'b1) begin
			$display("Time: %4t | OVERFLOW FLAG TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | OVEFLOW FLAG TEST: FAILED. EXPECTED VALUE: 1'b1. ACTUAL VALUE: 1'b%b", $time, rdata[3]);
		end 

		// Overflow FLag and clear
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		#1;

		if (rdata[3] === 1'b1) begin
			$display("Time: %4t | OVERFLOW FLAG HOLD TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | OVEFLOW FLAG HOLD TEST: FAILED. EXPECTED VALUE: 1'b1. ACTUAL VALUE: 1'b%b. THE FLAG SHOULD ONLY BE CLEAR WHEN WRITE 0 TO SR[3]", $time, rdata[3]);
		end 
		
		#1;
		wr_en = 1'b1;
		wdata = 32'h0000_0000;

		@(posedge clk);
		#1;
		if (rdata[3] === 1'b0) begin
			$display("Time: %4t | OVERFLOW FLAG CLEAR TEST: PASSED", $time);
		end else begin
			$display("Time: %4t | OVEFLOW FLAG CLEAR TEST: FAILED. EXPECTED VALUE: 1'b0. ACTUAL VALUE: 1'b%b.", $time, rdata[3]);
		end


		// Count recycle
		#1 rd_en = 1'b1;
		$display("7. COUNT RECYCLE TEST");
		pulseGenerate(1);
		countValue(32'h0000_0001);

		// Count clear
		#1;
		$display("8. COUNT CLEAR");
		addr = ADDR_CR;
		wdata = 32'h0000_0002;
		wr_en = 1'b1;
		@(posedge clk);
		#1;
		countValue(32'h0000_0000);



		// End simulation 
		#100;
		$finish;

	end

	task write;
		input [10:0] t_addr;
		input [31:0] t_wdata;

		begin
			@(posedge clk);
			#1 addr = t_addr;
			wdata = t_wdata;
			wr_en = 1'b1;
			$display("Writing 32'h%h ...", t_wdata);

			@(posedge clk);
			#1 wdata = 32'hx;
			wr_en = 1'b0;
			rd_en = 1'b1;

		end
	endtask

	task read;
		input [10:0] t_addr;
		input [31:0] expected_value;

		begin
			@(posedge clk);
			#1 rd_en = 1'b1;
			#1;
			$display("READING FROM ADDRESS: 10'h%h", t_addr);
		
			if (rdata === expected_value) begin
				$display("Time: %4t | READ 32'h%h VALUE TEST: PASSED", $time, expected_value);
			end else begin
				$display("Time: %4t | READ 32'h%h VALUE TEST: FAILED. EXPECTED VALUE: 32'h%h. ACTUAL VALUE: 32'h%h.", $time, expected_value, expected_value, rdata);
			end 

			@(posedge clk);
			#1 rd_en = 1'b0;
		end
	endtask

	task pulseGenerate;
		input integer number;

		begin
			@(posedge clk);
			#1 wdata = 32'h1;
			wr_en  = 1'b0;
			addr = ADDR_CR;
			repeat (number) begin
				@(posedge clk);
				#1 wr_en = 1'b1;
				@(posedge clk);
				#1 wr_en = 1'b0;
			end
		end
	endtask

	task countValue;
		input [31:0] expected_val;

		begin
			@(posedge clk);
			#1;
			addr = ADDR_SR;
			rd_en = 1'b1;
			#1;
			if (rdata === expected_val) begin
				$display("Time: %4t | COUNTER COUNT: 3'b%b:  PASSED", $time, expected_val[2:0]);
			end else begin
				$display("Time: %4t | COUNTER COUNT: 3'b%b: FAILED. ACTUAl VALUE: 3'b%b", $time, expected_val[2:0], rdata[2:0]);
			end
		end
	endtask
		


endmodule
