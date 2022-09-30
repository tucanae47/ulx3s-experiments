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


  reg  winc, wclk, rclk;
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



  // vga_sync i_vga
  //          (
  //            .rst     (rst),
  //            .clk     (wclk),
  //            .visible (vga_visible),
  //            .new_pxl (vga_new_pxl),
  //            .hsync   (vga_hsync_wr),
  //            .vsync   (vga_vsync_wr),
  //            .col     (vga_col),
  //            .row     (vga_row)
  //          );


  //   vga_display
  //   # (
  //       .c_img_cols(c_img_cols), // 7 bits
  //       .c_img_rows(c_img_rows), //  6 bits
  //       .c_img_pxls(c_img_cols * c_img_rows),
  //       .c_nb_img_pxls(c_nb_img_pxls)
  //   )
  //   I_ov_display
  //   (
  //      .rst        (rst),
  //      .clk        (wclk),
  //      .visible    (vga_visible),
  //      .new_pxl    (vga_new_pxl),
  //      .hsync      (vga_hsync_wr),
  //      .vsync      (vga_vsync_wr),
  //      .rgbmode    (rgbmode),
  //      .col        (vga_col),
  //      .row        (vga_row),
  //      .frame_pixel(orig_img_pxl),
  //      .frame_addr (orig_img_addr),
  //      .hsync_out  (vga_hsync),
  //      .vsync_out  (vga_vsync),
  //      .vga_red    (vga_red),
  //      .vga_green  (vga_green),
  //      .vga_blue   (vga_blue)
  //   );
  // count 2 clock cycles to get a pixel cycle
  reg            cnt_clk; // count 0 to 1: 2 clk cycles, from 50MHz to 25MHz
  reg  [10-1:0]  cnt_pxl;
  reg  [10-1:0]  cnt_line;

  wire   end_cnt_pxl;
  wire   end_cnt_line;
  wire   new_line, new_pxl;
  always @ (posedge rclk)
  begin
    if (rst)
      cnt_clk <= 1'b0;
    else
      cnt_clk <= ~cnt_clk;
  end

  assign new_pxl =  cnt_clk;
  always @ (posedge rclk)
  begin
    if (rst)
      orig_img_addr <= 0;
    else
    begin
      if (vga_row < c_img_rows)
      begin
        if (vga_col < c_img_cols)
        begin
          if (new_pxl)
            //it may have a simulation problem in the last pixel of the last row
            orig_img_addr <= orig_img_addr + 1;
        end
      end
      else
        orig_img_addr <= 0;
    end
  end

  // camera frame buffer, before processing
  // frame_buffer
  //   # (
  //     .c_img_cols(c_img_cols), // 7 bits
  //     .c_img_rows(c_img_rows), //  6 bits
  //     .c_img_pxls(c_img_cols * c_img_rows),
  //     .c_nb_img_pxls(c_nb_img_pxls)
  //   )
  //   cam_fb
  //   (
  //     .clk     (rclk),
  //     .wea     (capture_wen),
  //     .addra   (capture_addr),
  //     .dina    (capture_data),
  //     .addrb   (orig_img_addr),
  //     .doutb   (orig_img_pxl)
  //   );


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
  wire [7:0] color = {r,g, b};

  // reg [8:0] color;
  // wire [15:0] color;
  wire next_pixel;
  wire oclk;

  oled_video
    #(
      .c_init_file("ssd1351_oinit_xflip_16bit.mem"),
      .c_x_size(128),
      .c_y_size(128),
      .c_color_bits(C_color_bits)
    )
    oled_video_inst
    (
      .clk(oclk),
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
  
  //   always @(posedge rclk) begin
  //     if (next_pixel) begin
  //     r  <= capture_data[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     g  <= capture_data[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     b  <= capture_data[c_nb_buf_blue-1:0]; 
  //     // color<= {r[3:0], g[3:0], b[2:0]};

  //   end
  // end


  assign wclk = clk50mhz;
  // assign wclk = clk25mhz;
  assign oclk = clk25mhz;
  // //   assign rrst_n = btn0;


  always @(posedge wclk)
  begin
    if(rst)
    begin
      winc<= 1;
      wrst_n <= 0;
    end
    else
    begin
      //  wdata <= {{1'b0, vga_red},{1'b0, vga_green},{2'b0, vga_blue}};
      // wdata <= orig_img_pxl;
      wdata <= capture_data;
    end
  end

  always @(posedge rclk)
  begin
    if(rst)
    begin
      rinc <=1;
      rrst_n<=0;
    end
    else
    begin

      //   if ((x < c_img_cols) && (y < c_img_rows)) begin
      // r  <= {1'b0, rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
      // g  <= {1'b0, rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
      // b  <= {2'b0, rdata[c_nb_buf_blue-1:0]};

      // r  <= rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
      // g  <= rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
      // b  <= rdata[c_nb_buf_blue-1:0];

      if (next_pixel) begin
        // if ((x < 128) && (y < 128)) begin

      r  <= rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
      g  <= rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
      b  <= rdata[c_nb_buf_blue-1:0];

      // r  <= orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
      // g  <= orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
      // b  <= orig_img_pxl[c_nb_buf_blue-1:0];
      // r  <= {1'b0, rdata[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
      // g  <= {1'b0, rdata[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
      // b  <= {2'b0, rdata[c_nb_buf_blue-1:0]};
          // r  <= rdata[7:4];
          // g  <= rdata[7:4];
          // b  <= rdata[7:4];

          // color <= {r[2:0], g[2:0], b[1:0]};
        end
      // end
      //   end
      //   else begin
      //     r <=5'b0;
      //     g <=5'b0;
      //     b <=6'b0;
      //   end

      // color_pxl<=rdata;

    end
  end

  // we need async fifo to keep to clocks one for the tpu and other for the input stream
  async_fifo
    #(
      DSIZE,
      ASIZE
    )
    fifo
    (
      wclk,
      wrst_n,
      winc,
      wdata,
      wfull,
      awfull,
      rclk,
      rrst_n,
      rinc,
      rdata,
      rempty,
      arempty
    );



endmodule

