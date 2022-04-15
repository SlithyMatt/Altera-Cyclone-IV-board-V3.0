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

module digits(
	input clk,
	output[3:0] dig,
	output[7:0] seg);
	
	reg[1:0] dig_sel 		= 0;
	
	// decimal digits
	parameter
		seg_zero 	= 8'b11000000,
		seg_one  	= 8'b11111001,
		seg_two		= 8'b10100100,
		seg_three	= 8'b10110000,
		seg_four 	= 8'b10011001,
		seg_five 	= 8'b10010010,
		seg_six		= 8'b10000010,
		seg_seven   = 8'b11111000,
		seg_eight	= 8'b10000000,
		seg_nine    = 8'b10010000,
	// hex digits for debug
		seg_a 		= 8'b10001000,
		seg_b  		= 8'b10000011,
		seg_c			= 8'b11000110,
		seg_d			= 8'b10100001,
		seg_e 		= 8'b10000110,
		seg_f 		= 8'b10001110;
	
	reg[7:0] seg_write;
   reg[3:0] seg_sel;
	
	reg[3:0] dec_counter3 = 0;
	reg[3:0] dec_counter2 = 0;
	reg[3:0] dec_counter1 = 0;
	reg[3:0] dec_counter0 = 0;
	reg[23:0] dig_counter = 0;
	
	always
	begin
		case(seg_sel)
			4'h0: seg_write = seg_zero;
			4'h1: seg_write = seg_one;
			4'h2: seg_write = seg_two;
			4'h3: seg_write = seg_three;
			4'h4: seg_write = seg_four;
			4'h5: seg_write = seg_five;
			4'h6: seg_write = seg_six;
			4'h7: seg_write = seg_seven;
			4'h8: seg_write = seg_eight;
			4'h9: seg_write = seg_nine;
			4'ha: seg_write = seg_a;
			4'hb: seg_write = seg_b;
			4'hc: seg_write = seg_c;
			4'hd: seg_write = seg_d;
			4'he: seg_write = seg_e;
			4'hf: seg_write = seg_f;
		endcase
		
		case(dig_sel)
			0: seg_sel = dec_counter0;
			1: seg_sel = dec_counter1;
			2: seg_sel = dec_counter2;
			3: seg_sel = dec_counter3;
		endcase
	end
	
	assign seg = seg_write;
	
	assign dig[3] = !dig_sel[1] | !dig_sel[0];
	assign dig[2] = !dig_sel[1] | dig_sel[0];
	assign dig[1] = dig_sel[1] | !dig_sel[0];
	assign dig[0] = dig_sel[1] | dig_sel[0];
	
	always @(posedge clk)
	begin
		dig_counter <= dig_counter + 1;
	end
	
	always @(posedge dig_counter[15])
	begin
		dig_sel <= dig_sel + 1;
	end
	
	always @(posedge dig_counter[23])
	begin
		if (dec_counter0 == 9)
		begin
			dec_counter0 <= 0;
			if (dec_counter1 == 9)
			begin
				dec_counter1 <= 0;
				if (dec_counter2 == 9)
				begin
					dec_counter2 <= 0;
					if (dec_counter3 == 9)
						dec_counter3 <= 0;
					else
					   dec_counter3 <= dec_counter3 + 1;
				end
				else
					dec_counter2 <= dec_counter2 + 1;
			end
			else
				dec_counter1 <= dec_counter1 + 1;
		end
		else
			dec_counter0 <= dec_counter0 + 1;
	end
	

	
	

endmodule

	