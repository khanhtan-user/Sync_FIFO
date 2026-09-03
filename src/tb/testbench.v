`timescale 1ns/1ps
module tb_fifo();
	parameter W = 8;
	parameter L = 8;	

	reg clk;
	reg rst_n;
	reg rd_en;
	reg wr_en;
	reg[$clog2(L+1)-1:0] af_level;
	reg[$clog2(L+1)-1:0] ae_level;
	reg [W-1:0] wdata;
	wire[W-1:0] rdata;
	wire af_flag;
	wire ae_flag;
	wire full;
	wire empty;
	integer error_count = 0;

	fifo #(.W(W), .L(L)) dut (
		.clk(clk),
		.rst_n(rst_n),
		.rd_en(rd_en),
		.wr_en(wr_en),
		.af_level(af_level),
		.ae_level(ae_level),
		.wdata(wdata),
		.rdata(rdata),
		.ae_flag(ae_flag),
		.af_flag(af_flag),
		.full(full),
		.empty(empty) );
	initial begin
		clk = 0;
	end
		always #5 clk = ~clk;
	task fifo_write(input [W-1:0] data); 
		begin
		@(posedge clk);
			wr_en = 1;
			wdata = data;
		
		@(posedge clk);
			wr_en = 0;
		
	end	
	endtask
	
	task fifo_read;
		begin
		@(posedge clk);	
			rd_en = 1;
		@(posedge clk);
			rd_en = 0;
		end
	endtask
	task fifo_write_read(input [W-1:0] data);
		begin
			@(posedge clk);
			wr_en = 1;
			rd_en = 1;
			wdata = data;
			@(posedge clk);
			wr_en = 0;
			rd_en = 0;
		end
	endtask

task checker ( input [511:0] name, input [31:0] actual, input [31:0] expected);
	begin
	if ( actual !== expected) begin
		$display ( "FAIL %0s . Actual = 0x%0h, Expect = 0x%0h, Time = %0t",name , actual,expected, $time);
		error_count = error_count + 1;
	end
	else begin
		$display ( " PASS %0s . Actual = 0x%0h, time = %0t", name , actual, $time);
	end
end
endtask
 `include "run_test.v"
 initial begin
	 rst_n = 0;
	 rd_en = 0;
	 wr_en = 0;
	 ae_level = 2;
	 af_level = L - 2;
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 rst_n = 1;
	 @(posedge clk);
	 @(posedge clk);
	 @(posedge clk);
	 run_test;
	 if ( error_count == 0)
		 $display(" Test_result PASSED");
	 else 
		 $display(" Test_result FAILED");
	 $finish;
 end

endmodule

	
