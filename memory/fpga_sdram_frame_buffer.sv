module fpga_sdram_frame_buffer(
	input clk,
	input reset_n,
	input write_clk,
	input read_clk,
	
	input [15:0] write_data,
	input we,
	input read,
	output wr_full,
	
	output op_clk,
	output reg vga_en,
	output re,
	output [15:0] read_data,
	
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [15:0] DRAM_DQ,
	output DRAM_LDQM,
	output DRAM_RAS_N,
	output DRAM_UDQM,
	output DRAM_WE_N
	
);


reg wr_fifo_clr;
reg rd_fifo_clr;
reg wr_zero;
reg rd_zero;
reg internal_re;
reg rd_empty;
wire wr_full_reg;
wire [18:0] wrcount;
wire [18:0] rdcount;
reg [15:0] write_data_reg;
reg we_reg;
reg [31:0] Cont;

Sdram_Control	u1	(	//	HOST Side
						   .REF_CLK(clk),
							.CLK(op_clk),
					      .RESET_N(reset_n),
							//	FIFO Write Side 
						   .WR_DATA(write_data),
							.WR(we && !wr_full),
							.WR_ADDR(0),
							.WR_MAX_ADDR(640*480),		//	525-18 25'h1ffffff 25'h4B000 25'h4B0000
							.WR_LENGTH(256),
							.WR_LOAD(wr_fifo_clr),
							//.WR_ZERO(wr_zero),
							.WR_CLK(write_clk),
							.WR_FULL(wr_full),
							.WR_COUNT(wrcount),
							//	FIFO Read Side 
						   .RD_DATA(read_data),
				        	.RD(read && !rd_empty),
				        	.RD_ADDR(0),			//	Read odd field and bypess blanking
							.RD_MAX_ADDR(640*480),
							.RD_LENGTH(256), //9'h80 9'd16
				        	.RD_LOAD(rd_fifo_clr),
							//.RD_ZERO(rd_zero),
							.RD_EMPTY(rd_empty),
							.RD_CLK(read_clk),
							.RD_COUNT(rdcount),
                     //	SDRAM Side
						   .SA(DRAM_ADDR),
						   .BA(DRAM_BA),
						   .CS_N(DRAM_CS_N),
						   .CKE(DRAM_CKE),
						   .RAS_N(DRAM_RAS_N),
				         .CAS_N(DRAM_CAS_N),
				         .WE_N(DRAM_WE_N),
						   .DQ(DRAM_DQ),
				         .DQM({DRAM_UDQM,DRAM_LDQM}),
							.SDR_CLK(DRAM_CLK)	
);

assign re = !rd_empty;
always @(posedge clk) begin
	if(!reset_n) begin
		wr_fifo_clr <= 1;
		rd_fifo_clr <= 1;
		//internal_re <= 0;
		wr_zero <= 0;
		rd_zero <= 0;
		vga_en <= 0;
		Cont <= 0;
	end else begin
		
		if(Cont<32'h11FFFFF)
			Cont	<=	Cont+1;
		if(Cont>=32'h1FFFFF) begin
			wr_fifo_clr <= 0;
			rd_fifo_clr <= 0;
		end else begin
			wr_fifo_clr <= 1;
			rd_fifo_clr <= 1;
		end
	end
end

always @(posedge clk) begin
	if(!reset_n) begin
		we_reg <= 0;
	end else begin
		write_data_reg <= write_data;
		if(we) begin
			we_reg <= 1;
		end else begin
			we_reg <= 0;
		end
	end
end
							
endmodule
