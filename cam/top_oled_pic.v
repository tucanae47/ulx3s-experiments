

module top_oled_pic
    (input        rst,         // btn fire 1
     input        clk25mhz,    // 25mhz clk
     input        btn2,          // btn fire 2:
     input        btnd,          // down:stop capture
     input        btnr,          // right: color processing
     output       ov7670_rst_n,
     output       ov7670_pwdn,
     output       vga_hsync,
     output       vga_vsync,
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

wire [4:0] r; 
wire [4:0] g;
wire [5:0] b;

bram_buffer buf_rgb (
    .clk(clk),
    .reset(~btn0),
    .row(x),
    .col(y),
    .oe(1),
    .r(r),
    .g(g),
    .b(b)
);


wire next_pixel;

oled_video
    #(
      .c_init_file("ssd1351_linit_xflip_16bit.mem"),
      .c_x_size(128),
      .c_y_size(128),
      .c_color_bits(16)
    )
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

wire [15:0] color = (next_pixel)?{b,g,r}: 16'd0;
endmodule

