//-----------------------------------------------------------------
//                         RISC-V Core
//                            V1.0
//                     Ultra-Embedded.com
//                     Copyright 2014-2019
//
//                   admin@ultra-embedded.com
//
//                       License: BSD
//-----------------------------------------------------------------
//
// Copyright (c) 2014-2019, Ultra-Embedded.com
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions 
// are met:
//   - Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   - Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer 
//     in the documentation and/or other materials provided with the 
//     distribution.
//   - Neither the name of the author nor the names of its contributors 
//     may be used to endorse or promote products derived from this 
//     software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR 
// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF 
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF 
// SUCH DAMAGE.
//-----------------------------------------------------------------
`timescale 1ns / 1ps
module riscv_decode
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
     parameter SUPPORT_MULDIV   = 1
    ,parameter EXTRA_DECODE_STAGE = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           fetch_in_valid_i
    ,input  [ 31:0]  fetch_in_instr_i  //inst
    ,input  [ 31:0]  fetch_in_pc_i    //pc
    ,input           fetch_in_fault_fetch_i   //kiem tra dk cuar inst dung kieu hay ko -> phai =0 
    ,input           fetch_in_fault_page_i    //kiem tra dk cuar page dung kieu hay ko ->1 trong 2 cai sai -> inst = 32'b0 -> phai =0
    ,input           fetch_in_instr_exec_i
    ,input           fetch_in_instr_lsu_i
    ,input           fetch_in_instr_branch_i
    ,input           fetch_in_instr_mul_i
    ,input           fetch_in_instr_div_i
    ,input           fetch_in_instr_csr_i
    ,input           fetch_in_instr_rd_valid_i
    ,input           fetch_in_instr_invalid_i
    ,input           fetch_out_accept_i  //fetch nay phai =1
    ,input           squash_decode_i   // phai = 0

    // Outputs
    ,output          fetch_in_accept_o
    ,output          fetch_out_valid_o
    ,output [ 31:0]  fetch_out_instr_o
    ,output [ 31:0]  fetch_out_pc_o
    ,output          fetch_out_fault_fetch_o
    ,output          fetch_out_fault_page_o
    ,output          fetch_out_instr_exec_o
    ,output          fetch_out_instr_lsu_o
    ,output          fetch_out_instr_branch_o
    ,output          fetch_out_instr_mul_o
    ,output          fetch_out_instr_div_o
    ,output          fetch_out_instr_csr_o
    ,output          fetch_out_instr_rd_valid_o
    ,output          fetch_out_instr_invalid_o
    ,output [ 4:0]  rsa
    ,output [ 4:0]  rsb
    ,output [ 4:0]  rd
    ,output [ 31:0] rsa_value
    ,output [ 31:0] rsb_value	
    ,output 	    write_enable
    ,output 	    exe
    ,output 	    lsu
    ,output	    e_decode
    ,output 	    l_decode
);



wire        enable_muldiv_w     = SUPPORT_MULDIV;

//-----------------------------------------------------------------
// Extra decode stage (to improve cycle time)
//-----------------------------------------------------------------
generate
if (EXTRA_DECODE_STAGE)
begin
    wire [31:0] fetch_in_instr_w = (fetch_in_fault_page_i | fetch_in_fault_fetch_i) ? 32'b0 : fetch_in_instr_i;
    reg [66:0]  buffer_q;

    always @(posedge clk_i or posedge rst_i)
    if (rst_i)
        buffer_q <= 67'b0;
    else if (squash_decode_i)
        buffer_q <= 67'b0;
    else if (fetch_out_accept_i || !fetch_out_valid_o)
        buffer_q <= {fetch_in_valid_i, fetch_in_fault_page_i, fetch_in_fault_fetch_i, fetch_in_instr_w, fetch_in_pc_i};

    assign {fetch_out_valid_o,
            fetch_out_fault_page_o,
            fetch_out_fault_fetch_o,
            fetch_out_instr_o,
            fetch_out_pc_o} = buffer_q;
    wire instr_exec;
    wire instr_lsu;
    riscv_decoder
    u_dec
    (
         .valid_i(fetch_out_valid_o)
        ,.fetch_fault_i(fetch_out_fault_page_o | fetch_out_fault_fetch_o)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_out_instr_o)

        ,.invalid_o(fetch_out_instr_invalid_o)
        ,.exec_o(instr_exec)
        ,.lsu_o(instr_lsu)
        ,.branch_o(fetch_out_instr_branch_o)
        ,.mul_o(fetch_out_instr_mul_o)
        ,.div_o(fetch_out_instr_div_o)
        ,.csr_o(fetch_out_instr_csr_o)
        ,.rd_valid_o(fetch_out_instr_rd_valid_o)
    );
  /*  riscv_GPRs_read
    regis_value
    (
	.clk(clk_i)
	,.reg_read_addr_1(rsa)
	,.reg_read_data_1(rsa_value)
	,.reg_read_addr_2(rsb)
	,.reg_read_data_2(rsb_value)  
	);*/

	assign fetch_out_instr_exec_o = instr_exec;
	assign fetch_out_instr_lsu_o = instr_lsu;
        assign exe			    = instr_exec;
    assign lsu			    = instr_lsu;
    assign fetch_in_accept_o        = fetch_out_accept_i;
end
//-----------------------------------------------------------------
// Straight through decode
//-----------------------------------------------------------------
else
begin
    wire [31:0] fetch_in_instr_w = (fetch_in_fault_page_i | fetch_in_fault_fetch_i) ? 32'b0 : fetch_in_instr_i;
    wire write_en;
    riscv_decoder
    u_dec
    (
         .valid_i(fetch_in_valid_i)
        ,.fetch_fault_i(fetch_in_fault_fetch_i | fetch_in_fault_page_i)
        ,.enable_muldiv_i(enable_muldiv_w)
        ,.opcode_i(fetch_out_instr_o)

        ,.invalid_o(fetch_out_instr_invalid_o)
        ,.exec_o(fetch_out_instr_exec_o)
        ,.lsu_o(fetch_out_instr_lsu_o)
        ,.branch_o(fetch_out_instr_branch_o)
        ,.mul_o(fetch_out_instr_mul_o)
        ,.div_o(fetch_out_instr_div_o)
        ,.csr_o(fetch_out_instr_csr_o)
        ,.rd_valid_o(fetch_out_instr_rd_valid_o)
	,.rsa(rsa)
	,.rsb(rsb)
	,.rd(rd)
	,.write_en(write_en)
	,.w_e_code(e_decode)
	,.w_l_code(l_decode)
    );
  /*  riscv_GPRs_read
    regis_value
    (
	.clk(clk_i)
	,.reg_read_addr_1(rsa)
	,.reg_read_data_1(rsa_value)
	,.reg_read_addr_2(rsb)
	,.reg_read_data_2(rsb_value)  
	);*/

    // Outputs
    assign fetch_out_valid_o        = fetch_in_valid_i;
    assign fetch_out_pc_o           = fetch_in_pc_i;
    assign fetch_out_instr_o        = fetch_in_instr_w;
    assign fetch_out_fault_page_o   = fetch_in_fault_page_i;
    assign fetch_out_fault_fetch_o  = fetch_in_fault_fetch_i;
    assign write_enable             = write_en;
    assign fetch_in_accept_o        = fetch_out_accept_i;
end
endgenerate


endmodule
