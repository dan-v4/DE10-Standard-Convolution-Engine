module sccb_controller(
	input clk,
	input reset_n,
	input start,
	input wire [7:0] write_data_in,
	input wire [7:0] address, // 7-bit I2C slave address
	input wire [7:0] command,
	input increment_done,
	input read_write,
	inout sda,
	
	output scl,
	output busy,
	output [3:0] state_check,
	output reg [7:0] read_data,
	output [9:0] LEDR,
	
   output [9:0] error 
	
);

localparam IDLE = 0, START = 1, ADDRESS = 2, ACK1 = 3, COMMAND = 4, ACK2 = 5, DATA= 6, ACK3 = 7, STOP_FORCE_LOW = 8, STOP_CONDITION = 9, WAIT_FOR_INCREMENT = 10, ERROR = 11;
localparam MAX_INDEX = 10'd8;
localparam MAX_COUNT_DELAY = 1000;
reg sccb_clk = 1;
reg [7:0] clock_divider;
wire scl_high_mid;
wire scl_low_mid;

reg [3:0] curr_state;
reg [3:0] next_state;

reg sda_out_curr;
reg sda_out_next;

reg [15:0] bit_index_curr = MAX_COUNT_DELAY;
reg [15:0] bit_index_next;

reg busy_curr = 0;
reg busy_next;

reg [9:0] error_curr;
reg [9:0] error_next;

wire [8:0] write_data_in_buffer;
wire [8:0] address_buffer;
wire [8:0] command_buffer;
reg [7:0] read_data_curr;
reg [7:0] read_data_next;
reg [9:0] led_curr;
reg [9:0] led_next;
wire sda_copy;

assign scl_high_mid = (clock_divider == 8'd127 && sccb_clk);
assign scl_low_mid = (clock_divider == 8'd127 && ~sccb_clk);
//assign read_data = read_data_curr;

assign address_buffer = {address, 1'bx};
assign command_buffer = {command, 1'bx};
assign write_data_in_buffer = {write_data_in, 1'bx};

assign sda = (curr_state == IDLE) ?  1'b1:sda_out_curr;
assign sda_copy = sda;
assign scl = sccb_clk;
assign busy = busy_curr;
assign error = error_curr;
assign state_check = curr_state;

assign LEDR = led_curr;
// i2c clock
always @(posedge clk) begin
	if(!reset_n) begin
		clock_divider <= 8'd0;
		sccb_clk <= 1;
	end else begin
		
		if(curr_state == WAIT_FOR_INCREMENT) begin
			sccb_clk <= 1;
			if(clock_divider == 8'd255) begin
				clock_divider <= 8'd0;
			end else begin
				clock_divider <= clock_divider + 8'd1;
			end
		end else if(curr_state == IDLE || curr_state == START) begin
			sccb_clk <= 1;
			if(clock_divider == 8'd255) begin
				clock_divider <= 8'd0;
			end else begin
				clock_divider <= clock_divider + 8'd1;
			end
		end else begin
			if(clock_divider == 8'd255) begin
				sccb_clk <= ~sccb_clk;
				clock_divider <= 8'd0;
			end else begin
				clock_divider <= clock_divider + 8'd1;
			end
		end
	end
end

always @(posedge clk) begin
	if(!reset_n) begin
		curr_state <= IDLE;
		sda_out_curr <= 1;
		bit_index_curr <= MAX_COUNT_DELAY;
		busy_curr <= 0;
		error_curr <= 4'd0;
		led_curr <= 10'd0;
		read_data_curr <= 9'd0;
	end else begin
		curr_state <= next_state;
		sda_out_curr <= sda_out_next;
		bit_index_curr <= bit_index_next;
		busy_curr <= busy_next;
		error_curr <= error_next;
		led_curr <= led_next;
		read_data_curr <= read_data_next;
	end
end

always @(*) begin
	next_state = curr_state;
	sda_out_next = sda_out_curr;
	bit_index_next = bit_index_curr;
	busy_next = busy_curr;
	error_next = error_curr;
	led_next = led_curr;
	read_data_next = read_data_curr;
	case(curr_state)
		IDLE: begin
				//sda_out_next = 1;
				if(scl_high_mid) begin
					if(bit_index_curr == 0) begin
						if(start) begin
							bit_index_next = MAX_INDEX;
							//sda_out_next = 1;
							next_state=START;
							busy_next = 1;
						end
					end else begin
						busy_next = 0;
						bit_index_next = bit_index_curr -10'd1;
					end
				end
			end
			START: begin
				if(scl_high_mid) begin
					sda_out_next = 0;
					next_state = ADDRESS;
				end
			end
			ADDRESS: begin
				if(scl_low_mid) begin
					sda_out_next = address_buffer[bit_index_curr];
					if(bit_index_curr == 0) begin
						bit_index_next = MAX_INDEX;
						next_state = COMMAND;
					end else begin
						
						bit_index_next = bit_index_curr -10'd1;
					end
				end
			end
			COMMAND: begin
				if(scl_low_mid) begin
					sda_out_next = command_buffer[bit_index_curr];
					if(bit_index_curr == 0) begin
						bit_index_next = MAX_INDEX;
						next_state = DATA;
					end else begin
						
						bit_index_next = bit_index_curr -10'd1;
					end
				end
			end
			DATA: begin
				if(scl_low_mid) begin
					sda_out_next = write_data_in_buffer[bit_index_curr];
					if(bit_index_curr == 0) begin
						bit_index_next = MAX_INDEX;
						next_state = STOP_FORCE_LOW;
					end else begin
						
						bit_index_next = bit_index_curr -10'd1;
					end
				end

			end
			STOP_FORCE_LOW: begin
				if(scl_low_mid) begin
					sda_out_next = 0;
					next_state = STOP_CONDITION;
					
				end
			end
			STOP_CONDITION: begin
				if(scl_high_mid) begin
					sda_out_next = 1;
					next_state = WAIT_FOR_INCREMENT;
					busy_next = 0;
				end
			end
			WAIT_FOR_INCREMENT: begin
				if(scl_high_mid) begin
					if(bit_index_curr == 0) begin
						if(increment_done) begin
							bit_index_next = MAX_COUNT_DELAY;
							next_state = IDLE;
						end
					end else begin
						
						bit_index_next = bit_index_curr -10'd1;
					end
				end
			end
			ERROR: begin
				busy_next = 1;
			end
			default: begin
				next_state = IDLE;
			end
	endcase

end



endmodule