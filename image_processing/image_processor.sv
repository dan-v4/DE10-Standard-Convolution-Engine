module image_processor(
	input write_clk,
	input process_clk,
	input reset_n,
	input kernel_switch,
	input pixel_valid,
	input [15:0] pixel_in,
	
	output [15:0] out_pixel,
	output out_pixel_valid
);

wire read_ready;
wire read_valid;
wire  [15:0] out_buffer [8:0];

wire rdempty_f0;
wire wrfull_f0;

wire [15:0] q_f0;
wire rdreq_f0;
assign rdreq_f0 = !rdempty_f0;
image_processor_fifo f0(
	.aclr(!reset_n),
	.data(pixel_in),
	.rdclk(process_clk),
	.rdreq(rdreq_f0),
	.wrclk(write_clk),
	.wrreq(pixel_valid),
	.q(q_f0),
	.rdempty(rdempty_f0),
	.wrfull(wrfull_f0)
);

line_buffer_triple_port_ram_controller lbc(
	.write_clk(write_clk),
	.read_clk(process_clk),
	.reset_n(reset_n),
	.write(rdreq_f0),
	.read(read),
	.in_pixel(q_f0),
	.out_pixels(out_buffer),
	.read_ready(read_ready),
	.read_valid(read_valid)
);

wire read;

convolution_controller(
	.clk(process_clk),
	.reset_n(reset_n),
	.input_ready(read_ready),
	.valid_buffer(read_valid),
	.kernel_switch(kernel_switch),
	.pixel_buffer(out_buffer),
	
	.read(read),
	.pixel_valid(out_pixel_valid),
	.out_pixel(out_pixel)
);



endmodule
