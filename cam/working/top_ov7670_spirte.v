//------------------------------------------------------------------------------
//   Felipe Machado Sanchez
//   Area de Tecnologia Electronica
//   Universidad Rey Juan Carlos
//   https://github.com/felipe-m
//
//   top module 50 MHz clock generated from PLL 25MHz
//----------------------------------------------------------------------------//

//     - ov7670_rst_n
//          0: camera reset
//          1: normal mode
//     - pwdn: power down mode selection
//          0: normal mode
//          1: power down mode
module tank_bitmap
(
  input [7:0] addr,
  output [7:0] bits
  );

  reg [15:0] bitarray[0:255];
  
  assign bits = (addr[0]) ? bitarray[addr>>1][15:8] : bitarray[addr>>1][7:0];
  
  initial begin/*{w:16,h:16,bpw:16,count:5}*/
    bitarray['h00] = 16'b11110000000;
    bitarray['h01] = 16'b11110000000;
    bitarray['h02] = 16'b1100000000;
    bitarray['h03] = 16'b1100000000;
    bitarray['h04] = 16'b111101101111000;
    bitarray['h05] = 16'b111101101111000;
    bitarray['h06] = 16'b111111111111000;
    bitarray['h07] = 16'b111111111111000;
    bitarray['h08] = 16'b111111111111000;
    bitarray['h09] = 16'b111111111111000;
    bitarray['h0a] = 16'b111111111111000;
    bitarray['h0b] = 16'b111100001111000;
    bitarray['h0c] = 16'b111100001111000;
    bitarray['h0d] = 16'b0;
    bitarray['h0e] = 16'b0;
    bitarray['h0f] = 16'b0;
    
    bitarray['h10] = 16'b111000000000;
    bitarray['h11] = 16'b1111000000000;
    bitarray['h12] = 16'b1111000000000;
    bitarray['h13] = 16'b11000000000;
    bitarray['h14] = 16'b11101110000;
    bitarray['h15] = 16'b1101110000;
    bitarray['h16] = 16'b111101111110000;
    bitarray['h17] = 16'b111101111111000;
    bitarray['h18] = 16'b111111111111000;
    bitarray['h19] = 16'b11111111111000;
    bitarray['h1a] = 16'b11111111111100;
    bitarray['h1b] = 16'b11111111111100;
    bitarray['h1c] = 16'b11111001111100;
    bitarray['h1d] = 16'b1111001110000;
    bitarray['h1e] = 16'b1111000000000;
    bitarray['h1f] = 16'b1100000000000;
    
    bitarray['h20] = 16'b0;
    bitarray['h21] = 16'b0;
    bitarray['h22] = 16'b11000011000000;
    bitarray['h23] = 16'b111000111100000;
    bitarray['h24] = 16'b111101111110000;
    bitarray['h25] = 16'b1110111111000;
    bitarray['h26] = 16'b111111111100;
    bitarray['h27] = 16'b11111111110;
    bitarray['h28] = 16'b11011111111110;
    bitarray['h29] = 16'b111111111111100;
    bitarray['h2a] = 16'b111111111001000;
    bitarray['h2b] = 16'b11111110000000;
    bitarray['h2c] = 16'b1111100000000;
    bitarray['h2d] = 16'b111110000000;
    bitarray['h2e] = 16'b11110000000;
    bitarray['h2f] = 16'b1100000000;

    bitarray['h30] = 16'b0;
    bitarray['h31] = 16'b0;
    bitarray['h32] = 16'b110000000;
    bitarray['h33] = 16'b100001111000000;
    bitarray['h34] = 16'b1110001111110000;
    bitarray['h35] = 16'b1111010111111100;
    bitarray['h36] = 16'b1111111111111111;
    bitarray['h37] = 16'b1111111111111;
    bitarray['h38] = 16'b11111111110;
    bitarray['h39] = 16'b101111111110;
    bitarray['h3a] = 16'b1111111101100;
    bitarray['h3b] = 16'b11111111000000;
    bitarray['h3c] = 16'b1111111100000;
    bitarray['h3d] = 16'b11111110000;
    bitarray['h3e] = 16'b111100000;
    bitarray['h3f] = 16'b1100000;

    bitarray['h40] = 16'b0;
    bitarray['h41] = 16'b0;
    bitarray['h42] = 16'b0;
    bitarray['h43] = 16'b111111111000;
    bitarray['h44] = 16'b111111111000;
    bitarray['h45] = 16'b111111111000;
    bitarray['h46] = 16'b111111111000;
    bitarray['h47] = 16'b1100001111100000;
    bitarray['h48] = 16'b1111111111100000;
    bitarray['h49] = 16'b1111111111100000;
    bitarray['h4a] = 16'b1100001111100000;
    bitarray['h4b] = 16'b111111111000;
    bitarray['h4c] = 16'b111111111000;
    bitarray['h4d] = 16'b111111111000;
    bitarray['h4e] = 16'b111111111000;
    bitarray['h4f] = 16'b0;
  end
endmodule

module sprite_renderer2(
  input clk,
  input vstart,
  input load, 
  input hstart,
  output reg [7:0] rom_addr,
  input [7:0] rom_bits,
  output reg gfx,
  output busy);
  
  assign busy = state != WAIT_FOR_VSTART;

  reg [2:0] state;
  reg [3:0] ycount;
  reg [3:0] xcount;
  
  reg [15:0] outbits;
  
  localparam WAIT_FOR_VSTART = 0;
  localparam WAIT_FOR_LOAD   = 1;
  localparam LOAD1_SETUP     = 2;
  localparam LOAD1_FETCH     = 3;
  localparam LOAD2_SETUP     = 4;
  localparam LOAD2_FETCH     = 5;
  localparam WAIT_FOR_HSTART = 6;
  localparam DRAW            = 7;
  
  always @(posedge clk)
    begin
      case (state)
        WAIT_FOR_VSTART: begin
          ycount <= 0;
          // set a default value (blank) for pixel output
          // note: multiple non-blocking assignments are vendor-specific
	  gfx <= 0;
          if (vstart) state <= WAIT_FOR_LOAD;
        end
        WAIT_FOR_LOAD: begin
          xcount <= 0;
	  gfx <= 0;
          if (load) state <= LOAD1_SETUP;
        end
        LOAD1_SETUP: begin
          rom_addr <= {ycount, 4'b0};
          state <= LOAD1_FETCH;
        end
        LOAD1_FETCH: begin
	  outbits[7:0] <= rom_bits;
          state <= LOAD2_SETUP;
        end
        LOAD2_SETUP: begin
          rom_addr <= {ycount, 4'b1};
          state <= LOAD2_FETCH;
        end
        LOAD2_FETCH: begin
          outbits[15:8] <= rom_bits;
          state <= WAIT_FOR_HSTART;
        end
        WAIT_FOR_HSTART: begin
          if (hstart) state <= DRAW;
        end
        DRAW: begin
          // mirror graphics left/right
          gfx <= outbits[xcount[3:0]];
          xcount <= xcount + 1;
          if (xcount == 15) begin // pre-increment value
            ycount <= ycount + 1;
            if (ycount == 15) // pre-increment value
              state <= WAIT_FOR_VSTART; // done drawing sprite
            else
	      state <= WAIT_FOR_LOAD; // done drawing this scanline
          end
        end
      endcase
    end
endmodule

module top_ov7670
  # (parameter
     // VGA
   
     c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
     c_img_cols    = 80, // 7 bits
     c_img_rows    = 60, //  6 bits
     c_img_pxls    = c_img_cols * c_img_rows,
     c_nb_img_pxls =  13,  //80*60=4800 -> 2^13

     c_nb_buf_red   =  4,  // n bits for red in the buffer (memory)
     c_nb_buf_green =  4,  // n bits for green in the buffer (memory)
     c_nb_buf_blue  =  4,  // n bits for blue in the buffer (memory)
     // word width of the memory (buffer)
     c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue


    )
    (input        rst,         // btn fire 1
     input        clk25mhz,    // 25mhz clk
     input        btn2,          // btn fire 2:
     input        btnd,          // down:stop capture
     input        btnr,          // right: color processing

     output       ov7670_sioc,
     output       ov7670_siod,

     output       ov7670_rst_n,
     output       ov7670_pwdn,
     input        ov7670_vsync,
     input        ov7670_href,
     input        ov7670_pclk,
     output       ov7670_xclk,
     input  [7:0] ov7670_d,

     output [7:0] led,

     output [3:0] vga_red,
     output [3:0] vga_green,
     output [3:0] vga_blue,

     output       vga_hsync,
     output       vga_vsync,
     input  wire btn0,
     output wire oled_csn,
     output wire oled_clk,
     output wire oled_mosi,
     output wire oled_dc,
     output wire oled_resn
    );



  wire clk = clk25mhz;

reg [15:0]   rgb;


  wire [6:0] x;
  wire [5:0] y;

  wire gfx;
  reg [4:0] r= {4{1'b0}};
  reg [4:0] g= {4{1'b0}};
  reg [5:0] b= {5{1'b0}};
  // wire [7:0] color = {r,g, b};

  wire [7:0] tank_sprite_addr;
  wire [7:0] tank_sprite_bits;
  // reg [8:0] color;
  // wire [15:0] color;
  wire next_pixel;
  wire oclk;

// sdd1331_gen_pattern ssd_clk(
//            .clk(clk),
//            .out_hcnt(x),
//            .out_vcnt(y),
//            .rgb(rgb),
//            .rst(rst)
//        );
 tank_bitmap tank_bmp(
    .addr(tank_sprite_addr), 
    .bits(tank_sprite_bits));

  wire vstart = x;
  wire hstart = y;
  wire load;
  assign load = (x>0 && y >0 &&x <16 && y <16 );
  wire busy;

  sprite_renderer2 renderer(
    .clk(clk),
    .vstart(vstart),
    .load(load),
    .hstart(hstart),
    .rom_addr(tank_sprite_addr),
    .rom_bits(tank_sprite_bits),
    .gfx(gfx),
    .busy(busy));


  oled_video
    oled_video_inst
    (
      .clk(clk),
      .reset(~btn0),
      .next_pixel(next_pixel),
      .x(x),
      .y(y),
      .color(color),
      .spi_csn(oled_csn),
      .spi_clk(oled_clk),
      .spi_mosi(oled_mosi),
      .spi_dc(oled_dc),
      .spi_resn(oled_resn)
    );
  
  assign r = load? gfx:5'd128;
  assign g = load? gfx:5'd64;
  assign b = load? gfx:6'd128;
 
  wire [15:0] color = {r,g, b};


  //  wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};

endmodule

