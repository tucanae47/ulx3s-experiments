/*
 based on hirosh vga sync 

  Copyright (C) 2021  Hirosh Dabui <hirosh@dabui.de>

  
*/

module gen_pos (
           input clk,
           output reg [6:0] x,
           output reg [6:0] y,
           input rst
       );

    localparam VTOTAL            = 128;	
    localparam HTOTAL            = 128;	

wire hcycle = x == (HTOTAL -1) || rst;
wire vcycle = y == (VTOTAL -1) || rst;
// testpattern

always @(posedge clk) begin
    if (rst) begin
        x <= 0;
        y <= 0;
    end else begin
            x <= hcycle ? 0 : x + 1;
            if (hcycle) y <= vcycle ? 0 : y + 1;

    end
end

endmodule
