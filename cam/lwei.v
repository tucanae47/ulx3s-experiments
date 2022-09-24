`default_nettype none
`timescale 1ns / 1ps

`define ARRAY_SIZE 3
`define CHANNEL 4
`define INPUT_SIZE 16
`define KERNEL_SIZE 2
module lwei #(
    parameter   [31:0]  BASE_ADDRESS    = 32'h3000_0000        // base address
  )(

    input wire          clk,       // clock, runs at system clock
    input wire          rst,       // main system rst
    input wire          wb_stb_i,       // write strobe
    input wire          wb_cyc_i,       // cycle
    input wire          wb_we_i,        // write enable
    input wire  [3:0]   wb_sel_i,       // write word select
    input wire  [31:0]  wb_dat_i,       // data in
    input wire  [31:0]  wb_adr_i,       // address
    output reg          wb_ack_o,       // ack
    output reg  [31:0]  wb_dat_o,       // data out
    output reg [96:0] weights
  );

  reg [3:0] i;
  reg en;
  // CaravelBus reads

  always @(posedge clk)
  begin
    if(rst)
    begin
      en <=0;
      i<=0;
    end
    else
    begin
      // return ack
      wb_ack_o <= (wb_stb_i && wb_adr_i == BASE_ADDRESS);
      // FSM for systolic array
      if(i < 4 && wb_stb_i && wb_cyc_i && wb_we_i && wb_ack_o && wb_adr_i == BASE_ADDRESS)
      begin
        weights [(i*32)+:32] <= wb_dat_i;
        i <= i + 1;
      end
    end
  end
endmodule

