module fifo # ( parameter W = 8,
		parameter L = 8);
	(
	input clk,
	input rst_n,
	input wr_en,
	input rd_en,
	input [$clog2(L+1)-1:0] af_level,
	input [$clog2(L+1)-1:0] ae_level,
	input [W-1:0] wdata,
	output reg [W-1:0] rdata,
	output full,
	output empty,
	output af_flag,
	output ae_flag
);
reg [W-1:0]      mem [0:L-1];
reg [$clog2(L)-1:0] wr_ptr;
reg [$clog2(L)-1:0] rd_ptr;
reg [$clog2(L+1)-1:0] r_count;

wire[$clog2(L)-1:0] next_wr_ptr; 
wire[$clog2(L)-1:0] next_rd_ptr; 
wire rd;
wire wr;

assign rd = rd_en && !empty;
assign wr = wr_en && !full;
assign next_wr_ptr = ( wr_ptr == L - 1) ? 0 : wr_ptr + 1;
assign next_rd_ptr = (rd_ptr == L - 1) ? 0 : rd_ptr + 1;
assign empty = ( r_count == 0);
assign full = ( r_count == L );
assign af_flag = ( r_count >= af_level);
assign ae_flag = ( r_count <= ae_level);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wr_ptr <= 0;
			rd_ptr <= 0;
			r_count <= 0;

		end
		else begin
			if (wr) begin
				wr_ptr <= next_wr_ptr;
				mem[wr_ptr] <= wdata;
			end
				else if (!wr) begin
					wr_ptr <= wr_ptr;
					r_count <= r_count;
				end
			if (rd) begin
				rd_ptr <= next_rd_ptr;
				rdata <= mem[rd_ptr];

			end
			else if (!rd) begin
				rdata <= rdata;
				rd_ptr <= rd_ptr;
			end

	end



endmodule
