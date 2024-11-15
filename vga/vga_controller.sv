module vga_controller(
	input pclk, //25 MHZ
	input reset_n,
	input interface_state,
	input [15:0] pixel_in,
	input re,
	output reg [18:0] raddress,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output reg VGA_VS,
	output reg VGA_HS,
	output VGA_SYNC_N,
	output VGA_CLK,
	output VGA_BLANK_N,
	output pixel_request
);
////////////////////////////////////////////////////////////
//	Horizontal	Parameter
parameter H_FRONT	= 16;
parameter H_SYNC	= 96;
parameter H_BACK	= 48;
parameter H_ACT	= 640;
parameter H_ACT_END = H_ACT + H_BACK;

parameter H_TOTAL	= H_FRONT+H_SYNC+H_BACK+H_ACT;
parameter H_BLANK	= H_FRONT+H_SYNC+H_BACK;

////////////////////////////////////////////////////////////
//	Vertical Parameter
parameter V_FRONT	= 11;
parameter V_SYNC	= 2;
parameter V_BACK	= 31;
parameter V_ACT	= 480;
parameter V_ACT_END = V_ACT + V_BACK;


parameter V_TOTAL	= V_FRONT+V_SYNC+V_BACK+V_ACT;
parameter V_BLANK	= V_TOTAL + V_FRONT+V_SYNC+V_BACK;

reg [10:0] h_counter = 0;
reg [10:0] v_counter = 0;

assign raddress = curr_y*H_ACT + curr_x;
assign curr_x	= (h_counter < H_ACT) ? h_counter: 11'h0;
assign curr_y	= (v_counter < V_ACT) ? v_counter:	11'h0;
assign VGA_SYNC_N = 1'b1;
assign VGA_CLK = ~pclk;
assign VGA_R = {pixel_in[15:11],1'b0};
assign VGA_G = pixel_in[10:5];
assign VGA_B = {pixel_in[4:0],1'b0};
assign VGA_BLANK_N =	~((h_counter>=H_ACT)||(v_counter>=V_ACT));
assign pixel_request = h_counter < H_ACT && v_counter < V_ACT;

always @(posedge pclk or negedge reset_n) begin
	if(!reset_n) begin
		h_counter <= 11'd0;
		VGA_HS <= 1'b1;
	end else begin
		if(re) begin
			if(h_counter < H_TOTAL)begin
				h_counter <= h_counter + 11'd1;
			end else begin
				h_counter <= 11'd0;
			end
			if(h_counter==H_ACT + H_FRONT-1)			//	Front porch end
				VGA_HS	<=	1'b0;
			if(h_counter==H_ACT+ H_FRONT+H_SYNC-1)	//	Sync pulse end
				VGA_HS	<=	1'b1;
		end
	end
end

always @(posedge VGA_HS or negedge reset_n) begin
	if(!reset_n) begin
		v_counter <= 11'd0;
		VGA_VS <= 1'b1;
	end else begin
		if(v_counter < V_TOTAL)begin
			v_counter <= v_counter + 11'd1;
		end else begin
			v_counter <= 11'd0;
		end
		if(v_counter==V_ACT + V_FRONT-1)			//	Front porch end
			VGA_VS	<=	1'b0;
		if(v_counter==V_ACT + V_FRONT+V_SYNC-1)	//	Sync pulse end
			VGA_VS	<=	1'b1;
	end
end

endmodule