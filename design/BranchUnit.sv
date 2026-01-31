`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm,
    input logic Branch,
    input logic Jump,
    input logic JumpR,
    input logic Halt,
    input logic [31:0] AluResult,
    output logic [31:0] PCplusImm,
    output logic [31:0] PCplusFour,
    output logic [31:0] BrPC,
    output logic PcSel
);

  logic Branch_Sel;
  logic [31:0] PC_Extended;

  assign PC_Extended = {23'b0, Cur_PC};

  assign PCplusImm = PC_Extended + Imm;
  assign PCplusFour = PC_Extended + 32'b100;

  assign Branch_Sel = Branch && AluResult[0];  // 0:Conditional Branch is not taken; 1:Conditional Branch is taken.

  assign BrPC = (Halt) ? PC_Extended : (Branch_Sel || Jump) ? PCplusImm : (JumpR) ? {AluResult[31:1], 1'b0} : 32'b0;  
  // Branch or Jump -> PC + Imm
  // JALR -> RD1 value + Imm
  // Halt -> PC

  assign PcSel = Branch_Sel || Jump || JumpR || Halt;  // 0:Senquential PC (PC + 4); 1:Swerve from sequential flow.

endmodule
