//------------------------------------------------------------------------------
//   Felipe Machado Sanchez
//   Area de Tecnologia Electronica
//   Universidad Rey Juan Carlos
//   https://github.com/felipe-m
//
//   vga_display.v
//   Displays the image on the frambuffer to the VGA
//   outputs are registered to see if the displayed image improves
//

module vga_display
  # (parameter
      // VGA
      // active level of synchronization
      c_synch_act      = 0,
      // VGA
      //c_img_cols    = 640, // 10 bits
      //c_img_rows    = 480, //  9 bits
      //c_img_pxls    = c_img_cols * c_img_rows,
      //c_nb_line_pxls = 10, // log2i(c_img_cols-1) + 1;
      // c_nb_img_pxls = log2i(c_img_pxls-1) + 1
      //c_nb_img_pxls =  19,  //640*480=307,200 -> 2^19=524,288
      // QQVGA
      //c_img_cols    = 160, // 8 bits
      //c_img_rows    = 120, //  7 bits
      //c_img_pxls    = c_img_cols * c_img_rows,
      //c_nb_img_pxls =  15,  //160*120=19.200 -> 2^15
      // QQVGA /2
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
  (
    input          rst,       //reset, active high
    input          clk,       //fpga cloc
    input          visible,
    input          new_pxl,
    input          hsync,
    input          vsync,
    input          rgbmode,
    input [10-1:0] col,
    input [10-1:0] row,
    input  [c_nb_buf-1:0] frame_pixel,
    output reg [c_nb_img_pxls-1:0] frame_addr,
    output reg     hsync_out, // registered for synchronization
    output reg     vsync_out,
    output reg [4-1:0] vga_red,
    output reg [4-1:0] vga_green,
    output reg [4-1:0] vga_blue
  );

  reg  [7:0] char_rgbmode, char_testmode;
  wire [2:0] char_row;
  wire [2:0] char_col;
  wire [3:0] addr_rom_rgb;

  reg [4-1:0] vga_red_wr;
  reg [4-1:0] vga_green_wr;
  reg [4-1:0] vga_blue_wr;

  reg [4-1:0] vga_red_rg;
  reg [4-1:0] vga_green_rg;
  reg [4-1:0] vga_blue_rg;
  reg         hsync_rg;
  reg         vsync_rg;


  assign char_row = row[2:0];
  assign char_col = col[2:0];
  assign addr_rom_rgb = {~rgbmode, char_row};

  always @ (addr_rom_rgb) begin
    case (addr_rom_rgb)
      4'h0: char_rgbmode <= 8'b11111100; // R: RGB
      4'h1: char_rgbmode <= 8'b10000010;
      4'h2: char_rgbmode <= 8'b10000010;
      4'h3: char_rgbmode <= 8'b11111100;
      4'h4: char_rgbmode <= 8'b10001000;
      4'h5: char_rgbmode <= 8'b10000100;
      4'h6: char_rgbmode <= 8'b10000010;
      4'h7: char_rgbmode <= 8'b00000000;
      4'h8: char_rgbmode <= 8'b10000010; // Y: YUV
      4'h9: char_rgbmode <= 8'b01000100;
      4'hA: char_rgbmode <= 8'b00111000;
      4'hB: char_rgbmode <= 8'b00010000;
      4'hC: char_rgbmode <= 8'b00010000;
      4'hD: char_rgbmode <= 8'b00010000;
      4'hE: char_rgbmode <= 8'b00010000;
      4'hF: char_rgbmode <= 8'b00000000;
    endcase
  end



  always @ (posedge rst, posedge clk)
  begin
    if (rst)
      frame_addr <= 0;
    else begin
      if (row < c_img_rows) begin
        if (col < c_img_cols) begin
          if (new_pxl)
            //it may have a simulation problem in the last pixel of the last row
            frame_addr <= frame_addr + 1;
        end
      end
      else
        frame_addr <= 0;
    end
  end

  // registering the combinational part, the part that comes from memory
  // is already registered, and registering it would lead to unsynchronization
  always @ (*)
  begin
    vga_red_wr   = {4{1'b0}};
    vga_green_wr = {4{1'b0}};
    vga_blue_wr  = {4{1'b0}};
    if (col < 256) begin
      if (row < 256) begin
        if ((row >= 128) && (row < 128 + 8)) begin
          if ((col > 7) && (col < 16)) begin // RGB MODE
            if (char_rgbmode[7-char_col]) begin
              vga_red_wr   = 4'b1111;
              vga_green_wr = 4'b1111;
              vga_blue_wr  = 4'b1111;
            end
          end
        end
        else if (row > 240) begin
          if (col < 64) begin
            // Test grayscale  square of 16 pixels
            vga_red_wr    = {col[5:4],2'b00};
            vga_green_wr  = {col[5:4],2'b00};
            vga_blue_wr   = {col[5:4],2'b00};
          end 
          else begin// black
            vga_red_wr   = {4{1'b0}};
            vga_green_wr = {4{1'b0}};
            vga_blue_wr  = {4{1'b0}};
          end
        end
      end
      else begin // if (row >= 256) begin
        vga_red_wr   = col[7:4];
        vga_green_wr = col[5:2];
        vga_blue_wr  = row[5:2];
        if (row >= 384) begin
          vga_red_wr   = {4{1'b0}};
          vga_green_wr = {4{1'b0}};
          vga_blue_wr  = {4{1'b0}};
        end
      end
    end
  end

  // registering the combinational part, the part that comes from memory
  // is already registered, and registering it would lead to unsynchronization
  always @ (posedge rst, posedge clk)
  begin
    if (rst) begin
      vga_red_rg   <= {4{1'b0}};
      vga_green_rg <= {4{1'b0}};
      vga_blue_rg  <= {4{1'b0}};
    end
    else begin
      vga_red_rg   <= vga_red_wr;
      vga_green_rg <= vga_green_wr;
      vga_blue_rg  <= vga_blue_wr;
    end
  end



  // registering twice to have the outputs totally registered
  always @ (posedge rst, posedge clk)
  begin
    if (rst) begin
      vga_red   <= {4{1'b0}};
      vga_green <= {4{1'b0}};
      vga_blue  <= {4{1'b0}};
    end
    else begin
      vga_red   <= {4{1'b0}};
      vga_green <= {4{1'b0}};
      vga_blue  <= {4{1'b0}};
      if (visible) begin
        if ((col < c_img_cols) && (row < c_img_rows)) begin
          if (rgbmode) begin
            vga_red   <= frame_pixel[c_nb_buf-1: c_nb_buf-c_nb_buf_red];
            vga_green <= frame_pixel[c_nb_buf-c_nb_buf_red-1:c_nb_buf_blue];
            vga_blue  <= frame_pixel[c_nb_buf_blue-1:0];
          end
          else begin
            vga_red   <= frame_pixel[7:4];
            vga_green <= frame_pixel[7:4];
            vga_blue  <= frame_pixel[7:4];
          end
        end
        else begin
          vga_red   <= vga_red_rg;
          vga_green <= vga_green_rg;
          vga_blue  <= vga_blue_rg;
        end
      end
    end
  end


  // register twice
  always @ (posedge rst, posedge clk)
  begin
    if (rst) begin
      hsync_rg  <= ~c_synch_act;
      hsync_out <= ~c_synch_act;
      vsync_rg  <= ~c_synch_act;
      vsync_out <= ~c_synch_act;
    end
    else begin
      hsync_rg  <= hsync;
      hsync_out <= hsync_rg;
      vsync_rg  <= vsync;
      vsync_out <= vsync_rg;
    end
  end


endmodule
