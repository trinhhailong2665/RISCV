`timescale 1ns/1ps
`include "DEFINE.v"
`include "Global.v"
// fpga4student.com 
// FPGA projects, VHDL projects, Verilog projects 
// Verilog code for RISC Processor 
// Verilog code for register file
module riscv_GPRs_write(
 input    clk,
 // write port
 input    reg_write_en,
 input  [4:0] reg_write_dest,
 input  [31:0] reg_write_data
 //read port 1  //doc phan tu th? 1
 /*input  [4:0] reg_read_addr_1,
 output  [31:0] reg_read_data_1,
 //read port 2 //doc phan tu th? 2
 input  [4:0] reg_read_addr_2,
 output  [31:0] reg_read_data_2*/
);
 reg [31:0] reg_array [31:0];
 //reg [31:0] reg_data_w;
 integer i;
 integer fw;
 // write port
 //reg [2:0] i;
always @ (posedge clk or posedge ~clk) begin
   /*reg_array[i] <= 32'd0;*/
	
	$readmemb("E:/Riscv/riscv_ct_final/riscv_ct/register_data.data", reg_array);

/*for(i=0; i<=31; i=i+1)
	$fscanf(fw, "%d\n", reg_array[i]); 
$fclose(fw);*/
 end
 always @ (posedge clk) begin
	
   if(reg_write_en) begin
    reg_array[reg_write_dest] <= reg_write_data;
	fw = $fopen("E:/Riscv/riscv_ct_final/riscv_ct/register_data.data", "w");
	for (i = 0; i <= 31; i = i+1)
	begin
		if (i == reg_write_dest)
			$fwriteb(fw,reg_write_data,"\n");
		else
		  $fwriteb(fw,reg_array[i],"\n");
	end
	
  $fclose(fw);
   end
 end
 

/* assign reg_read_data_1 = reg_array[reg_read_addr_1];
 assign reg_read_data_2 = reg_array[reg_read_addr_2*/
endmodule