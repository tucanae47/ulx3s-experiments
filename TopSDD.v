`timescale 1ns / 1ps
module TopSDD(
    input clk,
    input rst
    );

reg [7:0]    oled_x_dc;
reg [7:0]    oled_y_data;
reg [15:0]   oled_rgb;
reg          oled_strobe;
reg          oled_setpixel_raw8tx;
wire   oled_cs;
wire   oled_mosi;
wire   oled_sck;
wire   oled_dc;
wire   oled_rst;
wire   oled_vccen;
wire   oled_pmoden;
wire   oled_ready;
wire   oled_valid;

always @(*) begin
    oled_strobe          = 1'b1;
    oled_setpixel_raw8tx = 1'b0;
end


sdd1331_gen_pattern ssd_clk(
           .clk(clk),
           .out_hcnt(oled_x_dc),
           .out_vcnt(oled_y_data),
           .rgb(oled_rgb),
           .rst(rst)
       );

oled_ssd1331 oled_ssd1331_i(
                 .clk(clk),
                 .resetn(~rst),
                 .oled_rst(oled_rst),
                 .strobe(oled_strobe),
                 .setpixel_raw8tx(oled_setpixel_raw8tx),
                 .x_dc(oled_x_dc),
                 .y_data(oled_y_data),
                 .rgb(oled_rgb),
                 .ready(oled_ready),
                 .valid(oled_valid),
                 .spi_cs(oled_cs),
                 .spi_dc(oled_dc),
                 .spi_mosi(oled_mosi),
                 .spi_sck(oled_sck),
                 .vccen(oled_vccen),
                 .pmoden(oled_pmoden)
             );

    `ifdef COCOTB_SIM
    `ifndef SCANNED
    `define SCANNED
    initial begin
        $dumpfile ("wave.vcd");
        $dumpvars (0, TopSDD);
        #1;
    end
    `endif
    `endif
endmodule