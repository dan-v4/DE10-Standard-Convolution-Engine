module triple_read_ram_dual_clock
#(parameter DATA_WIDTH=16, parameter ADDR_WIDTH=10)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] read_addr1, read_addr2, read_addr3, write_addr,
	input we, read_clock, write_clock,
	output reg [(DATA_WIDTH-1):0] q1, q2, q3
);

dual_port_ram_dual_clock
#(.DATA_WIDTH(16), .ADDR_WIDTH(10))
	d0
(
	.data(data),
	.read_addr(read_addr1), 
	.write_addr(write_addr),
	.we(we), 
	.read_clock(read_clock), 
	.write_clock(write_clock),
	.q(q1)
);

dual_port_ram_dual_clock
#(.DATA_WIDTH(16), .ADDR_WIDTH(10))
	d1
(
	.data(data),
	.read_addr(read_addr2), 
	.write_addr(write_addr),
	.we(we), 
	.read_clock(read_clock), 
	.write_clock(write_clock),
	.q(q2)
);

dual_port_ram_dual_clock
#(.DATA_WIDTH(16), .ADDR_WIDTH(10))
	d2
(
	.data(data),
	.read_addr(read_addr3), 
	.write_addr(write_addr),
	.we(we), 
	.read_clock(read_clock), 
	.write_clock(write_clock),
	.q(q3)
);


	
endmodule