/***************************************************
 Digit Tube Demo for "OMDAZZ" Cyclone IV Dev Board
 by Matt Heffernan
 
 Segment bit layout:
 
 5 000000000000 1
 55 0000000000 11
 555          111
 555          111
 555          111
 55 6666666666 11
   666666666666
 44 6666666666 22
 444          222
 444          222
 444          222
 44 3333333333 22  777
 4 333333333333 2  777
 
***************************************************/

module digits(clk,dig,seg);
	input clk;
	output[3:0] dig;
	output[7:0] seg;
	
	reg[1:0] digsel 		= 0;
	reg[7:0] seg_zero 	= 8'b11000000;
	reg[7:0] seg_one  	= 8'b11111001;
	reg[7:0] seg_two		= 8'b10100100;
	reg[7:0] seg_three	= 8'b10110000;
	
	reg[15:0] dec_counter = 0;
	reg[11:0] dig_clk = 0;
	
	assign dig[3] = !digsel[1] | !digsel[0];
	assign dig[2] = !digsel[1] | digsel[0];
	assign dig[1] = digsel[1] | !digsel[0];
	assign dig[0] = digsel[1] | digsel[0];
	
	assign seg = dig[0]? (dig[1]? (dig[2]? seg_three : seg_two) : seg_one) : seg_zero;
	
	always @(posedge clk)
	begin
		dig_clk <= dig_clk + 1;
	end
	
	always @(posedge dig_clk[11])
	begin
		digsel <= digsel + 1;
	end

endmodule

	