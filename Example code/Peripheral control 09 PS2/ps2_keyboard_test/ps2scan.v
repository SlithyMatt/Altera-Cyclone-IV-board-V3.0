`timescale 1ns / 1ps

module ps2scan(
	input clk,
	input rst_n,
	input[3:0] switch,
	inout ps2k_clk,
	inout ps2k_data,
	output[7:0] ps2_byte,
	output ps2_state,
	output[3:0] led);

//------------------------------------------
reg start_send = 0;
reg sending = 0;
reg waiting_ack = 0;
reg send_data = 0;
reg[7:0] send_data_byte;
reg[13:0] send_counter;
reg got_ack = 0;
reg passed = 0;
reg failed = 0;

assign ps2k_clk = start_send ? 1'b0 : 1'bZ;
assign ps2k_data = sending ? send_data : 1'bZ;

assign led[0] = ps2k_clk;
assign led[1] = stop_good;
assign led[2] = parity_good;
assign led[3] = start_good;

always @ (posedge clk or negedge rst_n or posedge send_led) begin
	if(!rst_n) begin
			send_data_byte <= 8'hed;
			send_counter <= 14'b0;
	end
	else if(send_led) begin
		if (send_counter[13]) begin
			send_counter <= 14'b0;
			send_data_byte <= 8'h02;
		end
	end
	else if(start_send) begin
		send_counter <= send_counter + 1;
	end
end

always @(posedge send_counter[13] or negedge rst_n or posedge send_led) begin
	if(!rst_n) begin
		start_send <= 1'b1;
	end
	else if (send_led) begin
		start_send <= 1'b1;
	end
	else begin
		start_send <= 1'b0;
	end
end

//------------------------------------------
reg[7:0] ps2_byte_r;		//PC��������PS2��һ���ֽ����ݴ洢��
reg[7:0] temp_data;			//��ǰ�������ݼĴ���
reg[3:0] num;				//�����Ĵ���
wire parity_check;
reg parity_good;
reg start_good;
reg stop_good;
reg send_led;

assign parity_check = ~^temp_data;

always @ (negedge ps2k_clk or negedge rst_n) begin
	if(!rst_n) begin
			num <= 4'd0;
			temp_data <= 8'd0;
			sending <= 1'b1;						
			waiting_ack <= 1'b0;
			parity_good <= 1'b0;
			start_good <= 1'b0;
			stop_good <= 1'b0;
			send_led <= 0;
		end
		else if (!sending && !waiting_ack) begin
				case (num)
					4'd0:	begin								
								start_good <= ~ps2k_data;
								if (~ps2k_data) begin
									num <= num+1'b1;
								end
							end
					4'd1:	begin
								num <= num+1'b1;
								temp_data[0] <= ps2k_data;	//bit0
							end
					4'd2:	begin
								num <= num+1'b1;
								temp_data[1] <= ps2k_data;	//bit1
							end
					4'd3:	begin
								num <= num+1'b1;
								temp_data[2] <= ps2k_data;	//bit2
							end
					4'd4:	begin
								num <= num+1'b1;
								temp_data[3] <= ps2k_data;	//bit3
							end
					4'd5:	begin
								num <= num+1'b1;
								temp_data[4] <= ps2k_data;	//bit4
							end
					4'd6:	begin
								num <= num+1'b1;
								temp_data[5] <= ps2k_data;	//bit5
							end
					4'd7:	begin
								num <= num+1'b1;
								temp_data[6] <= ps2k_data;	//bit6
							end
					4'd8:	begin
								num <= num+1'b1;
								temp_data[7] <= ps2k_data;	//bit7
							end
					4'd9:	begin
								num <= num+1'b1;
								parity_good <= parity_check == ps2k_data; 
							end
					4'd10: begin
								// stop
								stop_good <= ps2k_data;
								if (ps2k_data) begin
									num <= 4'd0;
								end
							end
					default: ;
					endcase
				end
		
		else if (!start_send) begin
				case (num)
					4'd0:	begin
								send_led <= 0;
								num <= num+1'b1;
								send_data <= 1'b0;	// Start
							end
					4'd1:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[0];	//bit0
							end
					4'd2:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[1];	//bit1
							end
					4'd3:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[2];	//bit2
							end
					4'd4:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[3];	//bit3
							end
					4'd5:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[4];	//bit4
							end
					4'd6:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[5];	//bit5
							end
					4'd7:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[6];	//bit6
							end
					4'd8:	begin
								num <= num+1'b1;
								send_data <= send_data_byte[7];	//bit7
							end
					4'd9:	begin
								num <= num+1'b1;
								send_data <= ~^send_data_byte; 	// parity
							end
					4'd10: begin
								num <= num+1'b1;
								sending <= 1'b0; 	// stop - data pin go back to Z
								waiting_ack <= 1'b1;
							end
					4'd11: begin
								num <= 1'b0;
								waiting_ack <= 1'b0;
								if (send_data_byte == 8'hed) begin
									send_led <= 1; 
								end
							end
					default: ;
					endcase
			end
end

reg key_f0;		//�ɼ���־λ����1��ʾ���յ�����8'hf0���ٽ��յ���һ�����ݺ�����
reg ps2_state_r;	//���̵�ǰ״̬��ps2_state_r=1��ʾ�м������� 

always @ (posedge newcode or negedge rst_n) begin	//�������ݵ���Ӧ����������ֻ��1byte�ļ�ֵ���д���
	if(!rst_n) begin
			key_f0 <= 1'b0;
			ps2_state_r <= 1'b0;
		end
	else begin
			//if(temp_data == 8'hf0) key_f0 <= 1'b1;
			//else begin
			//		if(!key_f0) begin	//˵���м�����
							ps2_state_r <= 1'b1;
							ps2_byte_r <= temp_data;	//���浱ǰ��ֵ
						end
			//		else begin
			//				ps2_state_r <= 1'b0;
			//				key_f0 <= 1'b0;
			//			end
			//	end
		//end
end

reg[7:0] ps2_asci;	//�������ݵ���ӦASCII��
wire newcode;

assign newcode = ~|num;
reg[7:0] code_last;
reg[7:0] code_1;
reg[7:0] code_2;
reg[7:0] code_3;

reg[7:0] aa_count;

always @ (posedge newcode or negedge rst_n) begin
	if(!rst_n) begin
			got_ack <= 1'b0;
			passed <= 1'b0;
			failed <= 1'b0;
			code_last <= 8'h42;
			code_1 <= 8'h00;
			code_2 <= 8'h00;
			code_3 <= 8'h00;
			ps2_asci <= 0;
			aa_count <= 0;
		end
	else begin
		if (code_3 == 8'h00) begin
			code_3 <= code_2;
			code_2 <= code_1;
			code_1 <= code_last;
			code_last <= temp_data;
		end
		case (ps2_byte_r)
			8'h15: ps2_asci <= 8'h51;	//Q
			8'h1d: ps2_asci <= 8'h57;	//W
			8'h24: ps2_asci <= 8'h45;	//E
			8'h2d: ps2_asci <= 8'h52;	//R
			8'h2c: ps2_asci <= 8'h54;	//T
			8'h35: ps2_asci <= 8'h59;	//Y
			8'h3c: ps2_asci <= 8'h55;	//U
			8'h43: ps2_asci <= 8'h49;	//I
			8'h44: ps2_asci <= 8'h4f;	//O
			8'h4d: ps2_asci <= 8'h50;	//P				  	
			8'h1c: ps2_asci <= 8'h41;	//A
			8'h1b: ps2_asci <= 8'h53;	//S
			8'h23: ps2_asci <= 8'h44;	//D
			8'h2b: ps2_asci <= 8'h46;	//F
			8'h34: ps2_asci <= 8'h47;	//G
			8'h33: ps2_asci <= 8'h48;	//H
			8'h3b: ps2_asci <= 8'h4a;	//J
			8'h42: ps2_asci <= 8'h4b;	//K
			8'h4b: ps2_asci <= 8'h4c;	//L
			8'h1a: ps2_asci <= 8'h5a;	//Z
			8'h22: ps2_asci <= 8'h58;	//X
			8'h21: ps2_asci <= 8'h43;	//C
			8'h2a: ps2_asci <= 8'h56;	//V
			8'h32: ps2_asci <= 8'h42;	//B
			8'h31: ps2_asci <= 8'h4e;	//N
			8'h3a: ps2_asci <= 8'h4d;	//M
			8'haa: aa_count <= aa_count + 1;
			default: ;//ps2_asci <= ps2_byte_r; // debug
			endcase
		end
end

assign ps2_byte = ~switch[0]? code_last : (~switch[1]? code_1 : (~switch[2]? code_2 : (~switch[3]? code_3 : ps2_asci))); 
assign ps2_state = ps2_state_r;

endmodule
