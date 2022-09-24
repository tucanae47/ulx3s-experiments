module top_checkered
(
    input  wire clk_25mhz,
    input  wire [6:0] btn,
    output wire [7:0] led,
    output wire oled_csn,
    output wire oled_clk,
    output wire oled_mosi,
    output wire oled_dc,
    output wire oled_resn,
    output wire wifi_gpio0
);
    assign wifi_gpio0 = btn[0];
    parameter C_color_bits = 16; // 8 or 16

/*
    wire clk, locked;
    pll
    pll_inst
    (
        .clki(clk_25mhz),
        .clko(clk), // 12.5 MHz
        .locked(locked)
    );
*/
    wire clk = clk_25mhz;

    wire [6:0] x;
    wire [5:0] y;

    wire [15:0] color = x[3] ^ y[3] ? {5'd0, x[6:1], 5'd0} : {y[5:1], 6'd0, 5'd0};
    //localparam C_init_file = "oled_init_16bit.mem";
    // localparam C_init_file = "ssd1351_init_16bit.mem";
    localparam C_init_file = "ssd1351_oinit_xflip_16bit.mem";
    //localparam C_init_file = "oled_init_yflip_16bit.mem";
    //localparam C_init_file = "oled_init_xyflip_16bit.mem";

    oled_video
    #(
        .c_init_file(C_init_file),
        // .c_init_file("ssd1351_linit_16bit.mem"),
        .c_x_size(128),
        .c_y_size(128),
        .c_color_bits(C_color_bits)
    )
    oled_video_inst
    (
        .clk(clk),
        .reset(~btn[0]),
        .x(x),
        .y(y),
        .color(color),
        .spi_csn(oled_csn),
        .spi_clk(oled_clk),
        .spi_mosi(oled_mosi),
        .spi_dc(oled_dc),
        .spi_resn(oled_resn)
    );
/*
    oled_video
    #(
        .c_init_file(C_init_file),
        .c_x_size(128),
        .c_y_size(128),
        .c_color_bits(C_color_bits)
    )
    oled_video_inst
    (
        .clk(clk),
        .x(x),
        .y(y),
        .color(color),
        .spi_csn(oled_csn),
        .spi_clk(oled_clk),
        .spi_mosi(oled_mosi),
        .spi_dc(oled_dc),
        .spi_resn(oled_resn)
    );
*/
endmodule
