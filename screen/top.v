

module top
  # (parameter
     // VGA
     c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
     c_img_cols    = 80, // 7 bits
     c_img_rows    = 80, //  6 bits
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
     input  wire btn0,
     output wire oled_csn,
     output wire oled_clk,
     output wire oled_mosi,
     output wire oled_dc,
     output wire oled_resn
    );


wire [6:0] x;
wire [6:0] y;
wire clk = clk25mhz;

// reg [4:0] r= {5{1'b0}};
// reg [4:0] g= {5{1'b0}};
// reg [5:0] b= {6{1'b0}};

wire [4:0] r; 
wire [4:0] g;
wire [5:0] b;
// gen_pos ssd_clk(
//             .clk(clk),
//             .x(x),
//             .y(y),
//             .rst(rst)
//           );

// wire [11:0] rgb;

bram_buffer buf_rgb (
    .clk(clk),
    .reset(~btn0),
    // .reset(rst),
    .row(x),
    .col(y),
    .oe(1'd1),
    .r(r),
    .g(g),
    .b(b)
);

reg [15:0] color;

 always @ (posedge clk)
  begin
      if (x < c_img_rows) begin
        if (y < c_img_cols) begin
          color<={5'd0, x[6:1], 5'd0};
        end
      end
      else begin
        color<= {r,g,b};
      end
end

// wire [15:0] color = (oled_img_addr>0)?{r,g,b}: {5'd0, x[6:1], 5'd0};

  //  wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};
// wire [15:0] color = (next_pixel)?{b,g,r}: 16'd0;
oled_video
    #(
      // .c_init_file("ssd1351_oinit.mem"),
      // .c_init_file("ssd1351.mem"),
      // .c_init_file("ssd1351_linit_xflip_16bit.mem"),
      .c_x_size(128),
      .c_y_size(128),
      .c_color_bits(16)
    )
    oled_video_inst
    (
      .clk(clk),
      .reset(~btn0),
      // .reset(rst),
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
//  wire clk = clk50mhz;
//   wire          clk50mhz;
//   wire          locked_wire;
//   // 50 MHz clock
//   pll i_pll
//       (
//         .clkin(clk25mhz),
//         .clkout0(clk50mhz),
//         .locked(locked_wire)
//       );
// wire next_pixel;
//  reg [15:0] R_color;
//   always @(posedge clk)
//     if(next_pixel)
//       R_color <= color;
//  wire w_oled_csn;
//   lcd_video
//   #(
//     .c_clk_spi_mhz(50),
//     .c_init_file("st7789_linit.mem"),
//     .c_clk_phase(0),
//     .c_clk_polarity(1)
//   )
//   lcd_video_inst
//   (
//     .reset(~btn0),
//     .clk_pixel(clk),
//     .clk_spi(clk),
//     .x(x),
//     .y(y),
//     .next_pixel(next_pixel),
//     .color(R_color),
//     .spi_clk(oled_clk),
//     .spi_mosi(oled_mosi),
//     .spi_dc(oled_dc),
//     .spi_resn(oled_resn),
//     .spi_csn(w_oled_csn)
//   );

// wire [15:0] color = {r,g,b};
// wire [15:0] color;
// assign color = (next_pixel)?{b,g,r}: 16'd0;
// wire [15:0] color = (next_pixel)?{r,g,b}: 16'd0;
// wire [15:0] color = (next_pixel)?{b,g,r}: 16'd0;
    // Next pixel is not working
// wire [15:0] color = {b,g,r};
endmodule
