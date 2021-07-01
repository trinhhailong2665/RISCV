`timescale 1ns/1ps
`include "DEFINE.v"
module riscv_GPRs_read(
 input    clk,
 // write port

 //read port 1  //doc phan tu th? 1
 input  [4:0] reg_read_addr_1,
 output  [31:0] reg_read_data_1,
 //read port 2 //doc phan tu th? 2
 input  [4:0] reg_read_addr_2,
 output  [31:0] reg_read_data_2
);
// reg [31:0] reg_array [31:0];
 integer i;
 integer fb;
 

endmodule