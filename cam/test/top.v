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
`default_nettype none
`timescale 1ns / 1ps
module clk_div_n #(
    parameter WIDTH = 7)

  (
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] div_num,
    output reg clk_out
  );


  reg [WIDTH-1:0] pos_count;

  always @(posedge clk)
    if (rst)
      pos_count <=0;
    else if (pos_count ==div_num-1)
    begin
      clk_out <= 1;
      pos_count<=0;
    end
    else
    begin
      pos_count<= pos_count +1;
      clk_out<=0;
    end
endmodule

module top
  # (parameter
     c_img_cols    = 160, // 8 bits
     c_img_rows    = 120, //  7 bits
     c_nb_line_pxls = 8, // log2i(c_img_cols-1) + 1;
     c_img_pxls    = c_img_cols * c_img_rows,
     c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15
     // QQVGA
     // QQVGA /2
    //  c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
    //  c_img_cols    = 80, // 7 bits
    //  c_img_rows    = 60, //  6 bits
    //  c_img_pxls    = c_img_cols * c_img_rows,
    //  c_nb_img_pxls =  13,  //80*60=4800 -> 2^13

     c_nb_buf_red   =  4,  // n bits for red in the buffer (memory)
     c_nb_buf_green =  4,  // n bits for green in the buffer (memory)
     c_nb_buf_blue  =  4,  // n bits for blue in the buffer (memory)
     // word width of the memory (buffer)
     c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue


    )
    (input        rst,         // btn fire 1
     input        clk,    // 25mhz clk
     output [3:0] vga_red,
     output [3:0] vga_green,
     output [3:0] vga_blue,
     output       vga_hsync,
     output       vga_vsync
    );


  reg  winc, wclk, rclk;
  wire clk2;

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
 
  clk_div_n div(
              .rst(rst),
              .clk(clk),
              .div_num(2),
              .clk_out(clk2)
            );

  vga_sync i_vga
           (
             .rst     (rst),
             .clk     (clk),
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
       .clk        (clk),
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
      .clk     (clk),
      .wea     (capture_wen),
      .addra   (capture_addr),
      .dina    (capture_data),
      .addrb   (orig_img_addr),
      .doutb   (orig_img_pxl)
    );

  wire [6:0] x;
  wire [5:0] y;

  wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};

  oled_video
    #(
      .c_init_file("ssd1351_oinit_xflip_16bit.mem"),
      .c_x_size(80),
      .c_y_size(60),
      .c_color_bits(5'd16)
    )
    oled_video_inst
    (
      .clk(clk2),
      .reset(rst),
      .x(x),
      .y(y),
      .color(color)
    );





endmodule

