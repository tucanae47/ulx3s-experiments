//------------------------------------------------------------------------------
//   Felipe Machado Sanchez
//   Area de Tecnologia Electronica
//   Universidad Rey Juan Carlos
//   https://github.com/felipe-m
//
//   frame_buffer.v
//   
//-----------------------------------------------------------------------------

module frame_buff
  #(parameter
    // QVGA
    c_img_cols    = 128, // 9 bits
    // c_img_cols    = 320, // 9 bits
    c_img_rows    = 128, // 8 bits
    // c_img_rows    = 240, // 8 bits
    c_img_pxls    = c_img_cols * c_img_rows,
    c_nb_img_pxls =  14,  //320*240=76,800 -> 2^17
    c_nb_buf_red   =  4,  // n bits for red in the buffer (memory)
    c_nb_buf_green =  4,  // n bits for green in the buffer (memory)
    c_nb_buf_blue  =  4,  // n bits for blue in the buffer (memory)
    // word width of the memory (buffer)
    c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue
  )
  (
   input                          clk,
   input                          wea,
   input      [c_nb_img_pxls-1:0] addra,
   input      [c_nb_buf-1:0]      dina,
  input [6:0] row,          // 0 to 127 
  input [6:0] col,          // 0 to 127
  output reg [4:0] r,     // 4-bit x 3 BGR 
  output reg [4:0] g,     // 4-bit x 3 BGR 
  output reg [5:0] b,     // 4
   );

localparam c_red   =  4;  // n bits for red in the buffer (memory)
localparam c_green =  4;  // n bits for green in the buffer (memory)
localparam c_blue  =  4;
  wire [17:0] read_addr = 8'd80 * row + col;
  reg  [c_nb_buf-1:0] buffer[c_img_pxls-1:0];

  always @ (posedge clk)
  begin
    if (wea)
        buffer[addra] <= dina;
    r  <= {1'b0, buffer[read_addr][c_nb_buf-1: c_nb_buf-c_red]};
    g  <= {1'b0, buffer[read_addr][c_nb_buf-c_red-1:c_blue]};
    b  <= {2'b0, buffer[read_addr][c_blue-1:0]};

    // r  <= {buffer[read_addr][c_nb_buf-1: c_nb_buf-c_red]};
    // g  <= {buffer[read_addr][c_nb_buf-c_red-1:c_blue]};
    // b  <= {buffer[read_addr][c_blue-1:0]};
  end

endmodule

