`include "DEFINE.v"
`include "riscv_defs.v"

module Instruction(
     input   [31:0]   pc,
     output  [31:0]   instruction
    ,output 	      fetch_in_valid_o
    ,output  [ 31:0]  fetch_in_pc_o    //pc
    ,output           fetch_in_fault_fetch_o   
    ,output           fetch_in_fault_page_o   
    ,output           fetch_in_instr_exec_o
    ,output           fetch_in_instr_lsu_o
    ,output           fetch_in_instr_branch_o
    ,output           fetch_in_instr_mul_o
    ,output           fetch_in_instr_div_o
    ,output           fetch_in_instr_csr_o
    ,output           fetch_in_instr_rd_valid_o
    ,output           fetch_in_instr_invalid_o  // 0
    ,output           fetch_out_accept_o 
    ,output           squash_decode_o  
);

 reg [`col - 1:0] memory [`row_i - 1:0];
 wire [31 : 0] rom_addr = pc[31 : 0]/4;
 initial
 begin
	$readmemb(`inst_mem, memory);
 end
 assign instruction =  memory[rom_addr];
 assign fetch_in_valid_o = 1'b1; 
 assign fetch_in_pc_o = pc;
 assign fetch_in_fault_fetch_o = 1'b0;
 assign fetch_in_fault_page_o = 1'b0;
 reg exec;
 reg branch;
always @ *
begin
    exec = 1'b0;	
    branch = 1'b0;
    if ((instruction & `INST_ADD_MASK) == `INST_ADD) // add
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_AND_MASK) == `INST_AND) // and
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_OR_MASK) == `INST_OR) // or
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SLL_MASK) == `INST_SLL) // sll
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SRA_MASK) == `INST_SRA) // sra
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SRL_MASK) == `INST_SRL) // srl
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SUB_MASK) == `INST_SUB) // sub
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_XOR_MASK) == `INST_XOR) // xor
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SLT_MASK) == `INST_SLT) // slt
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SLTU_MASK) == `INST_SLTU) // sltu
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_ADDI_MASK) == `INST_ADDI) // addi
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_ANDI_MASK) == `INST_ANDI) // andi
    begin
        exec = 1'b1;
    end
    else if ((instruction & `INST_SLTI_MASK) == `INST_SLTI) // slti
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_SLTIU_MASK) == `INST_SLTIU) // sltiu
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_ORI_MASK) == `INST_ORI) // ori
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_XORI_MASK) == `INST_XORI) // xori
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_SLLI_MASK) == `INST_SLLI) // slli
    begin
      exec = 1'b1;
    end
    else if ((instruction & `INST_SRLI_MASK) == `INST_SRLI) // srli
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_SRAI_MASK) == `INST_SRAI) // srai
    begin
      exec = 1'b1;
    end
    else if ((instruction & `INST_LUI_MASK) == `INST_LUI) // lui
    begin
       exec = 1'b1;
    end
    else if ((instruction & `INST_AUIPC_MASK) == `INST_AUIPC) // auipc
    begin
       exec = 1'b1;
    end     
    else if (((instruction & `INST_JAL_MASK) == `INST_JAL) || ((instruction & `INST_JALR_MASK) == `INST_JALR)) // jal, jalr
    begin
       exec = 1'b1;
	branch = 1'b1;
    end
    if ((instruction & `INST_JAL_MASK) == `INST_JAL) // jal
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_JALR_MASK) == `INST_JALR) // jalr
    begin
       exec = 1'b1;
	branch = 1'b1;
    end
    //tiep theo may cai nay target = pc+imm mac dinh o tren 
    else if ((instruction & `INST_BEQ_MASK) == `INST_BEQ) // beq
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_BNE_MASK) == `INST_BNE) // bne
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_BLT_MASK) == `INST_BLT) // blt <
    begin
       exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_BGE_MASK) == `INST_BGE) // bge >=
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_BLTU_MASK) == `INST_BLTU) // bltu
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
    else if ((instruction & `INST_BGEU_MASK) == `INST_BGEU) // bgeu
    begin
        exec = 1'b1;
	branch = 1'b1;
    end
	
	end
	assign fetch_in_instr_exec_o = exec;
	assign fetch_in_instr_branch_o = branch;
	assign fetch_in_instr_lsu_o = (((instruction & `INST_LB_MASK) == `INST_LB)  || 
                    ((instruction & `INST_LH_MASK) == `INST_LH)  || 
                    ((instruction & `INST_LW_MASK) == `INST_LW)  || 
                    ((instruction & `INST_LBU_MASK) == `INST_LBU) || 
                    ((instruction & `INST_LHU_MASK) == `INST_LHU) || 
                    ((instruction & `INST_LWU_MASK) == `INST_LWU));
	assign fetch_in_instr_lsu_o = (((instruction & `INST_SB_MASK) == `INST_SB)  || 
                     ((instruction & `INST_SH_MASK) == `INST_SH)  || 
                     ((instruction & `INST_SW_MASK) == `INST_SW));
	assign fetch_in_instr_div_o= ((instruction & `INST_DIV_MASK) == `INST_DIV)  || 
                          ((instruction & `INST_DIVU_MASK) == `INST_DIVU) ||
                          ((instruction & `INST_REM_MASK) == `INST_REM)  ||
                          ((instruction & `INST_REMU_MASK) == `INST_REMU);
	assign fetch_in_instr_mul_o = ((instruction & `INST_MUL_MASK) == `INST_MUL)        || 
                      ((instruction & `INST_MULH_MASK) == `INST_MULH)      ||
                      ((instruction & `INST_MULHSU_MASK) == `INST_MULHSU)  ||
                      ((instruction & `INST_MULHU_MASK) == `INST_MULHU);
	assign fetch_in_instr_csr_o = 1'b0;
	assign fetch_in_instr_rd_valid_o = 1'b1;
	assign fetch_in_instr_invalid_o = 1'b0;
	assign fetch_out_accept_o = 1'b1;
	assign squash_decode_o = 1'b0;
endmodule