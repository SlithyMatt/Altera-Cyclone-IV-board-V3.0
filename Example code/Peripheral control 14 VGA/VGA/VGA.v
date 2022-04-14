/************************************************
 VGA Demo
*************************************************/
module VGA(
   clock,
   switch,
   disp_RGB,
   hsync,
   vsync
);
input  clock;     // 50MHz
input  [1:0]switch;
output [2:0]disp_RGB;    // RGB pin states
output  hsync;     // horizontal sync (once per scan line)
output  vsync;     // vertical sync (once per frame)

reg [9:0] hcount;     // VGA ticks during scan line
reg [9:0] vcount;     // Scan lines during frame
reg [2:0] data;		 // B-G-R
reg [2:0] h_dat;
reg [2:0] v_dat;

//reg [9:0]   timer;

reg   flag;
wire  hcount_ov;
wire  vcount_ov;
wire  dat_act;
wire  hsync;
wire   vsync;
reg  vga_clk;


parameter hsync_end   = 10'd95, 	// Turn off HSYNC, start front porch
   hdat_begin  = 10'd143, 			// End front porch, start display
   hdat_end  = 10'd783, 			// End display, start back porch
   hpixel_end  = 10'd799, 			// End back porch, rest to new HSYNC
   vsync_end  = 10'd1,           // Turn off VSYNC, continue vertical blanking
   vdat_begin  = 10'd34,         // End vertical blanking, start display
   vdat_end  = 10'd514,          // End display, start vertical blanking
   vline_end  = 10'd524;         // Start VSYNC during vertical blanking

reg [2:0] vram [0:7];
initial
begin
   vram[0] = 3'd0;
	vram[1] = 3'd1;
	vram[2] = 3'd2;
	vram[3] = 3'd3;
	vram[4] = 3'd4;
	vram[5] = 3'd5;
	vram[6] = 3'd6;
	vram[7] = 3'd7;
end

// Divide board clock by 2 to make VGA clock 25MHz
always @(posedge clock)
begin
 vga_clk = ~vga_clk;
end

// Increment hcount (pixel lengths on scan line) every VGA clock, reset after end of line
always @(posedge vga_clk)
begin
 if (hcount_ov)
  hcount <= 10'd0;
 else
  hcount <= hcount + 10'd1;
end

// Flag to indicate end of scan line
assign hcount_ov = (hcount == hpixel_end);

// Increment vcount every scan line, reset after end of frame
always @(posedge vga_clk)
begin
 if (hcount_ov)
 begin
  if (vcount_ov)
   vcount <= 10'd0;
  else
   vcount <= vcount + 10'd1;
 end
end

// flag to indicate start of VSYNC
assign  vcount_ov = (vcount == vline_end);

assign dat_act =    ((hcount >= hdat_begin) && (hcount < hdat_end))
     && ((vcount >= vdat_begin) && (vcount < vdat_end));

// Pull HSYNC high when front porch begins
assign hsync = (hcount > hsync_end);

// VSYNC pulled low only during beginning of frame
assign vsync = (vcount > vsync_end);

// Output RGB signal only when scanning through display area
assign disp_RGB = (dat_act) ?  data : 3'b000;


// select pattern with switches 1 and 2
always @(posedge vga_clk)
begin
 case(switch[1:0])
  2'd0: data <= vram[((hcount - hdat_begin) >> 1) & 7] + vcount; // both switches pressed: diagontal lines
  2'd1: data <= v_dat; 					// switch 2 only: vertical bars
  2'd2: data <= h_dat;    			   // switch 1 only:  horizontal bars  
  2'd3: data <= (v_dat ~^ h_dat);	// no switches: XNOR H/V colors
 endcase
end

// Set colors based on horizontal scan position
always @(posedge vga_clk)
begin
 if(hcount < 223)
  v_dat <= 3'h7;   // white
 else if(hcount < 303)
  v_dat <= 3'h6;   // cyan
 else if(hcount < 383)
  v_dat <= 3'h5;   // magenta
 else if(hcount < 463)
  v_dat <= 3'h4;    // blue
 else if(hcount < 543)
  v_dat <= 3'h3;   // yellow
 else if(hcount < 623)
  v_dat <= 3'h2;   // green
 else if(hcount < 703)
  v_dat <= 3'h1;   // red
 else
  v_dat <= 3'h0;   // black
end

// Set colors based on vertical scan position
always @(posedge vga_clk)
begin
 if(vcount < 94)
  h_dat <= 3'h7;   // white
 else if(vcount < 154)
  h_dat <= 3'h6;   // cyan
 else if(vcount < 214)
  h_dat <= 3'h5;   // magenta
 else if(vcount < 274)
  h_dat <= 3'h4;   // blue
 else if(vcount < 334)
  h_dat <= 3'h3;   // yellow
 else if(vcount < 394)
  h_dat <= 3'h2;   // green
 else if(vcount < 454)
  h_dat <= 3'h1;   // red
 else
  h_dat <= 3'h0;   // black
end

endmodule
