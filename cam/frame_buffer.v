//------------------------------------------------------------------------------
//   Felipe Machado Sanchez
//   Area de Tecnologia Electronica
//   Universidad Rey Juan Carlos
//   https://github.com/felipe-m
//
//   frame_buffer.v
//   
//-----------------------------------------------------------------------------

module frame_buffer
  #(parameter
    // QVGA
    c_img_cols    = 80, // 9 bits
    // c_img_cols    = 320, // 9 bits
    c_img_rows    = 60, // 8 bits
    // c_img_rows    = 240, // 8 bits
    c_img_pxls    = c_img_cols * c_img_rows,
    c_nb_img_pxls =  13,  //320*240=76,800 -> 2^17
    c_nb_buf_red   =  5,  // n bits for red in the buffer (memory)
    c_nb_buf_green =  5,  // n bits for green in the buffer (memory)
    c_nb_buf_blue  =  6,  // n bits for blue in the buffer (memory)
    // word width of the memory (buffer)
    c_nb_buf       =   c_nb_buf_red + c_nb_buf_green + c_nb_buf_blue
  )
  (
   input                          clk,
   input                          wea,
   input      [c_nb_img_pxls-1:0] addra,
   input      [c_nb_buf-1:0]      dina,
   input      [c_nb_img_pxls-1:0] addrb,
   output reg [c_nb_buf-1:0]      doutb
   );

  reg  [c_nb_buf-1:0] ram[c_img_pxls-1:0];

  always @ (posedge clk)
  begin
    if (wea)
        ram[addra] <= dina;
    doutb <= ram[addrb];
  end

endmodule

