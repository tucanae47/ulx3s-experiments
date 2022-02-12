/*
 based on hirosh vga sync 

  Copyright (C) 2021  Hirosh Dabui <hirosh@dabui.de>

  
*/

module sdd1331_gen_pattern (
           input clk,
           output reg [8:0] out_hcnt,
           output reg [8:0] out_vcnt,
           output reg [15:0] rgb,
           input rst
       );

    localparam VTOTAL            = 96;	
    localparam HTOTAL            = 64;	

wire hcycle = out_hcnt == (HTOTAL -1) || rst;
wire vcycle = out_vcnt == (VTOTAL -1) || rst;
// testpattern
wire r = ((out_hcnt&7)==0) || ((out_vcnt&7)==0);
wire g = out_hcnt[4];
wire b = out_vcnt[4];

always @(posedge clk) begin
    rgb <= {b,g,r};
    if (rst) begin
        out_hcnt <= 0;
        out_vcnt <= 0;
    end else begin
            out_hcnt <= hcycle ? 0 : out_hcnt + 1;
            if (hcycle) out_vcnt <= vcycle ? 0 : out_vcnt + 1;

    end
end

endmodule
