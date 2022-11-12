
`default_nettype none
`timescale 1ns / 1ps

module tank_bitmap2
  (
    input [7:0] addr,
    output [7:0] bits
  );

  reg [15:0] bitarray[0:255];

  assign bits = (addr[0]) ? bitarray[addr>>1][15:8] : bitarray[addr>>1][7:0];

  initial
  begin/*{w:16,h:16,bpw:16,count:5}*/
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

module sprite_renderer3(
    input clk,
    input vstart,
    input load,
    input hstart,
    output reg [7:0] rom_addr,
    input [7:0] rom_bits,
    output reg gfx,
    output busy
  );

  assign busy = state != WAIT_FOR_VSTART;

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
  reg [2:0] state = WAIT_FOR_VSTART;

  always @(posedge clk)
  begin
    case (state)
      WAIT_FOR_VSTART:
      begin
        ycount <= 0;
        // set a default value (blank) for pixel output
        // note: multiple non-blocking assignments are vendor-specific
        gfx <= 0;
        if (vstart)
          state <= WAIT_FOR_LOAD;
      end
      WAIT_FOR_LOAD:
      begin
        xcount <= 0;
        gfx <= 0;
        if (load)
          state <= LOAD1_SETUP;
      end
      LOAD1_SETUP:
      begin
        rom_addr <= {ycount, 4'b0};
        state <= LOAD1_FETCH;
      end
      LOAD1_FETCH:
      begin
        outbits[7:0] <= rom_bits;
        state <= LOAD2_SETUP;
      end
      LOAD2_SETUP:
      begin
        rom_addr <= {ycount, 4'b1};
        state <= LOAD2_FETCH;
      end
      LOAD2_FETCH:
      begin
        outbits[15:8] <= rom_bits;
        state <= WAIT_FOR_HSTART;
      end
      WAIT_FOR_HSTART:
      begin
        if (hstart)
          state <= DRAW;
      end
      DRAW:
      begin
        // mirror graphics left/right
        gfx <= outbits[xcount[3:0]];
        xcount <= xcount + 1;
        if (xcount == 15)
        begin // pre-increment value
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

module etwas_anderes(
    input        rst,         // btn fire 1
    input clk25mhz,
    input  wire btn0,
    output wire oled_csn,
     output wire oled_clk,
     output wire oled_mosi,
     output wire oled_dc,
     output wire oled_resn
  );

  wire clk = clk25mhz;
  parameter C_color_bits = 8; // 8 or 16

  wire [6:0] x;
  wire [5:0] y;
  wire gfx;
  reg [15:0]   rgb;
  reg [2:0] r= {3{1'b0}};
  reg [2:0] g= {3{1'b0}};
  reg [1:0] b= {2{1'b0}};
  // wire [7:0] color = {r,g, b};

  wire [7:0] tank_sprite_addr;
  wire [7:0] tank_sprite_bits;
  wire next_pixel;
  wire oclk;

  // gen_pos ssd_clk(
  //           .clk(clk),
  //           .out_hcnt(x),
  //           .out_vcnt(y),
  //           .rst(rst)
  //         );

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
                     .busy(busy)
                   );
  always @(posedge clk)
  begin
    r <= (load)? gfx:4'b1101;
    g <= (load)? gfx:4'b1011;
    b <= (load)? gfx:4'b1111;
  end


   wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};
  // wire [15:0] color = {r,g, b};
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
  

endmodule
