task run_test;
	integer i;
	integer error_count;
	begin
	//-----------------TC02:Single_Write---------------//
	rst_n = 0;
	@(posedge clk);
	@(posedge clk);

	rst_n = 1;
	@(posedge clk);

	fifo_write(8'hF0);
	@(posedge clk);

	checker("TC02:Single_Write:_wdata", dut.wdata, 8'hF0);
        checker("TC02:Single_Write:_wr_ptr", dut.wr_ptr, 1);
	checker("TC02:Single_Write:_empty", empty,0);
	checker("TC02:Single_Write:_full", full,0);
	checker("TC02:Single_Write:_r_count", dut.r_count, 1);
	
	fifo_write(8'h00); // case : increase coverage
	@(posedge clk);
	@(posedge clk);
	
	fifo_write(8'hFF); // case : increase coverage
	@(posedge clk);

	fifo_write(8'h00); // case : increase coverage

	@(posedge clk);
	rst_n = 0;
	@(posedge clk);
	@(posedge clk);
	
	rst_n = 1;
	@(posedge clk);
	//-------------------TC03:Write_from_empty_to_full---//
	fifo_write(8'hFF);
	@(posedge clk);

	fifo_write(8'h00);
	@(posedge clk);

	fifo_write(8'hC);
	@(posedge clk);
	
	checker("TC03:Write_from_empty_to_full:_ae_flag", ae_flag, 0);

	fifo_write(8'hD);
	@(posedge clk);
	
	fifo_write(8'h1);
	@(posedge clk);

	fifo_write(8'h2);
	@(posedge clk);
	
	checker("TC03:Write_from_empty_to_full:_af_flag", af_flag, 1);

	fifo_write(8'h3);
	@(posedge clk);

	fifo_write(8'h4);
	@(posedge clk);

	checker("TC03:Write_from_empty_to_full:_full", full, 1);
	checker("TC03:Write_from_empty_to_full:_wr_ptr", dut.wr_ptr, 0);
	checker("TC03:Write_from_empty_to_full:_r_count", dut.r_count, 8);

	//----------------TC04:Write_when_full--------//
	

	fifo_write(8'h8);
	@(posedge clk);


	checker("TC04:Write_when_full:_r_count", dut.r_count, 8);
	checker("TC04:Write_when_full:_full", full, 1);
	checker("TC04:Write_when_full:_af_flag", af_flag, 1);
	checker("TC04:Write_when_full:_wr_ptr", dut.wr_ptr, 0);

	@(posedge clk);
	rst_n = 0;
	@(posedge clk);
	@(posedge clk);

	rst_n = 1;
	@(posedge clk);
	//----------------TC05:Pointer_wrap_around_write--//
	

	fifo_write(8'hA);
	@(posedge clk);

	fifo_write(8'hC);
	@(posedge clk);
	
	fifo_write(8'hD);
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_write(8'h8);
	@(posedge clk);

	fifo_read;
	@(posedge clk);

	fifo_write(8'h9);
	@(posedge clk);

	fifo_write(8'h1);
	@(posedge clk);

	fifo_write(8'h7);
	@(posedge clk);

	fifo_write(8'hB);
	@(posedge clk);


	fifo_read;

	checker("TC05:Pointer_wrap_around_write:_wr_ptr", dut.wr_ptr, 0);

	@(posedge clk);

	rst_n = 0;
	@(posedge clk);
	
	rst_n = 1;
	@(posedge clk);
	@(posedge clk);

	//---------TC06:Write_to_check_af_flag-------//
	
	fifo_write(8'hB);
	@(posedge clk);

	fifo_write(8'hC);
	@(posedge clk);

	fifo_write(8'hD);
	@(posedge clk);

	fifo_write(8'hA);
	@(posedge clk);

	fifo_write(8'h1);
	@(posedge clk);

	fifo_write(8'h2);
	@(posedge clk);

	checker("TC06:Write_to_check_af_flag:_af_flag_go_high", af_flag, 1);
	@(posedge clk);

	fifo_read;
	@(posedge clk);
	checker("TC06:Write_to_check_af_flag:_af_flag_go_low", af_flag,0);


	rst_n = 0;
	@(posedge clk);
	@(posedge clk);
	
	rst_n = 1;
	@(posedge clk);

	


	end
endtask
