task run_test;
	integer i;
	integer expected_count;
	begin
		//-----------------TC1: Async_reset----------------------//
		fifo_write(8'hA);
		fifo_read;
		rst_n = 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		checker(" TC1_wr_ptr_clear", dut.wr_ptr, 0);
		checker(" TC1_rd_ptr_clear", dut.rd_ptr, 0);
		checker(" TC1_r_count_clear", dut.r_count,0);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		rst_n = 1;
		#1;
		@(posedge clk);
		@(posedge clk);
		checker(" TC1_empty_after_reset", empty, 1'b1);
		checker(" TC1_full_after_reset", full, 1'b0);
		checker(" TC1_ae_flag_after_reset", ae_flag, 1'b1);
		checker(" TC1_af_flag_after_reset", af_flag, 1'b0);
		@(posedge clk);
		@(posedge clk);

		//------------------TC11:Simultaneous_R/W-------------//
		rst_n = 0;
		#1;
		@(posedge clk);
		@(posedge clk);
		rst_n = 1;
		#1;
		@(posedge clk);
		@(posedge clk);
		fifo_write(8'hA);

		fifo_write_read(8'hB);

		fifo_write_read(8'hC);

		fifo_write_read(8'h9);


		fifo_write_read(8'h3);
			
		checker("TC11_full_empty_no_toggle", {empty,full}, 2'b0);
		fifo_read;
		#1;
		checker("TC11_r_count_after_many_cycles", dut.r_count , 0);
		@(posedge clk);
		rst_n = 0;
		@(posedge clk);
		rst_n = 1;
		@(posedge clk);

		
		//----------------TC12:Test_r_count_accuracy---------------//
		
		fifo_write(8'hD);
		@(posedge clk);
		@(posedge clk);

		fifo_write(8'h1);
		@(posedge clk);
		@(posedge clk);

		fifo_write(8'h2);
		@(posedge clk);
		@(posedge clk);

		fifo_write(8'hA);
		@(posedge clk);
		@(posedge clk);

		fifo_write(8'hC);
		@(posedge clk);
		@(posedge clk);

		fifo_read;
		@(posedge clk);

		fifo_read;
		@(posedge clk);

		fifo_read;
		@(posedge clk);

		checker("TC12:r_count_accuracy", dut.r_count, 2);
		@(posedge clk);
		

	end
endtask
