module convolution(
	input clk,
	//input reset_n,
	//input with_norm,
	//input [4:0] divisor,
	input valid_buffer,
	input [15:0] pixel_buffer [8:0],
	input signed [5:0] kernel [8:0],
	input signed [9:0] scale_bias_g,
	input signed [9:0] scale_bias_rb,
	output valid_out,
	output [47:0] out_pixel
	//output [9:0] LEDR
	
);

//assign LEDR = out_pixel[9:0];

reg signed [5:0] pixel_r [8:0];
reg signed [6:0] pixel_g [8:0];
reg signed [5:0] pixel_b [8:0];

reg signed [5:0] kernel_reg [8:0];


reg signed [12:0] product_r [8:0];
reg signed [12:0] product_g [8:0];
reg signed [12:0] product_b [8:0];

reg signed [15:0] accumulator_r = 0;
reg signed [15:0] accumulator_g = 0;
reg signed [15:0] accumulator_b = 0;


reg valid_in;
reg valid_prod;
reg valid_sum;

int i;

always @(posedge clk) begin

	if(valid_buffer) begin
		for(i = 0; i < 9; i++) begin
			pixel_r[i] <= {1'b0,pixel_buffer[i][15:11]};
			pixel_g[i] <= {1'b0,pixel_buffer[i][10:5]};
			pixel_b[i] <= {1'b0,pixel_buffer[i][4:0]};
			kernel_reg[i] <= kernel[i];
		end
			
		valid_in <= 1;
	end else begin
		valid_in <= 0;
	end
	
end


always @(posedge clk) begin
	
	if(valid_in) begin
		for(i = 0; i < 9; i++) begin
			product_r[i] <= kernel_reg[i]*pixel_r[i];
			product_g[i] <= kernel_reg[i]*pixel_g[i];
			product_b[i] <= kernel_reg[i]*pixel_b[i];
		end
		valid_prod <= 1;
	end else begin
		valid_prod <= 0;
	end
	
	
end

always @(posedge clk) begin
	if(valid_prod) begin
		accumulator_r <= product_r[0] + product_r[1] + product_r[2] + product_r[3] + product_r[4] + product_r[5] + product_r[6] + product_r[7] + product_r[8] + scale_bias_rb;
		accumulator_g <= product_g[0] + product_g[1] + product_g[2] + product_g[3] + product_g[4] + product_g[5] + product_g[6] + product_g[7] + product_g[8] + scale_bias_g;
		accumulator_b <= product_b[0] + product_b[1] + product_b[2] + product_b[3] + product_b[4] + product_b[5] + product_b[6] + product_b[7] + product_b[8] + scale_bias_rb;
		valid_sum <= 1;
	end else begin
		valid_sum <= 0;
	end
end

always @(posedge clk) begin
	if(valid_sum) begin
		out_pixel <= {accumulator_r, accumulator_g, accumulator_b};
		valid_out <= 1;
	end else begin
		valid_out <= 0;
	end
end



		



endmodule