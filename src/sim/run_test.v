task run_test;
	integer i;
	integer error_count;
	begin
	//------TC07:Single_Read--------//
	
	rst_n = 0;
	@(posedge clk);
	@(posedge clk);
	
	rst_n = 1;
	@(posedge clk);
	
	fifo_write(8'hB);
	@(posedge clk);
	
	checker("TC07:Single_Read:_r_count_after_1st_write", dut.r_count, 1);
	checker("TC07:Single_Read:_empty_after_1st_write", empty,0);
	fifo_read;
	@(posedge clk);
	
	checker("TC07:Single_Read:_empty_after_1st_read", empty,1);
	checker("TC07:Single_Read:_Rdata", rdata, 8'hB);
	checker("TC07:Single_Read:full_after_1st_read", full,0);	checker("TC07:Single_Read:_r_count_after_1st_read", dut.r_count, 0);
	checker("TC07:Single_Read:_r_ptr_after_1st_read", dut.rd_ptr, 1);

	@(posedge clk);

	rst_n = 0;
	@(posedge clk);
	@(posedge clk);

	rst_n = 1;
	@(posedge clk);

	//-----------TC08:Read_from_full_to_empty---------//
	
	fifo_write(8'hB2);
	@(posedge clk);

	fifo_write(8'h00);
	@(posedge clk);

	fifo_write(8'hFF);
	@(posedge clk);

	fifo_write(8'h5A);
	@(posedge clk);

	fifo_write(8'hB);
	@(posedge clk);

	fifo_write(8'h6);
	@(posedge clk);

	fifo_write(8'h9);
	@(posedge clk);

	fifo_write(8'h00);
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);
	
	fifo_read;
	@(posedge clk);
	checker("TC08:Read_from_full_to_empty:_ae_flag", ae_flag, 1);
	fifo_read;
	@(posedge clk);

	checker("TC08:Read_from_full_to_empty:_empty", empty, 1);
	checker("TC08:Read_from_full_to_empty:_full", full, 0);
	checker("TC08:Read_from_full_to_empty:_r_count", dut.r_count, 0);
	checker("TC08:Read_from_full_to_empty:_rd_ptr", dut.rd_ptr, 0);
	
	@(posedge clk);
	rst_n = 0;
	@(posedge clk);
	
	rst_n = 1;
	@(posedge clk);
	@(posedge clk);


	//-------------------TC09:Read_when_FIFO_empty------//
	
	fifo_read;
	@(posedge clk);

	checker("TC09:Read_when_FIFO_empty:_r_count", dut.r_count, 0);
	checker("TC09:Read_when_FIFO_empty:_rd_ptr", dut.rd_ptr,0);
	checker("TC09:Read_when_FIFO_empty:_empty", empty, 1);

	//--------------TC10:Pointer_wrap_around_read------//
	
	fifo_write(8'hA);
	@(posedge clk);

	fifo_write(8'hB);
	@(posedge clk);

	fifo_write(8'hC);
	@(posedge clk);
	
	fifo_write(8'hA);
	@(posedge clk);

	fifo_write(8'h1);
	@(posedge clk);

	fifo_write(8'h2);
	@(posedge clk);

	fifo_write(8'h9);
	@(posedge clk);
	
	fifo_write(8'hFF);
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	checker("TC10:Pointer_wrap_around_Read:_rd_ptr", dut.rd_ptr,0);
	@(posedge clk);
	@(posedge clk);

	rst_n = 0;
	@(posedge clk);

	rst_n = 1;
	@(posedge clk);


	end
endtask
