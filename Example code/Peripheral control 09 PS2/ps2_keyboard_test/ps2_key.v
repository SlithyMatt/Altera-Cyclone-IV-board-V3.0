
/*
 FPGA Project: PS/2 Keyboard typing to RS-232 connected terminal
*/


`timescale 1ns / 1ps

module ps2_key(
	input clk,
	input rst_n,
	input[3:0] switch,
	input ps2k_clk,
	input ps2k_data,
	output rs232_tx,
	output[3:0] dig,
	output[7:0] seg,
	output[3:0] led);

wire[7:0] ps2_byte;	// last byte read from PS/2 device
wire ps2_state;		// state of PS/2 port (low = resetting)

wire bps_start;		
wire clk_bps;		

ps2scan			ps2scan(	.clk(clk),
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
