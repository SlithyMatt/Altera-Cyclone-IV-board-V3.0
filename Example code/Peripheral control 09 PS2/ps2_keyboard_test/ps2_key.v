
/*FPGAͨ��ps2���ռ������ݣ�Ȼ���ѽ��յ�����ĸA��Z��ֵת����Ӧ��ASII�룬ͨ�����ڷ��͵�PC���ϡ�
ʵ��ʱ����Ҫ�Ӽ��̣���Ҫ�õ������֣����س��������ڼ����ϰ���һ����������A������PC���������Ͽɿ���A
*/


`timescale 1ns / 1ps

module ps2_key(
	input clk,
	input rst_n,
	input[3:0] switch,
	inout ps2k_clk,
	inout ps2k_data,
	output rs232_tx,
	output[3:0] dig,
	output[7:0] seg,
	output[3:0] led);

wire[7:0] ps2_byte;	// 1byte��ֵ
wire ps2_state;		//����״̬��־λ

wire bps_start;		//���յ����ݺ󣬲�����ʱ�������ź���λ
wire clk_bps;		// clk_bps�ĸߵ�ƽΪ���ջ��߷�������λ���м������� 

ps2scan			ps2scan(	.clk(clk),			  	//����ɨ��ģ��
								.rst_n(rst_n),
								.switch(switch),
								.ps2k_clk(ps2k_clk),
								.ps2k_data(ps2k_data),
								.ps2_byte(ps2_byte),
								.ps2_state(ps2_state),
								.led(led)
								);

speed_select	speed_select(	.clk(clk),
										.rst_n(rst_n),
										.bps_start(bps_start),
										.clk_bps(clk_bps)
										);

my_uart_tx		my_uart_tx(		.clk(clk),
										.rst_n(rst_n),
										.clk_bps(clk_bps),
										.rx_data(ps2_byte),
										.rx_int(ps2_state),
										.rs232_tx(rs232_tx),
										.bps_start(bps_start)
										);
										
digits			digits(	.clk(clk),
								.state(ps2_state),
								.code(ps2_byte),
								.dig(dig),
								.seg(seg)
								);

endmodule
