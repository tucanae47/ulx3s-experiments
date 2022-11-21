

module top_ov7670
  # (parameter
    // c_img_cols    = 320, // 9 bits
    //  c_img_rows    = 240, // 8 bits
    //  c_img_pxls    = c_img_cols * c_img_rows,
    //  c_nb_line_pxls = 9, // log2i(c_img_cols-1) + 1;
    //  c_nb_img_pxls =  17,  //320*240=76,800 -> 2^17

    //  c_nb_line_pxls = 8, // log2i(c_img_cols-1) + 1;
    //   c_img_cols    = 160, // 8 bits
    //   c_img_rows    = 120, //  7 bits
    //   c_img_pxls    = c_img_cols * c_img_rows,
    //   c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15


      f_img_cols    = 128, // 8 bits
      f_img_rows    = 128, //  7 bits
      f_img_pxls    = f_img_cols * f_img_rows,
      f_nb_img_pxls =  14,  //160*120=19.200 -> 2^15
     // VGA
     c_nb_line_pxls = 7, // log2i(c_img_cols-1) + 1;
     c_img_cols    = 80, // 7 bits
     c_img_rows    = 60, //  6 bits
     c_img_pxls    = c_img_cols * c_img_rows,
     c_nb_img_pxls =  13,  //80*60=4800 -> 2^13

     c_nb_buf_red   =  5,  // n bits for red in the buffer (memory)
     c_nb_buf_green =  5,  // n bits for green in the buffer (memory)
     c_nb_buf_blue  =  6,  // n bits for blue in the buffer (memory)
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

// assign rst = ~btn0;
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
             .clk     (oclk),
             .visible (vga_visible),
             .new_pxl (vga_new_pxl),
             .hsync   (vga_hsync_wr),
             .vsync   (vga_vsync_wr),
             .col     (vga_col),
             .row     (vga_row)
             //  .end_img (end_img)
           );

  // localparam c_line_total = 80 * 60;
  // localparam c_line_total = 520;

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
      .clk        (oclk),
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
  reg  [10-1:0]  cntO_pxl;
  reg  [10-1:0]  cntO_line;
  // wire [10:0] c_line_total = 9'd80;
  // wire [10:0] c_pxl_total = 9'd60;

  wire   end_cnt_pxl;
  wire   end_cnt_line;
  wire   new_line, new_pxl;
  reg fb_front;

frame_buffer
    #(
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
    )
    cam_vga
    (
      .clk     (oclk),
      .wea     (capture_wen),
      // .wea     (capture_wen && fb_front),
      .addra   (capture_addr),
      .dina    (capture_data),
      .addrb   (orig_img_addr),
      .doutb   (orig_img_pxl)
    );

  frame_buff
    #(
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
      // .c_img_cols(128), // 7 bits
      // .c_img_rows(128), //  6 bits
      // .c_img_pxls(128*128),
      // .c_nb_img_pxls(14)
    )
    cam_fb
    (
      .clk     (oclk),
      .wea     (capture_wen),
      // .wea     (capture_wen && !fb_front),
      .addra   (capture_addr),
      .dina    (capture_data),
      .row(x),
      .col(y),
      .r(r),
      .g(g),
      .b(b)
    );

  localparam STATE_LOAD           = 1;
  localparam STATE_INIT        = 2;
  localparam STATE_DISPLAY         = 4;
  reg enr;

  reg end_img;
//   reg [2:0]  state;
//  always @(posedge clk) begin
//         if(rst) begin
//                 state<=STATE_INIT;
//                 // fb_front<=1;
//         end else begin
//           case(state)
//                 STATE_INIT: begin
//                   if (config_finished==1'b1) begin
//                       state <= STATE_LOAD;
//                   end
//                 end
//                 STATE_LOAD: begin
//                     if (capture_addr==0) begin
//                     state<= STATE_DISPLAY;
//                     // cam_reset <= ~cam_reset;
//                     end
//                 end
//                 STATE_DISPLAY: begin
//                 // if (oled_img_addr > 16000)
//                   // state<=STATE_LOAD;
//                   oled_reset <= ~oled_reset;
//                 end
//                 default:
//                 state<=STATE_INIT;
//           endcase
//         end
//     end

 
  assign led[7] = config_finished;
  // assign led[6] = enable_oled;
  // assign led[0] = state[0];
  // assign led[1] = state[1];
  assign led[0] = (capture_addr==0)? 1'b1 : 1'b0;
  assign led[1] = (orig_img_addr==0)? 1'b1 : 1'b0;
  assign led[2] = (oled_img_addr==0) ? 1'b1 : 1'b0;
  // assign led[2] = (capture_addr==0)?;
  // assign led[3:5] = {1'b0, 1'b0, 1'b0};
  assign led[3:6] = orig_img_addr[c_nb_img_pxls-4:c_nb_img_pxls-1];
  wire enable_oled;
  // wire cam_reset = btn0;
  // wire oled_reset = btnd;
  // assign enable_oled = (img>8'd254) ? 1'b1 : 1'b0;
  assign capture_wen = (~enable_oled) ? capture_we : 1'b0;

  ov7670_capture
    # (
      .c_img_cols(c_img_cols), // 7 bits
      .c_img_rows(c_img_rows), //  6 bits
      .c_nb_line_pxls(c_nb_line_pxls),
      .c_img_pxls(c_img_cols * c_img_rows),
      .c_nb_img_pxls(c_nb_img_pxls)
    )
    capture
    (
      .rst          (rst),
      .clk          (oclk),
      .pclk         (ov7670_pclk),
      .vsync        (ov7670_vsync),
      .href         (ov7670_href),
      .rgbmode      (rgbmode),
      .swap_r_b     (swap_r_b),
      .data         (ov7670_d),
      .addr         (capture_addr),
      .dout         (capture_data),
      .we           (capture_we)
    );


  ov7670_top_ctrl controller
                  (
                  // .rst          (cam_reset),
                    .rst          (rst),
                    .clk          (oclk),
                    .resend       (resend),
                    // .cnt_reg_test (led[5:0]),
                    .rgbmode      (rgbmode),
                    // .cnt_reg_test (led[5:0]),
                    .testmode     (testmode),
                    .done         (config_finished),
                    .sclk         (ov7670_sioc),
                    .sdat_on      (sdat_on),
                    .sdat_out     (sdat_out),
                    .ov7670_rst_n (ov7670_rst_n),
                    .ov7670_clk   (ov7670_xclk),
                  );
  assign ov7670_pwdn = 1'b0; //not working from the component

  assign resend = 1'b0;
  assign ov7670_siod = sdat_on ? sdat_out : 1'bz;


  parameter C_color_bits = 16; // 8 or 16

  localparam DSIZE = c_nb_buf;
  localparam ASIZE = c_img_pxls;

  wire [6:0] x;
  wire [6:0] y;

  // reg [4:0] r= {5{1'b0}};
  // reg [4:0] g= {5{1'b0}};
  // reg [5:0] b= {6{1'b0}};

  reg [4:0] r;
  reg [4:0] g;
  reg [5:0] b;
  wire next_pixel;
  wire oclk;

  assign wclk = clk50mhz;
  assign oclk = clk50mhz;
  // wire [15:0] color = {r, g, b};
  oled_video
    oled_video_inst
    (
      .clk(oclk),
      // .reset(rst),
      // .reset(oled_reset),
      .reset(~btn0),
      // .reset(enable_oled),
      // .reset(~capture_wen),
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

  // wire [15:0] color=  {r,g,b};
reg [15:0] color;
// always @ (posedge oclk)begin
//         color<= {r,g,b};
// end
always @ (posedge oclk)
  begin
      if (x < c_img_rows) begin
        if (y < c_img_cols) begin
          color<= {r,g,b};
        end
      end
      else begin
          color<={5'd0, 6'd128, 5'd0};
      end
end

  // assign  r  = oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  // assign  g  = oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  // assign  b  = oled_img_pxl[c_nb_buf_blue-1:0];
  // always @(posedge oclk)
  // begin
  //   if (orig_img_addr==0) begin
  //     oled_img_addr <= 0;
  //     fb_front<=~fb_front;
  //     // {r,g,b}<={5'd0, 5'd0, 6'd0};
  //   end
  //   else
  //   begin
  //         r  <= oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //         g  <= oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //         b  <= oled_img_pxl[c_nb_buf_blue-1:0];
  //         oled_img_addr <= oled_img_addr + 1;
  //         // color<= {r,g,b};
  //       // end
  //     end
  //   end

endmodule

