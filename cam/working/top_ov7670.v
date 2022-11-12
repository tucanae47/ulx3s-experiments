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
// module tank_bitmap
// (
//   input [7:0] addr;
//   output [7:0] bits;
//   );

//   reg [15:0] bitarray[0:255];
  
//   assign bits = (addr[0]) ? bitarray[addr>>1][15:8] : bitarray[addr>>1][7:0];
  
//   initial begin/*{w:16,h:16,bpw:16,count:5}*/
//     bitarray['h00] = 16'b11110000000;
//     bitarray['h01] = 16'b11110000000;
//     bitarray['h02] = 16'b1100000000;
//     bitarray['h03] = 16'b1100000000;
//     bitarray['h04] = 16'b111101101111000;
//     bitarray['h05] = 16'b111101101111000;
//     bitarray['h06] = 16'b111111111111000;
//     bitarray['h07] = 16'b111111111111000;
//     bitarray['h08] = 16'b111111111111000;
//     bitarray['h09] = 16'b111111111111000;
//     bitarray['h0a] = 16'b111111111111000;
//     bitarray['h0b] = 16'b111100001111000;
//     bitarray['h0c] = 16'b111100001111000;
//     bitarray['h0d] = 16'b0;
//     bitarray['h0e] = 16'b0;
//     bitarray['h0f] = 16'b0;
    
//     bitarray['h10] = 16'b111000000000;
//     bitarray['h11] = 16'b1111000000000;
//     bitarray['h12] = 16'b1111000000000;
//     bitarray['h13] = 16'b11000000000;
//     bitarray['h14] = 16'b11101110000;
//     bitarray['h15] = 16'b1101110000;
//     bitarray['h16] = 16'b111101111110000;
//     bitarray['h17] = 16'b111101111111000;
//     bitarray['h18] = 16'b111111111111000;
//     bitarray['h19] = 16'b11111111111000;
//     bitarray['h1a] = 16'b11111111111100;
//     bitarray['h1b] = 16'b11111111111100;
//     bitarray['h1c] = 16'b11111001111100;
//     bitarray['h1d] = 16'b1111001110000;
//     bitarray['h1e] = 16'b1111000000000;
//     bitarray['h1f] = 16'b1100000000000;
    
//     bitarray['h20] = 16'b0;
//     bitarray['h21] = 16'b0;
//     bitarray['h22] = 16'b11000011000000;
//     bitarray['h23] = 16'b111000111100000;
//     bitarray['h24] = 16'b111101111110000;
//     bitarray['h25] = 16'b1110111111000;
//     bitarray['h26] = 16'b111111111100;
//     bitarray['h27] = 16'b11111111110;
//     bitarray['h28] = 16'b11011111111110;
//     bitarray['h29] = 16'b111111111111100;
//     bitarray['h2a] = 16'b111111111001000;
//     bitarray['h2b] = 16'b11111110000000;
//     bitarray['h2c] = 16'b1111100000000;
//     bitarray['h2d] = 16'b111110000000;
//     bitarray['h2e] = 16'b11110000000;
//     bitarray['h2f] = 16'b1100000000;

//     bitarray['h30] = 16'b0;
//     bitarray['h31] = 16'b0;
//     bitarray['h32] = 16'b110000000;
//     bitarray['h33] = 16'b100001111000000;
//     bitarray['h34] = 16'b1110001111110000;
//     bitarray['h35] = 16'b1111010111111100;
//     bitarray['h36] = 16'b1111111111111111;
//     bitarray['h37] = 16'b1111111111111;
//     bitarray['h38] = 16'b11111111110;
//     bitarray['h39] = 16'b101111111110;
//     bitarray['h3a] = 16'b1111111101100;
//     bitarray['h3b] = 16'b11111111000000;
//     bitarray['h3c] = 16'b1111111100000;
//     bitarray['h3d] = 16'b11111110000;
//     bitarray['h3e] = 16'b111100000;
//     bitarray['h3f] = 16'b1100000;

//     bitarray['h40] = 16'b0;
//     bitarray['h41] = 16'b0;
//     bitarray['h42] = 16'b0;
//     bitarray['h43] = 16'b111111111000;
//     bitarray['h44] = 16'b111111111000;
//     bitarray['h45] = 16'b111111111000;
//     bitarray['h46] = 16'b111111111000;
//     bitarray['h47] = 16'b1100001111100000;
//     bitarray['h48] = 16'b1111111111100000;
//     bitarray['h49] = 16'b1111111111100000;
//     bitarray['h4a] = 16'b1100001111100000;
//     bitarray['h4b] = 16'b111111111000;
//     bitarray['h4c] = 16'b111111111000;
//     bitarray['h4d] = 16'b111111111000;
//     bitarray['h4e] = 16'b111111111000;
//     bitarray['h4f] = 16'b0;
//   end
// endmodule

// module sprite_renderer2(
//   input clk,
//   input vstart,
//   input load, 
//   input hstart,
//   output reg [7:0] rom_addr,
//   input [7:0] rom_bits,
//   output reg gfx,
//   output busy);
  
//   assign busy = state != WAIT_FOR_VSTART;

//   reg [2:0] state;
//   reg [3:0] ycount;
//   reg [3:0] xcount;
  
//   reg [15:0] outbits;
  
//   localparam WAIT_FOR_VSTART = 0;
//   localparam WAIT_FOR_LOAD   = 1;
//   localparam LOAD1_SETUP     = 2;
//   localparam LOAD1_FETCH     = 3;
//   localparam LOAD2_SETUP     = 4;
//   localparam LOAD2_FETCH     = 5;
//   localparam WAIT_FOR_HSTART = 6;
//   localparam DRAW            = 7;
  
//   always @(posedge clk)
//     begin
//       case (state)
//         WAIT_FOR_VSTART: begin
//           ycount <= 0;
//           // set a default value (blank) for pixel output
//           // note: multiple non-blocking assignments are vendor-specific
// 	  gfx <= 0;
//           if (vstart) state <= WAIT_FOR_LOAD;
//         end
//         WAIT_FOR_LOAD: begin
//           xcount <= 0;
// 	  gfx <= 0;
//           if (load) state <= LOAD1_SETUP;
//         end
//         LOAD1_SETUP: begin
//           rom_addr <= {ycount, 4'b0};
//           state <= LOAD1_FETCH;
//         end
//         LOAD1_FETCH: begin
// 	  outbits[7:0] <= rom_bits;
//           state <= LOAD2_SETUP;
//         end
//         LOAD2_SETUP: begin
//           rom_addr <= {ycount, 4'b1};
//           state <= LOAD2_FETCH;
//         end
//         LOAD2_FETCH: begin
//           outbits[15:8] <= rom_bits;
//           state <= WAIT_FOR_HSTART;
//         end
//         WAIT_FOR_HSTART: begin
//           if (hstart) state <= DRAW;
//         end
//         DRAW: begin
//           // mirror graphics left/right
//           gfx <= outbits[xcount[3:0]];
//           xcount <= xcount + 1;
//           if (xcount == 15) begin // pre-increment value
//             ycount <= ycount + 1;
//             if (ycount == 15) // pre-increment value
//               state <= WAIT_FOR_VSTART; // done drawing sprite
//             else
// 	      state <= WAIT_FOR_LOAD; // done drawing this scanline
//           end
//         end
//       endcase
//     end
// endmodule

// module top_ov7670
//   # (parameter
//      // VGA
   
//      c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
//      c_img_cols    = 80, // 7 bits
//      c_img_rows    = 60, //  6 bits
//      c_img_pxls    = c_img_cols * c_img_rows,
//      c_nb_img_pxls =  13,  //80*60=4800 -> 2^13

//      c_nb_buf_red   =  4,  // n bits for red in the buffer (memory)
//      c_nb_buf_green =  4,  // n bits for green in the buffer (memory)
//      c_nb_buf_blue  =  4,  // n bits for blue in the buffer (memory)
//      // word width of the memory (buffer)
//      c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue


//     )
//     (input        rst,         // btn fire 1
//      input        clk25mhz,    // 25mhz clk
//      input        btn2,          // btn fire 2:
//      input        btnd,          // down:stop capture
//      input        btnr,          // right: color processing

//      output       ov7670_sioc,
//      output       ov7670_siod,

//      output       ov7670_rst_n,
//      output       ov7670_pwdn,
//      input        ov7670_vsync,
//      input        ov7670_href,
//      input        ov7670_pclk,
//      output       ov7670_xclk,
//      input  [7:0] ov7670_d,

//      output [7:0] led,

//      output [3:0] vga_red,
//      output [3:0] vga_green,
//      output [3:0] vga_blue,

//      output       vga_hsync,
//      output       vga_vsync,
//      input  wire btn0,
//      output wire oled_csn,
//      output wire oled_clk,
//      output wire oled_mosi,
//      output wire oled_dc,
//      output wire oled_resn
//     );


//   reg  winc, wclk, oclk;
//   // rclk;
//   reg  [DSIZE-1:0] wdata;
//   reg              wrst_n;
//   wire             wfull;
//   wire             awfull;
//   reg              rrst_n;
//   reg              rinc;
//   wire [DSIZE-1:0] rdata;
//   wire             rempty;
//   wire             arempty;

//   wire          vga_visible;
//   wire          vga_new_pxl;
//   wire [10-1:0] vga_col;
//   wire [10-1:0] vga_row;

//   wire          vga_hsync_wr; // intermediate signal, not registered (wire)
//   wire          vga_vsync_wr; // intermediate signal, not registered (wire

//   wire [c_nb_img_pxls-1:0] display_img_addr;
//   wire [c_nb_buf-1:0]      display_img_pxl;

//   wire [c_nb_img_pxls-1:0] frame_addr;
//   wire [c_nb_buf-1:0]    frame_pixel;

//   wire [c_nb_img_pxls-1:0] capture_addr;
//   wire [c_nb_buf-1:0]    capture_data;

//   wire          capture_we;
//   wire          capture_wen; // enable the write enable: stop capture

//   wire [c_nb_img_pxls-1:0] orig_img_addr;
//   wire [c_nb_buf-1:0]      orig_img_pxl;
//   wire          proc_we;

//   wire          resend;
//   wire          config_finished;

//   wire          sdat_on;
//   wire          sdat_out;  //  not making it INOUT, just out, but 3-state

//   wire          clk50mhz;

//   wire          rgbmode = 1'b1;
//   wire          testmode;
//   wire          locked_wire;
//   parameter     swap_r_b = 1'b1; // red and blue are swapped

//   wire clk = clk25mhz;
//   // 50 MHz clock
//   pll i_pll
//       (
//         .clkin(clk25mhz),
//         .clkout0(clk50mhz),
//         .locked(locked_wire)
//       );

// reg [7:0]    x;
// reg [7:0]    y;
// reg [15:0]   rgb;

//   parameter C_color_bits = 8; // 8 or 16

//   wire [6:0] x;
//   wire [5:0] y;

//   reg [3:0] r= {4{1'b0}};
//   reg [3:0] g= {4{1'b0}};
//   reg [2:0] b= {3{1'b0}};
//   wire [7:0] color = {r,g, b};

//   // reg [8:0] color;
//   // wire [15:0] color;
//   wire next_pixel;
//   wire oclk;

// sdd1331_gen_pattern ssd_clk(
//            .clk(clk),
//            .out_hcnt(x),
//            .out_vcnt(y),
//            .rgb(rgb),
//            .rst(rst)
//        );
//  tank_bitmap tank_bmp(
//     .addr(tank_sprite_addr), 
//     .bits(tank_sprite_bits));

//   wire vstart = x;
//   wire hstart = y;
//   wire load;
//   assign load = (x>0 && y >0 &&x <16 && y <16 );
//   wire busy;

//   sprite_renderer2 renderer(
//     .clk(clk),
//     .vstart(vstart),
//     .load(load),
//     .hstart(hstart),
//     .rom_addr(sprite_addr),
//     .rom_bits(sprite_bits),
//     .gfx(gfx),
//     .busy(busy));


//   oled_video
//     #(
//       .c_init_file("ssd1351_oinit_xflip_16bit.mem"),
//       .c_x_size(80),
//       .c_y_size(60),
//       .c_color_bits(C_color_bits)
//     )
//     oled_video_inst
//     (
//       .clk(oclk),
//       .reset(~btn0),
//       .next_pixel(next_pixel),
//       .x(x),
//       .y(y),
//       .color(color),
//       .spi_csn(oled_csn),
//       .spi_clk(oled_clk),
//       .spi_mosi(oled_mosi),
//       .spi_dc(oled_dc),
//       .spi_resn(oled_resn)
//     );
  
//   wire r = load?  tank1_gfx:4'b0;
//   wire g = load? tank1_gfx:4'b0;
//   wire b = load? (tank1_gfx:4'b0;
 



// endmodule

module top_ov7670
  # (parameter
     // VGA
     //c_img_cols    = 640, // 10 bits
     //c_img_rows    = 480, //  9 bits
     //c_img_pxls    = c_img_cols * c_img_rows,
     //c_nb_line_pxls = 10, // log2i(c_img_cols-1) + 1;
     // c_nb_img_pxls = log2i(c_img_pxls-1) + 1
     //c_nb_img_pxls =  19,  //640*480=307,200 -> 2^19=524,288
     // QVGA
     // c_img_cols    = 320, // 9 bits
     // c_img_rows    = 240, // 8 bits
     // c_img_pxls    = c_img_cols * c_img_rows,
     // c_nb_line_pxls = 9, // log2i(c_img_cols-1) + 1;
     // c_nb_img_pxls =  17,  //320*240=76,800 -> 2^17
    //  c_img_cols    = 160, // 8 bits
    //  c_img_rows    = 120, //  7 bits
    //  c_nb_line_pxls = 8, // log2i(c_img_cols-1) + 1;
    //  c_img_pxls    = c_img_cols * c_img_rows,
    //  c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15
     // QQVGA
     // c_img_cols    = 120, // 8 bits
     // c_img_rows    = 90, //  7 bits
     // c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
     // c_img_pxls    = c_img_cols * c_img_rows,
     // c_nb_img_pxls =  14,  //160*120=19.200 -> 2^15
     // QQVGA /2
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


  reg  winc, wclk, oclk;
  // rclk;
  reg  [DSIZE-1:0] wdata;
  reg              wrst_n;
  wire             wfull;
  wire             awfull;
  reg              rrst_n;
  reg              rinc;
  wire [DSIZE-1:0] rdata;
  wire             rempty;
  wire             arempty;

  wire          vga_visible;
  wire          vga_new_pxl;
  wire [10-1:0] vga_col;
  wire [10-1:0] vga_row;

  wire          vga_hsync_wr; // intermediate signal, not registered (wire)
  wire          vga_vsync_wr; // intermediate signal, not registered (wire

  wire [c_nb_img_pxls-1:0] display_img_addr;
  wire [c_nb_buf-1:0]      display_img_pxl;

  wire [c_nb_img_pxls-1:0] frame_addr;
  wire [c_nb_buf-1:0]    frame_pixel;

  wire [c_nb_img_pxls-1:0] capture_addr;
  wire [c_nb_buf-1:0]    capture_data;

  wire          capture_we;
  wire          capture_wen; // enable the write enable: stop capture

  wire [c_nb_img_pxls-1:0] orig_img_addr;
  wire [c_nb_buf-1:0]      orig_img_pxl;

  wire [c_nb_img_pxls-1:0] oled_img_addr;
  wire [c_nb_buf-1:0]      oled_img_pxl;
  wire          proc_we;

  wire          resend;
  wire          config_finished;

  wire          sdat_on;
  wire          sdat_out;  //  not making it INOUT, just out, but 3-state

  wire          clk50mhz;

  wire          rgbmode = 1'b1;
  wire          testmode;
  wire          locked_wire;
  parameter     swap_r_b = 1'b1; // red and blue are swapped

  wire clk = clk25mhz;
  // 50 MHz clock
  pll i_pll
      (
        .clkin(clk25mhz),
        .clkout0(clk50mhz),
        .locked(locked_wire)
      );



  vga_sync i_vga
           (
             .rst     (rst),
             .clk     (wclk),
             .visible (vga_visible),
             .new_pxl (vga_new_pxl),
             .hsync   (vga_hsync_wr),
             .vsync   (vga_vsync_wr),
             .col     (vga_col),
             .row     (vga_row)
           );


    vga_display
    # (
        .c_img_cols(c_img_cols), // 7 bits
        .c_img_rows(c_img_rows), //  6 bits
        .c_img_pxls(c_img_cols * c_img_rows),
        .c_nb_img_pxls(c_nb_img_pxls)
    )
    I_ov_display
    (
       .rst        (rst),
       .clk        (wclk),
       .visible    (vga_visible),
       .new_pxl    (vga_new_pxl),
       .hsync      (vga_hsync_wr),
       .vsync      (vga_vsync_wr),
       .rgbmode    (rgbmode),
       .col        (vga_col),
       .row        (vga_row),
       .frame_pixel(orig_img_pxl),
       .frame_addr (orig_img_addr),
       .hsync_out  (vga_hsync),
       .vsync_out  (vga_vsync),
       .vga_red    (vga_red),
       .vga_green  (vga_green),
       .vga_blue   (vga_blue)
    );
  // count 2 clock cycles to get a pixel cycle
  reg            cntO_clk; // count 0 to 1: 2 clk cycles, from 50MHz to 25MHz
  reg  [10-1:0]  cntO_pxl;
  reg  [10-1:0]  cntO_line;
  wire [10:0] c_line_total = 9'd80; 
  wire [10:0] c_pxl_total = 9'd60; 

  wire   end_cnt_pxl;
  wire   end_cnt_line;
  wire   new_line, new_pxl;
  always @ (posedge oclk)
  begin
    if (rst)
      cntO_clk <= 1'b0;
    else
      cntO_clk <= ~cntO_clk;
  end

  assign new_pxl =  cntO_clk;
  always @ (posedge oclk)
  begin
    if (rst)
      oled_img_addr <= 0;
    else
    begin
      if (x < c_img_rows)
      begin
        if (y < c_img_cols)
        begin
          if (new_pxl)
            //it may have a simulation problem in the last pixel of the last row
            oled_img_addr <= oled_img_addr + 1;
        end
      end
      else
        oled_img_addr <= 0;
    end
  end

  assign end_cnt_pxl =  (cnt0_pxl == c_pxl_total-1) ? 1'b1 : 1'b0;
  // new line: when in the end of the count and there is a new pixel
  assign new_line = end_cnt_pxl && new_pxl;


  always @ (posedge rst, posedge oclk)
  begin
    if (rst)
      cntO_line <= 10'd0;
    else begin
      if (new_line) begin
        if (end_cnt_line) 
          cntO_line <= 10'd0;
        else
          cntO_line <= cntO_line + 1;
      end
    end
  end 

  // end of pixel count
  assign end_cnt_line =  (cntO_line == c_line_total-1) ? 1'b1 : 1'b0;

  always @(posedge oclk) begin
      if (next_pixel) begin
      r  <= oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
      g  <= oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
      b  <= oled_img_pxl[c_nb_buf_blue-1:0]; 
    end

   wire [15:0] color = {r, g, b};

  // camera frame buffer, before processing
  frame_buffer
    # (
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
    )
    cam_fb
    (
      .clk     (wclk),
      .wea     (capture_wen),
      .addra   (capture_addr),
      .dina    (capture_data),
      .addrb   (orig_img_addr),
      .doutb   (orig_img_pxl)
    );

  // wire [6:0] x;
  // wire [6:0] y;
  // gen_pos ssd_clk(
  //           .clk(oclk),
  //           .out_hcnt(x),
  //           .out_vcnt(y),
  //           .rst(rst)
  //         );

 frame_buffer
    # (
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
    )
    cam_fb_oled
    (
      .clk     (oclk),
      .wea     (~capture_wen),
      .addra   (orig_img_addr),
      .dina    (orig_img_pxl),
      .addrb   (oled_img_addr),
      .doutb   (oled_img_pxl)
    );


  // stop capturing to see what happens with the image
  // if btnd is not pressed -> normal capture
  assign capture_wen = (btnd==1'b0) ? capture_we : 1'b0;

  ov7670_capture
    # (
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_nb_line_pxls(c_nb_img_pxls),
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
    )
    capture
    (
      .rst          (rst),
      .clk          (wclk),
      .pclk         (ov7670_pclk),
      .vsync        (ov7670_vsync),
      .href         (ov7670_href),
      .rgbmode      (rgbmode),
      .swap_r_b     (swap_r_b),
      //.dataout_test (ov_capture_datatest),
      //.led_test     (led[3:0]),
      .data         (ov7670_d),
      .addr         (capture_addr),
      .dout         (capture_data),
      .we           (capture_we)
    );


  ov7670_top_ctrl controller
                  (
                    .rst          (rst),
                    .clk          (wclk),
                    .resend       (resend),
                    .rgbmode      (rgbmode),
                    .testmode     (testmode),
                    .cnt_reg_test (led[5:0]),
                    .done         (config_finished),
                    .sclk         (ov7670_sioc),
                    .sdat_on      (sdat_on),
                    .sdat_out     (sdat_out),
                    .ov7670_rst_n (ov7670_rst_n),
                    .ov7670_clk   (ov7670_xclk),
                    //.ov7670_pwdn  (ov7670_pwdn)
                  );
  assign ov7670_pwdn = 1'b0; //not working from the component

  assign resend = 1'b0;
  assign ov7670_siod = sdat_on ? sdat_out : 1'bz;

  assign led[7] = config_finished;
  assign led[6] = btnd;

  parameter C_color_bits = 8; // 8 or 16

  localparam DSIZE = c_nb_buf;
  localparam ASIZE = c_img_pxls;

  wire [6:0] x;
  wire [5:0] y;

  reg [4:0] r= {5{1'b0}};
  reg [4:0] g= {5{1'b0}};
  reg [5:0] b= {6{1'b0}};
  //  reg[15:0] color_pxl = {16{1'b0}};

  //  wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};
  //  wire [15:0] color = color_pxl;
  //  wire [15:0] color = {g, b, r};
  // wire [7:0] color = {r,g, b};

  //     // r  <= orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     // g  <= orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     // b  <= orig_img_pxl[c_nb_buf_blue-1:0];
  // reg [8:0] color;
  // wire [15:0] color;
  wire next_pixel;
  wire oclk;

  oled_video
    #(
      .c_init_file("ssd1351_oinit_xflip_16bit.mem"),
      .c_x_size(80),
      .c_y_size(60),
      .c_color_bits(C_color_bits)
    )
    oled_video_inst
    (
      .clk(oclk),
      // .reset(~btn0),
      .reset(~capture_wen),
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
  
  // end


  assign wclk = clk50mhz;
  // assign wclk = clk25mhz;
  assign oclk = clk25mhz;
  // //   assign rrst_n = btn0;


  // always @(posedge wclk)
  // begin
  //   if(rst)
  //   begin
  //     winc<= 1;
  //     wrst_n <= 0;
  //   end
  //   else
  //   begin
  //     //  wdata <= {{1'b0, vga_red},{1'b0, vga_green},{2'b0, vga_blue}};
  //     // wdata <= orig_img_pxl;
  //     wdata <= capture_data;
  //   end
  // end

  // always @(posedge oclk)
  // begin
  //   if(rst)
  //   begin
  //     rinc <=1;
  //     rrst_n<=0;
  //   end
  //   else
  //   begin

  //     //   if ((x < c_img_cols) && (y < c_img_rows)) begin
  //     // r  <= {1'b0, rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
  //     // g  <= {1'b0, rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
  //     // b  <= {2'b0, rdata[c_nb_buf_blue-1:0]};

  //     // r  <= rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     // g  <= rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     // b  <= rdata[c_nb_buf_blue-1:0];

  //     if (next_pixel) begin
  //       // if ((x < 128) && (y < 128)) begin

  //     r  <= rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     g  <= rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     b  <= rdata[c_nb_buf_blue-1:0];

  //     // r  <= orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     // g  <= orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     // b  <= orig_img_pxl[c_nb_buf_blue-1:0];
  //     // r  <= {1'b0, rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
  //     // g  <= {1'b0, rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
  //     // b  <= {2'b0, rdata[c_nb_buf_blue-1:0]};
  //         // r  <= rdata[7:4];
  //         // g  <= rdata[7:4];
  //         // b  <= rdata[7:4];

  //         // color <= {r[2:0], g[2:0], b[1:0]};
  //       end
  //     // end
  //     //   end
  //     //   else begin
  //     //     r <=5'b0;
  //     //     g <=5'b0;
  //     //     b <=6'b0;
  //     //   end

  //     // color_pxl<=rdata;

  //   end
  // end

  // // we need async fifo to keep to clocks one for the tpu and other for the input stream
  // async_fifo
  //   #(
  //     DSIZE,
  //     ASIZE
  //   )
  //   fifo
  //   (
  //     wclk,
  //     wrst_n,
  //     winc,
  //     wdata,
  //     wfull,
  //     awfull,
  //     oclk,
  //     rrst_n,
  //     rinc,
  //     rdata,
  //     rempty,
  //     arempty
  //   );



endmodule

