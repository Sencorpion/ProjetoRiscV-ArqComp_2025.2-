`timescale 1ns / 1ps

/*
* BRANCH UNIT
* Description: Responsible for calculating target addresses for branches and
*              jumps, and for determining when the Program Counter (PC) should
*              deviate from its sequential increment (PC + 4). It generates
*              the PCSel signal to control the PC mux in the Datapath.
*/

module BranchUnit #(

    // PARAMETERS
    // PC_W: Defines the bit-width of the PC.
    //
    // OBS: In this design, it's 9 bits, implying a PC range of 0 to 511.
    parameter PC_W = 9
) (

    // INPUTS
    // Cur_PC: The current PC value (from the IF/ID stage).
    //         Used as a base for calculating deviation targets.
    input logic [PC_W-1:0] Cur_PC,

    // Imm: The sign-extended immediate value from the current instruction.
    //      Used for calculating deviation targets.
    input logic [31:0] Imm,

    // Branch: Control signal from the Controller. Asserted if the instruction
    //         is a conditional branch type.
    input logic Branch,

    // Jump: Control signal from the Controller. Asserted for a JAL instruction.
    input logic Jump,

    // JumpR: Control signal from the Controller. Asserted for a JALR
    //        instruction.
    input logic JumpR,

    // AluResult: The result from the ALU. For branch instructions,
    //            AluResult[0] indicates if the branch condition is met (1 for
    //            true). For JALR, this is the rs1 + imm result.
    input logic [31:0] AluResult,

    // OUTPUTS
    // PC_Imm: The calculated target address for branches and jumps. (PC + imm)
    output logic [31:0] PC_Imm,

    // PC_Four: The address of the next sequential instruction (PC + 4).
    //          Also used for the "link" part of JAL and JALR.
    output logic [31:0] PC_Four,

    // BrPC: The final selected target address for the PC mux.
    //       Will be either PC + Imm (for branches and JAL), PC + AluResult
    //       (for JALR), or 0 if no deviation is taken.
    output logic [31:0] BrPC,

    // PcSel: The main control signal for the PC mux in the Datapath.
    output logic PcSel
);

  // Intermediate signal indicating if a conditional branch is taken.
  logic Branch_Sel;

  // The 32-bit representation of the current PC. The input Cur_PC is PC_W
  // bits, so it's zero extended to 32 bits for arithmetic operations.
  logic [31:0] PC_Full;
  assign PC_Full = {23'b0, Cur_PC};

  // Calculates target address for JAL and branches
  assign PC_Imm = PC_Full + Imm;

  // Calculates the address of the next sequential instruction (Used for the
  // linking part of the Jump and Link instructions (saving the return address)) 
  assign PC_Four = PC_Full + 32'b100;

  // Determines if the conditional branch is taken.
  // Asserted by both the Controller and the ALU comparison.
  assign Branch_Sel = Branch && AluResult[0];  // 0:Branch is taken; 1:Branch is not taken

  // Determines the next PC value.
  // 1. If a branch is taken of the instruction is JAL, the target is PC + Imm.
  // 2. Else if it's a JALR function, the target is PC + rs1 + Imm.
  // 3. Else, no deviation is taken.
  assign BrPC = (Branch_Sel || Jump) ? PC_Imm : (JumpR) ? {AluResult[31:1], 1'b0} : 32'b0;  // Branch or Jump -> PC+Imm   // JALR -> PC + EVEN AluResult // Otherwise, BrPc is unimportant

  // Determines if the PC should deviate from sequential execution (meaning,
  // if a deviation instruction is taken).
  assign PcSel = Branch_Sel || Jump || JumpR;  // 1:branch is taken; 0:branch is not taken (choose pc+4)

endmodule
