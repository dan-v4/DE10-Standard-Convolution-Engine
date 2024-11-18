module convolution_controller(
	input clk,
	input reset_n,
	input input_ready,
	input valid_buffer,
	input kernel_switch,
	input [15:0] pixel_buffer [8:0],
	
	output read,
	output pixel_valid,
	output [15:0] out_pixel
);

localparam SHARPEN_OFFSET_G = 384;
localparam SHARPEN_OFFSET_RB = 256;

localparam EMBOSS_OFFSET_G = 384;
localparam EMBOSS_OFFSET_RB = 256;


localparam OO_OFFSET_G = 0;
localparam OO_OFFSET_RB = 0;

wire valid_out_conv;
wire [47:0] out_pixel_46b;
reg signed [5:0] kernel [8:0];
reg [15:0] pixel_buffer_conv [8:0];
reg [1:0] kernel_select;

reg signed [9:0] scale_bias_g;
reg signed [9:0] scale_bias_rb;

assign pixel_valid = valid_out;
convolution c0(
	.clk(clk),
	.valid_buffer(valid_buffer),
	.pixel_buffer(pixel_buffer),
	.kernel(kernel),
	.scale_bias_g(scale_bias_g),
	.scale_bias_rb(scale_bias_rb),
	.valid_out(valid_out),
	.out_pixel(out_pixel_46b)
	//output [9:0] LEDR
	
);

always @(*) begin
	case(kernel_select)//47:32, 31:16, 15:0
		0: out_pixel = {out_pixel_46b[36:32], out_pixel_46b[21:16], out_pixel_46b[4:0]};//identity kernel
		1: out_pixel = {out_pixel_46b[36:32], out_pixel_46b[21:16], out_pixel_46b[4:0]};//sharpen max range: 9bits + 1 g 8b + 1 rb, min range: 8bit g 7b rb, max val: 320 g 160 rb, min val: -256 g -128 rb
		2: out_pixel = {out_pixel_46b[36:32], out_pixel_46b[21:16], out_pixel_46b[4:0]};//emboss max  range: 9bits + 1 g 8b + 1 rb, min range: 8bit g 7b rb, max val: 192 g 96 rb, min val: -384 g -192 rb
		3: out_pixel = {out_pixel_46b[36:32], out_pixel_46b[21:16], out_pixel_46b[4:0]};//idk? max  range: 9bits + 1 g 8b + 1 rb, min range: 9bits g 8b rb, max val: 512 g 256 rb, min val: -512 g -256 rb
		default: out_pixel = {out_pixel_46b[36:32], out_pixel_46b[21:16], out_pixel_46b[4:0]};//identity kernel
	endcase
end

reg valid_buffer_conv;
always @(posedge clk) begin
	if(input_ready && valid_buffer) begin
		valid_buffer_conv <= 1;
		pixel_buffer_conv <= pixel_buffer;
	end else begin
		valid_buffer_conv <= 0;
	end
	
	if(input_ready) begin
		read <= 1;
	end else begin
		read <= 0;
	end
end

reg debounce = 0;
always @(posedge clk) begin
	if(!reset_n) begin
		kernel_select <= 0;
		debounce <= 0;
	end else begin
		if(!kernel_switch && !debounce) begin
			kernel_select <= kernel_select + 1;
			debounce <= 1;
		end else if(kernel_switch) begin
			debounce <= 0;
		end
	end
end

always @(posedge clk) begin
	if(kernel_select == 0) begin
		kernel[0] <= 0;
		kernel[1] <= 0;
		kernel[2] <= 0;
		kernel[3] <= 0;
		kernel[4] <= 1;
		kernel[5] <= 0;
		kernel[6] <= 0;
		kernel[7] <= 0;
		kernel[8] <= 0;
		scale_bias_g <= 0;
		scale_bias_rb <= 0;
	end else if(kernel_select == 1) begin
		kernel[0] <= 0;
		kernel[1] <= -1;
		kernel[2] <= 0;
		kernel[3] <= -1;
		kernel[4] <= 5;
		kernel[5] <= -1;
		kernel[6] <= 0;
		kernel[7] <= -1;
		kernel[8] <= 0;
		scale_bias_g <= SHARPEN_OFFSET_G;
		scale_bias_rb <= SHARPEN_OFFSET_RB;
	end else if(kernel_select == 2) begin
		kernel[0] <= -2;
		kernel[1] <= -1;
		kernel[2] <= 0;
		kernel[3] <= -1;
		kernel[4] <= 1;
		kernel[5] <= 1;
		kernel[6] <= 0;
		kernel[7] <= 1;
		kernel[8] <= 2;
		scale_bias_g <= EMBOSS_OFFSET_G;
		scale_bias_rb <= EMBOSS_OFFSET_RB;
	end else if(kernel_select == 3) begin
		kernel[0] <= -1;
		kernel[1] <= -1;
		kernel[2] <= -1;
		kernel[3] <= 0;
		kernel[4] <= 0;
		kernel[5] <= 0;
		kernel[6] <= 1;
		kernel[7] <= 1;
		kernel[8] <= 1;
		scale_bias_g <= OO_OFFSET_G;
		scale_bias_rb <= OO_OFFSET_RB;
	end
end

endmodule
