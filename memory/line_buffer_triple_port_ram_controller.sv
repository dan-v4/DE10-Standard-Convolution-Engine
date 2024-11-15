module line_buffer_triple_port_ram_controller(
	input write_clk,
	input read_clk,
	input reset_n,
	input write,
	input read,
	input [15:0] in_pixel,
	output [15:0] out_pixels [8:0],
	output read_ready,
	output read_valid
);

reg [10:0] read_addr;
reg [10:0] write_addr;

reg [15:0] q_t0 [2:0];
reg [15:0] q_t1 [2:0];
reg [15:0] q_t2 [2:0];
reg [15:0] q_t3 [2:0];

reg [3:0] we;

reg [1:0] line_counter;
reg [1:0] read_lb_pointer;
reg allow_read;

assign read_ready = allow_read; // && (line_counter != read_lb_pointer)

always @(posedge write_clk) begin
	if(!reset_n) begin
		write_addr <= 0;
		line_counter <= 0;
		allow_read <= 0;
	end else begin
		if(write) begin
			if(write_addr == 639) begin
				write_addr <= 0;
				line_counter <= line_counter + 1;
			end else begin
				write_addr <= write_addr + 1;
			end
		end
		
		if(line_counter == 0) begin
			we[0] <= write;
			we[1] <= 0;
			we[2] <= 0;
			we[3] <= 0;
		end else if(line_counter == 1) begin
			we[0] <= 0;
			we[1] <= write;
			we[2] <= 0;
			we[3] <= 0;
		end else if(line_counter == 2) begin
			we[0] <= 0;
			we[1] <= 0;
			we[2] <= write;
			we[3] <= 0;
		end else if(line_counter == 3) begin
			we[0] <= 0;
			we[1] <= 0;
			we[2] <= 0;
			we[3] <= write;
			allow_read <= 1;
		end
	end
end

reg read_reg;

always @(posedge read_clk) begin
	if(!reset_n) begin
		read_lb_pointer <= 0;
		read_addr <= 0;
		read_valid <= 0;
	end else begin
		if(write && read_ready) begin
			if(read_addr == 639) begin
				read_addr <= 0;
				read_lb_pointer <= read_lb_pointer + 1;
			end else begin
				read_addr <= read_addr + 1;
			end
			read_valid <= 1;
		end else begin
			read_valid <= 0;
		end
		
		if(read_lb_pointer == 0) begin
			out_pixels[0] <= q_t0[0];
			out_pixels[1] <= q_t0[1];
			out_pixels[2] <= q_t0[2];
			out_pixels[3] <= q_t1[0];
			out_pixels[4] <= q_t1[1];
			out_pixels[5] <= q_t1[2];
			out_pixels[6] <= q_t2[0];
			out_pixels[7] <= q_t2[1];
			out_pixels[8] <= q_t2[2];
		end else if(read_lb_pointer == 1) begin
			out_pixels[0] <= q_t1[0];
			out_pixels[1] <= q_t1[1];
			out_pixels[2] <= q_t1[2];
			out_pixels[3] <= q_t2[0];
			out_pixels[4] <= q_t2[1];
			out_pixels[5] <= q_t2[2];
			out_pixels[6] <= q_t3[0];
			out_pixels[7] <= q_t3[1];
			out_pixels[8] <= q_t3[2];
		end else if(read_lb_pointer == 2) begin
			out_pixels[0] <= q_t2[0];
			out_pixels[1] <= q_t2[1];
			out_pixels[2] <= q_t2[2];
			out_pixels[3] <= q_t3[0];
			out_pixels[4] <= q_t3[1];
			out_pixels[5] <= q_t3[2];
			out_pixels[6] <= q_t0[0];
			out_pixels[7] <= q_t0[1];
			out_pixels[8] <= q_t0[2];
		end else if(read_lb_pointer == 3) begin
			out_pixels[0] <= q_t3[0];
			out_pixels[1] <= q_t3[1];
			out_pixels[2] <= q_t3[2];
			out_pixels[3] <= q_t0[0];
			out_pixels[4] <= q_t0[1];
			out_pixels[5] <= q_t0[2];
			out_pixels[6] <= q_t1[0];
			out_pixels[7] <= q_t1[1];
			out_pixels[8] <= q_t1[2];
		end 
		
	end
end



triple_read_ram_dual_clock t0
(
	.data(in_pixel),
	.read_addr1(read_addr-1), 
	.read_addr2(read_addr), 
	.read_addr3(read_addr+1), 
	.write_addr(write_addr),
	.we(we[0]), 
	.read_clock(read_clk), 
	.write_clock(write_clk),
	.q1(q_t0[0]), 
	.q2(q_t0[1]), 
	.q3(q_t0[2])
);

triple_read_ram_dual_clock t1
(
	.data(in_pixel),
	.read_addr1(read_addr-1), 
	.read_addr2(read_addr), 
	.read_addr3(read_addr+1), 
	.write_addr(write_addr),
	.we(we[1]), 
	.read_clock(read_clk), 
	.write_clock(write_clk),
	.q1(q_t1[0]), 
	.q2(q_t1[1]), 
	.q3(q_t1[2])
);

triple_read_ram_dual_clock t2
(
	.data(in_pixel),
	.read_addr1(read_addr-1), 
	.read_addr2(read_addr), 
	.read_addr3(read_addr+1), 
	.write_addr(write_addr),
	.we(we[2]), 
	.read_clock(read_clk), 
	.write_clock(write_clk),
	.q1(q_t2[0]), 
	.q2(q_t2[1]), 
	.q3(q_t2[2])
);

triple_read_ram_dual_clock t3
(
	.data(in_pixel),
	.read_addr1(read_addr-1), 
	.read_addr2(read_addr), 
	.read_addr3(read_addr+1), 
	.write_addr(write_addr),
	.we(we[3]), 
	.read_clock(read_clk), 
	.write_clock(write_clk),
	.q1(q_t3[0]), 
	.q2(q_t3[1]), 
	.q3(q_t3[2])
);
endmodule