module ov7670_interface(
	input clk, //50MHz fpga clock
	input reset_n,
	inout sda,
	inout scl, 
	input pclk, //pixel clock
	input href,
	input vsync,
	input blank_n,
	input [7:0] data_pins, //d7 - d0 pins
	output reg [15:0] pixel_out, //output pixel
	output camera_reset, //reset pin
	output reg mclk, //25Hz clock from master
	output pixel_valid,
	output pwdn, //pwdn pin
	
	output [9:0] LEDR
	
);


localparam MAX_ROM_INDEX = 78;


assign camera_reset = reset_n ? 1'b1: 1'b0;
assign pwdn = exit_pwdn ? 1'b0 : 1'b1;


wire [7:0] write_address;
wire [3:0] state_check;
reg read_write = 1'b0;
reg [9:0] error_i2c;
wire [7:0] read_data;
assign write_address = 8'h42;

sccb_controller sc0(
	.clk(clk),
	.reset_n(reset_n),
	.start(start_i2c),
	.write_data_in(curr_reg[7:0]),
	.address(write_address), // 7-bit I2C slave address
	.command(curr_reg[15:8]),
	.sda(sda),
	.read_write(read_write),
	.read_data(read_data),
	.scl(scl),
	.busy(busy_i2c),
	.state_check(state_check),
	//.LEDR(LEDR),
	.increment_done(incremented),
   .error(error_i2c) 
);

reg [7:0] curr_command;
wire [15:0] curr_reg;

sccb_rom sr0(
    .clock(clk),
    .address(curr_command),
    .register(curr_reg)
);



reg clock_divider_mclk;
reg increment = 1'b0;

always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin 
		clock_divider_mclk <= 1'b0;
		mclk <= 1'b0;
	end else begin
		clock_divider_mclk <= ~clock_divider_mclk;
		mclk <= clock_divider_mclk;
	end
end

reg [7:0] clock_divider_i2c;
reg sccb_clk = 1'b0;
always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
		clock_divider_i2c <= 1'b0;
		sccb_clk <= 1'b0; 
  end else if (clock_divider_i2c == 8'h7F) begin
		clock_divider_i2c <= 0;
		sccb_clk <= ~sccb_clk; 
  end else
		clock_divider_i2c <= clock_divider_i2c + 1;
end
reg [15:0] pwdn_count;
reg exit_pwdn = 0;
always @(posedge sccb_clk or negedge reset_n) begin
	if(!reset_n) begin
		pwdn_count <= 0;
		exit_pwdn <= 0;
	end else begin
		if(pwdn_count < 100) begin
			pwdn_count <= pwdn_count + 1;
			exit_pwdn <= 0;
		end else 
			exit_pwdn <= 1;
	end
end

reg start_i2c;
reg busy_i2c;
reg init_finished = 1'b0;

reg incremented;
always @(posedge clk or negedge reset_n) begin
	if (!reset_n) begin
		start_i2c <= 1'b0;
		init_finished <= 1'b0;
		curr_command <= 8'd0;
		increment <= 1'b0;
		incremented <= 0;
	end else begin
		if(exit_pwdn) begin
			if(!busy_i2c && !init_finished && (state_check == 4'd0) && (curr_command <= MAX_ROM_INDEX) && !increment)begin
				start_i2c <= 1'b1;
				increment <= 1'b1;
				incremented <= 0;
			end else if(!init_finished && (state_check == 4'd10) && increment) begin
				if(curr_command > MAX_ROM_INDEX) begin
					init_finished <= 1'b1;
					start_i2c <= 1'b0;
					incremented <= 1;
				end else begin
					curr_command <= curr_command + 1'b1;
					start_i2c <= 1'b0;
					init_finished <= 1'b0;
					incremented <= 1;
				end
				increment <= 1'b0;
			end
		end
	end
end


reg byte_select = 1'b0;
reg start_write = 0;
reg frame_complete;
reg [19:0] address_counter = 0;
assign pixel_valid = byte_select;
reg pixel_valid_reg;
always @(posedge pclk or negedge reset_n) begin
	if(!reset_n) begin
		byte_select <= 1'b0;
		start_write <= 0;
		address_counter <= 0;
		frame_complete <= 0;
		pixel_valid_reg <= 0;
	end else begin
		if(href && exit_pwdn && start_write && frame_complete && curr_command > MAX_ROM_INDEX) begin
			if(byte_select) begin
				pixel_out[7:0] <= data_pins;
				byte_select <= 1'b0;
				pixel_valid_reg <= 1;
			end else begin
				pixel_out[15:8] <= data_pins;
				byte_select <= 1'b1;
				pixel_valid_reg <= 0;
			end
		end else if(href && exit_pwdn && start_write && !frame_complete && curr_command > MAX_ROM_INDEX) begin
			byte_select <= 1'b0;
			pixel_valid_reg <= 0;
			if(address_counter <= 614400) begin
				address_counter <= address_counter + 1;
				frame_complete <= 0;
			end else begin
				frame_complete <= 1;
			end
		end
		else begin
			pixel_valid_reg <= 0;
			byte_select <= 1'b0;
			if(vsync && exit_pwdn && curr_command > MAX_ROM_INDEX) begin
				start_write <= 1;
			end
		end
	end
end

endmodule
