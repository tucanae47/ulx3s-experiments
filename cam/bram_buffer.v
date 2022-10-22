/* 
    author : @tucanae47 mod from @mkvenkit
    modifed from https://github.com/mkvenkit/learn_fpga
    bram_buffer.v

    This module implements a 128 x 128 x 16-bit buffer using BRAM.

*/

`default_nettype none

module bram_buffer (
  input clk,
  input reset,
  input [6:0] row,          // 0 to 127 
  input [6:0] col,          // 0 to 127
  input oe,                 // output enable
  output reg [4:0] r,     // 4-bit x 3 BGR 
  output reg [4:0] g,     // 4-bit x 3 BGR 
  output reg [5:0] b,     // 4-bit x 3 BGR 
);
localparam c_red   =  4;  // n bits for red in the buffer (memory)
localparam c_green =  4;  // n bits for green in the buffer (memory)
localparam c_blue  =  4;

localparam c_nb_buf = c_red + c_green + c_blue;
// declare a reg from which 
// block RAM will be inferred 
// 128 * 128 * 12-bit = 196608
parameter SZ = 128 * 128;
reg [11:0] buffer[SZ];

// initialize RAM 
initial begin 
    $readmemh("img.mem", buffer); 
end
// compute read address 

wire [17:0] read_addr = 8'd128 * row + col;

// define read access 
always @ (posedge clk) begin
    if (oe) begin
        r  <= {1'b0, buffer[read_addr][c_nb_buf-1: c_nb_buf-c_red]};
        g  <= {1'b0, buffer[read_addr][c_nb_buf-c_red-1:c_blue]};
        b  <= {2'b0, buffer[read_addr][c_blue-1:0]};
    end
end

endmodule
