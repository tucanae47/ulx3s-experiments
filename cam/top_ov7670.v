

module top_ov7670
  # (parameter
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
             //  .end_img (end_img)
           );

  // localparam c_line_total = 80 * 60;
  localparam c_line_total = 520;
// 
  // always @(posedge wclk) begin
  //   end_img <= vga_row[0];
  // end
  // always @(posedge wclk)
  // begin
  //   // assign end_img =  (orig_img_addr == c_line_total-1) ? 1'b1 : 1'b0;
  //   // if (orig_img_addr > 2000)
  //    if  (vga_row == c_line_total-1)
  //     end_img <=1'b1;
  //   else
  //     end_img <=1'b0;
  // end
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
  reg  [10-1:0]  cntO_pxl;
  reg  [10-1:0]  cntO_line;
  wire [10:0] c_line_total = 9'd80;
  wire [10:0] c_pxl_total = 9'd60;

  wire   end_cnt_pxl;
  wire   end_cnt_line;
  wire   new_line, new_pxl;

  // always @ (posedge oclk)
  // begin
  //   if (~capture_wen)
  //     oled_img_addr <= 0;
  //   else
  //   begin
  //     if (x < c_img_rows)
  //     begin
  //       if (y < c_img_cols)
  //       begin
  //         oled_img_addr <= oled_img_addr + 1;
  //       end
  //     end
  //     else
  //       oled_img_addr <= 0;
  //   end
  // end

  // assign end_cnt_pxl =  (cntO_pxl == c_pxl_total-1) ? 1'b1 : 1'b0;

  // // new line: when in the end of the count and there is a new pixel
  // assign new_line = end_cnt_pxl;


  // always @ (posedge oclk)
  // begin
  //   if (~capture_wen)
  //     cntO_line <= 10'd0;
  //   else
  //   begin
  //     if (new_line)
  //     begin
  //       if (end_cnt_line)
  //         cntO_line <= 10'd0;
  //       else
  //         cntO_line <= cntO_line + 1;
  //     end
  //   end
  // end

  // // end of pixel count
  // assign end_cnt_line =  (cntO_line == c_line_total-1) ? 1'b1 : 1'b0;

  // always @(posedge oclk)
  // begin
  //   if (next_pixel)
  //   begin

  //     r  <= {1'b0, oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
  //     g  <= {1'b0, oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
  //     b  <= {2'b0, oled_img_pxl[c_nb_buf_blue-1:0]};
  //     // r  <= oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  //     // g  <= oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  //     // b  <= oled_img_pxl[c_nb_buf_blue-1:0];
  //   end
  // end

  // assign r  = oled_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  // assign g  = oled_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  // assign b  = oled_img_pxl[c_nb_buf_blue-1:0];
  //  reg [15:0] color;

  //  wire [15:0] color = vga_col[3] ^ vga_row[3] ? {5'd0, vga_row[6:1], 5'd0} : {vga_col[5:1], 6'd0, 5'd0};
  //  wire [15:0] color = {vga_row[5:0],5'd0,  vga_col[5:0]};
  // wire [15:0] color = {6'd255,5'd0, 6'd255};
  
      // color = {x[5:0],5'd0,  y[5:0]};

  //  wire [15:0] color = {vga_row[5:0],5'd0,  vga_col[5:0]};
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

  // frame_buffer
  //   # (
  //     .c_img_cols(c_img_cols), // 7 bits
  //     .c_img_rows(c_img_rows), //  6 bits
  //     .c_img_pxls(c_img_cols * c_img_rows),
  //     .c_nb_img_pxls(c_nb_img_pxls)
  //   )
  //   cam_fb_oled
  //   (
  //     .clk     (oclk),
  //     .wea     (~capture_wen),
  //     .addra   (orig_img_addr),
  //     .dina    (orig_img_pxl),
  //     .addrb   (oled_img_addr),
  //     .doutb   (oled_img_pxl)
  //   );
  localparam STATE_LOAD           = 0;
  localparam STATE_UPDATE         = 1;
  reg enr;

  //  always @(posedge wclk)
  //   begin
  //     if(reset)
  //     begin
  //       dac_state           <= STATE_LOAD;
  //       img<=0;
  //     end
  //     else
  //     begin
  //       case(dac_state)
  //         STATE_LOAD:
  //         begin
  //             if (end_cnt_line)
  //               img <= img + 1;
  //             if (img > 2)
  //               dac_state       <= STATE_UPDATE;
  //         end
  //         STATE_UPDATE: begin
  //           dac_state       <= STATE_WAIT;
  //         end
  //         default:
  //           dac_state       <= STATE_WAIT;
  //       endcase
  //     end
  // reg [15:0] color;
  // wire [15:0] color;
  reg end_img;
  // color <= {vga_row[5:0],5'd0,  vga_col[5:0]};
  // assign color = {img[5:0] ^ img[6:1],img[7:3] ^ img[4:0], img[7:2] ^ img[5:0]};

  // wire [15:0] color = img[5:0] ^ img[6:1] ? {5'd0, img[6:1], 5'd0} : {img[5:1], 6'd0, 5'd0};
  always @(posedge wclk) begin
  if (vga_row == c_img_rows -1 && vga_col == c_img_cols - 1) 
      end_img<= 1;
    else
      end_img<= 0;
  end
  reg [7:0] img, img_g;
  // always @(posedge end_img)
  // begin
  //   if(rst)
  //     img<=0;
  //   else
  //     img <= img + 1;
  // end
  localparam N = 8;

  always @(posedge end_img)
  begin
    if(rst)begin
      img<=0;
      img_g<=0;
    end
    else begin
      img <= img + 1;
      img_g <= {img[N-1], img[N-1:1] ^ img[N-2:0]};
    end
      // img <= img ^ img[7:1]; 
  end
  assign led = img_g;
  // stop capturing to see what happens with the image
  // if btnd is not pressed -> normal capture
  // assign capture_wen = (btnd==1'b0 && ~enr) ? capture_we : 1'b0;
  // assign capture_wen = (img < 10 && btnd==1'b0) ? capture_we : 1'b0;
  assign capture_wen = (~enable_oled && btnd==1'b0 ) ? capture_we : 1'b0;

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
      .clk          (oclk),
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
                    .clk          (oclk),
                    .resend       (resend),
                    .rgbmode      (rgbmode),
                    .testmode     (testmode),
                    // .cnt_reg_test (led[5:0]),
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
//  always @(posedge wclk) begin
  
  // assign led[7:5] = vga_row[8:6];
      // led[7:5] <= vga_row[8:6];
//  end
  // assign led[6] = btnd;

  // assign led[7] = img;
  // assign led[6] = btnd;

  parameter C_color_bits = 16; // 8 or 16

  localparam DSIZE = c_nb_buf;
  localparam ASIZE = c_img_pxls;

  wire [6:0] x;
  wire [5:0] y;

  reg [4:0] r= {5{1'b0}};
  reg [4:0] g= {5{1'b0}};
  reg [5:0] b= {6{1'b0}};
  wire next_pixel;
  wire oclk;
  wire enable_oled; 
    
  assign enable_oled = (img_g>8'd254) ? 1'b1 : 1'b0;

  // wire [15:0] color = {r, g, b};
  oled_video
    #(
      // .c_init_file("ssd1351_oinit_xflip_16bit.mem"),
      .c_x_size(80),
      .c_y_size(60),
      .c_color_bits(C_color_bits)
    )
    oled_video_inst
    (
      .clk(oclk),
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

  // end
  // assign r = orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
  // assign g = orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
  // assign b = orig_img_pxl[c_nb_buf_blue-1:0];

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
  //     wdata <= orig_img_pxl;
  //     // wdata <= capture_data;
  //   end
  // end

  // wire [15:0] color = {b, r, g};
  wire [15:0] color = {r,g,b};
  // wire [15:0] color = {b, g, r};
  always @(posedge oclk)
  begin
    // if(rst)
    // begin
    //   rinc <=1;
    //   rrst_n<=0;
    // end
    // begin
      // if (next_pixel)
      // begin
        // r  <= {1'b0, orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red]};
        // g  <= {1'b0, orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue]};
        // b  <= {2'b0, orig_img_pxl[c_nb_buf_blue-1:0]};
        r  <= orig_img_pxl[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
        g  <= orig_img_pxl[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
        b  <= orig_img_pxl[c_nb_buf_blue-1:0];
      // end
    // end
  end

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

