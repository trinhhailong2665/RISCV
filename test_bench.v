`timescale 1ns/1ps


module test_bench (
	
);
localparam period = 20;
	reg 	       CLOCK_50;
	reg 	       rst;
	reg [31:0]     data_write;
	wire           mem_write_en;
	wire           mem_read;
	wire  [4:0]    rsa;
	wire  [4:0]    rsb;
	wire  [4:0]    rsd;
	wire  [31:0]   value_rsa;
	wire  [31:0]   value_rsb;
	reg            hold;
	wire  [31:0]   pc_out;
	wire  [31:0]   data_read;
	wire  [31:0]   inst;
	//fetch
	reg   [31:0]   pc_in;
	wire 	       fetch_in_valid_i;
    	wire  [ 31:0]  fetch_in_instr_i;  //inst
    	wire  [ 31:0]  fetch_in_pc_i;    //pc
    	wire           fetch_in_fault_fetch_i;  //kiem tra dk cuar inst dung kieu hay ko -> phai =0 ;
    	wire           fetch_in_fault_page_i ;   //kiem tra dk cuar page dung kieu hay ko ->1 trong 2 cai sai -> inst = 32'b0 -> phai =0
    	wire           fetch_in_instr_exec_i;
    	wire           fetch_in_instr_lsu_i;
    	wire           fetch_in_instr_branch_i;
    	wire           fetch_in_instr_mul_i;
    	wire           fetch_in_instr_div_i;
    	wire           fetch_in_instr_csr_i;
    	wire           fetch_in_instr_rd_valid_i;
    	wire           fetch_in_instr_invalid_i;
    	wire           fetch_out_accept_i;  //fetch nay phai =1
    	wire           squash_decode_i ;  // phai = 0
	//decode
	wire          fetch_in_accept_i;
    	wire          fetch_out_valid_i;
    	wire [ 31:0]  fetch_out_instr_i;
    	wire [ 31:0]  fetch_out_pc_i;
    	wire          fetch_out_fault_fetch_i;
    	wire          fetch_out_fault_page_i;
    	wire          fetch_out_instr_exec_i;
    	wire          fetch_out_instr_lsu_i;
    	wire          fetch_out_instr_branch_i;
    	wire          fetch_out_instr_mul_i;
    	wire          fetch_out_instr_div_i;
    	wire          fetch_out_instr_csr_i;
    	wire          fetch_out_instr_rd_valid_i;
    	wire          fetch_out_instr_invalid_i;
	wire [31:0]   reg1;
	wire [31:0]   reg2;
	wire          branch_request_o;
	wire 	      branch_is_taken_o;
	wire          branch_is_not_taken_o;
	wire [ 31:0]  branch_source_o;
    	wire          branch_is_call_o;
    	wire          branch_is_ret_o;
    	wire          branch_is_jmp_o;
    	wire [ 31:0]  branch_pc_o;
    	wire          branch_d_request_o;
    	wire [ 31:0]  branch_d_pc_o;
    	wire [  1:0]  branch_d_priv_o;
   	wire [ 31:0]  writeback_value_o;
	wire [ 31:0]  mem_addr_o;  
        wire [ 31:0]  mem_data_wr_o;  //viet vao
        wire          mem_rd_o;
    	wire [  3:0]  mem_wr_o;
    	wire          mem_cacheable_o;
    	wire [ 10:0]  mem_req_tag_o;
    	wire          mem_invalidate_o;
    	wire          mem_writeback_o;
    	wire          mem_flush_o;
    	wire          writeback_valid_o;
    	wire [ 31:0]  writeback_value_data_o;  //lay ra
    	wire [  5:0]  writeback_exception_o;
    	wire          stall_o;
    	wire	      write_en;
	wire	      write_ena;
	wire	      write_exe;
	wire	      exe;
	wire          lsu1;
	wire          e_decode;
	wire	      l_decode;
	reg [31:0] reg_array [31:0];
	// 50MHz
	initial begin
		CLOCK_50 = 1'b0;
		forever #10 begin
			CLOCK_50 = ~CLOCK_50;
			$readmemb("E:/Riscv/riscv_ct_final/riscv_ct/register_data.data", reg_array);
	end
	end

	initial begin
		rst = 1'b1;
		#1000 rst = 1'b0;
		//#2000 $stop;
	end
	initial begin
		pc_in <= 32'b0;
		forever #40 begin
		pc_in <= branch_pc_o;
		if (pc_in == 32'h28)
			pc_in <= 32'b0;
		end
		//branch_d_pc_o = 32'b0;
	end
	


	Instruction
	Ins_mem(
	
			
		.pc(pc_in)
		,.instruction(inst)
		,.fetch_in_valid_o(fetch_in_valid_i)
		,.fetch_in_pc_o(fetch_in_pc_i)
		,.fetch_in_fault_fetch_o(fetch_in_fault_fetch_i)
		,.fetch_in_fault_page_o(fetch_in_fault_page_i)
		,.fetch_in_instr_exec_o(fetch_in_instr_exec_i)
		,.fetch_in_instr_lsu_o(fetch_in_instr_lsu_i)
		,.fetch_in_instr_branch_o(fetch_in_instr_branch_i)
		,.fetch_in_instr_mul_o(fetch_in_instr_mul_i)
		,.fetch_in_instr_div_o(fetch_in_instr_div_i)
		,.fetch_in_instr_csr_o(fetch_in_instr_csr_i)
		,.fetch_in_instr_rd_valid_o(fetch_in_instr_rd_valid_i)
		,.fetch_in_instr_invalid_o(fetch_in_instr_invalid_i)
		,.fetch_out_accept_o(fetch_out_accept_i)
		,.squash_decode_o(squash_decode_i)
	);
		
	//decode
	riscv_decode
	decode(
	
		.clk_i(CLOCK_50)
		,.rst_i(rst)
		,.fetch_in_valid_i(fetch_in_valid_i)
    		,.fetch_in_instr_i(inst)  //inst
    		,.fetch_in_pc_i(fetch_in_pc_i)    //pc
    		,.fetch_in_fault_fetch_i(fetch_in_fault_fetch_i)   //kiem tra dk cuar inst dung kieu hay ko -> phai =0 
    		,.fetch_in_fault_page_i(fetch_in_fault_page_i)    //kiem tra dk cuar page dung kieu hay ko ->1 trong 2 cai sai -> inst = 32'b0 -> phai =0
    		,.fetch_in_instr_exec_i(fetch_in_instr_exec_i)
    		,.fetch_in_instr_lsu_i(fetch_in_instr_lsu_i)
    		,.fetch_in_instr_branch_i(fetch_in_instr_branch_i)
    		,.fetch_in_instr_mul_i(fetch_in_instr_mul_i)
    		,.fetch_in_instr_div_i(fetch_in_instr_div_i)
    		,.fetch_in_instr_csr_i(fetch_in_instr_csr_i)
    		,.fetch_in_instr_rd_valid_i(fetch_in_instr_rd_valid_i)
    		,.fetch_in_instr_invalid_i(fetch_in_instr_invalid_i)
    		,.fetch_out_accept_i(fetch_out_accept_i)  //fetch nay phai =1
    		,.squash_decode_i(squash_decode_i)   // phai = 0

		//output
		,.fetch_in_accept_o(fetch_in_accept_i)
    		,.fetch_out_valid_o(fetch_out_valid_i)
    		,.fetch_out_instr_o(fetch_out_instr_i)
    		,.fetch_out_pc_o(fetch_out_pc_i)
    		,.fetch_out_fault_fetch_o(fetch_out_fault_fetch_i)
    		,.fetch_out_fault_page_o(fetch_out_fault_page_i)
    		,.fetch_out_instr_exec_o(fetch_out_instr_exec_i)
    		,.fetch_out_instr_lsu_o(fetch_out_instr_lsu_i)
    		,.fetch_out_instr_branch_o(fetch_out_instr_branch_i)
    		,.fetch_out_instr_mul_o(fetch_out_instr_branch_i)
    		,.fetch_out_instr_div_o(fetch_out_instr_div_i)
    		,.fetch_out_instr_csr_o(fetch_out_instr_csr_i)
    		,.fetch_out_instr_rd_valid_o(fetch_out_instr_rd_valid_i)
    		,.fetch_out_instr_invalid_o(fetch_out_instr_invalid_i)
		,.rsa(rsa)
		,.rsb(rsb)
		,.rd(rsd)
		,.write_enable(write_en)	
		//,.rsa_value(value_rsa)
		//,.rsb_value(value_rsb)	
		,.exe(exe)
		,.lsu(lsu1)
		,.e_decode(e_decode)
		,.l_decode(l_decode)
		);
		riscv_GPRs_read
   		 regis_value
    		(
			.clk(CLOCK_50)
			,.reg_read_addr_1(rsa)
			,.reg_read_data_1(value_rsa)
			,.reg_read_addr_2(rsb)
			,.reg_read_data_2(value_rsb)  
		);
	riscv_exec 
	ex (
	
		.clk_i(CLOCK_50)
		,.rst_i(rst)
		,.opcode_valid_i(fetch_in_valid_i)
		,.opcode_opcode_i(fetch_out_instr_i)
		,.opcode_pc_i(fetch_out_pc_i)
		,.opcode_invalid_i(fetch_out_instr_lsu_i)
		,.opcode_rd_idx_i(rsd)
		,.opcode_ra_idx_i(rsa)
		,.opcode_rb_idx_i(rsb)
		,.opcode_ra_operand_i(reg_array[rsa])
		,.opcode_rb_operand_i(reg_array[rsb])
		,.hold_i(fetch_out_instr_invalid_i)  //=0
		,.write_en(write_en)
		,.branch_request_o(branch_request_o)
		,.branch_is_taken_o(branch_is_taken_o)
		,.branch_is_not_taken_o(branch_is_not_taken_o)
		,.branch_source_o(branch_source_o)
		,.branch_is_call_o(branch_is_call_o)
		,.branch_is_ret_o(branch_is_ret_o)
		,.branch_is_jmp_o(branch_is_jmp_o)
		,.branch_pc_o(branch_pc_o)     //dia chi lenh tiep theo
		,.branch_d_request_o(branch_d_request_o)
		,.branch_d_pc_o(branch_d_pc_o)  //dia chi tieptheo
		,.branch_d_priv_o(branch_d_priv_o)
		,.writeback_value_o(writeback_value_o)
		,.mem_write_o(write_exe)
		
	);
	

	//lsu
	riscv_lsu
	lsu (
	
		// Inputs
     		.clk_i(CLOCK_50)
    		,.rst_i(rst)
    		,.opcode_valid_i(fetch_out_instr_lsu_i)
    		,.opcode_opcode_i(inst)
    		,.opcode_pc_i(branch_pc_o)
    		,.opcode_invalid_i(fetch_out_instr_exec_i)
    		,.opcode_rd_idx_i(rsd)
		,.opcode_ra_idx_i(rsa)
		,.opcode_rb_idx_i(rsb)
		,.opcode_ra_operand_i(reg_array[rsa])
		,.opcode_rb_operand_i(reg_array[rsb])
    		,.mem_data_rd_i(32'b0)  // rd chua d√ata tu mem
    		,.mem_accept_i(fetch_out_instr_lsu_i)
    		,.mem_ack_i(1'b0)
    		,.mem_error_i(1'b0)
    		,.mem_resp_tag_i(11'b11111111111)
    		,.mem_load_fault_i(1'b0)
    		,.mem_store_fault_i(1'b0)

    // Outputs
    		,.mem_addr_o(mem_addr_o)
    		,.mem_data_wr_o(mem_data_wr_o)  //viet vao
    		,.mem_rd_o(mem_rd_o)
    		,.mem_wr_o(mem_wr_o)
    		,.mem_cacheable_o(mem_cacheable_o)
    		,.mem_req_tag_o(mem_req_tag_o)
    		,.mem_invalidate_o(mem_invalidate_o)
    		,.mem_writeback_o(mem_writeback_o)
    		,.mem_flush_o(mem_flush_o)
    		,.writeback_valid_o(writeback_valid_o)
    		,.writeback_value_o(writeback_value_data_o)  //lay ra
    		,.writeback_exception_o(writeback_exception_o)
    		,.stall_o(stall_o)
		,.write_ena(write_ena)
	);
		reg [31:0] temp;
		reg 	   write_temp;
		always @ *
		if (fetch_out_instr_exec_i)
		begin
			temp <= writeback_value_o;
			write_temp <= e_decode;
		end
		else if (fetch_out_instr_lsu_i) begin
			temp <= writeback_value_data_o;
			write_temp <= l_decode;
		end
		riscv_GPRs_write
		write_resexe
		(
			.clk(CLOCK_50)
			,.reg_write_en(write_temp)
			,.reg_write_dest(rsd)
			,.reg_write_data(temp)
		);
		
	
endmodule // test_bench