module vga_interface(
	input clk,
	input pclk,
	input reset_n,
	input re,
	//input pixel_ready,
	input [15:0] pixel_in,
	output [18:0] raddress,
	//output reg [10:0] address,
	output pixel_out_ready,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output reg VGA_VS,
	output reg VGA_HS,
	output VGA_SYNC_N,
	output VGA_CLK,
	output VGA_BLANK_N
);

parameter H_ACT =	640;

reg [3:0] state = 4'd0;

vga_controller vc0(
	.pclk(pclk), //25 MHZ
	.reset_n(reset_n),
	.interface_state(state),
	.raddress(raddress),
	.pixel_in(pixel_in),
	.re(re),
	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_CLK(VGA_CLK),
	.VGA_BLANK_N(VGA_BLANK_N),
	.pixel_request(pixel_out_ready)
);

endmodule
