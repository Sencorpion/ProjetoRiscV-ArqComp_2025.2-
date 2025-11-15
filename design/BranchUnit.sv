`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm,
    input logic Branch,
    input logic Jump,
    input logic JumpR,
    input logic [31:0] AluResult,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel
);

  logic Branch_Sel;
  logic [31:0] PC_Full;

  assign PC_Full = {23'b0, Cur_PC};

  assign PC_Imm = PC_Full + Imm;
  assign PC_Four = PC_Full + 32'b100;
  assign Branch_Sel = Branch && AluResult[0];  // 0:Branch is taken; 1:Branch is not taken

  assign BrPC = (Branch_Sel || Jump) ? PC_Imm : (JumpR) ? {AluResult[31:1], 1'b0} : 32'b0;  // Branch or Jump -> PC+Imm   // JALR -> PC + EVEN AluResult // Otherwise, BrPc is unimportant
  assign PcSel = Branch_Sel || Jump || JumpR;  // 1:branch is taken; 0:branch is not taken(choose pc+4)

endmodule
