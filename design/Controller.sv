`timescale 1ns / 1ps

/*
* MAIN CONTROL UNIT
* Description: Takes 7-bit opcode from current instruction and generates all
*              of the primary control signals required by other components in
*              the datapath.
*/

module Controller (
    // INPUTS
    // Opcode: The 7-bit opcode (bits [6:0]) from the current instruction.
    //         This is the primary input that decides the behavior of the CPU.
    input logic [6:0] Opcode,

    // OUTPUTS
    // ALUSrc: Selects the second operand of the CPU.
    //         - 0: The second operand is from the register file (Read Data 2).
    //              Used for R-Type instructions.
    //         - 1: The second operand is the sign-extended immediate value.
    //              Used for I-Type, S-Type, J-type... instructions.
    output logic ALUSrc,

    // MemtoReg: Selects the data source to be written back to the register
    //           file.
    //           - 2'b00: Write the result from the ALU (R-Type, I-Type arithmetic).
    //           - 2'b01: Write the data read from memory (Load instructions).
    //           - 2'b10: Write the PC + 4 value (J-type, JALR).
    output logic [1:0] MemtoReg,

    // RegWrite: Enables writing to the register file.
    //           Asserted for any instruction that writes to a register.
    output logic RegWrite,

    // MemRead: Enables reading from the data memory. Only for Load instructions
    output logic MemRead,

    // MemWrite: Enables writing to the data memory. Onlly for Store instructions.
    output logic MemWrite,

    // ALUOp: 2-bit code sent to the ALUController to specify the category of
    //        the ALU operation.
    //        - 2'b00: For Load/Store address calculation (performs ADD).
    //        - 2'b01: For branch comparisons.
    //        - 2'b10: For REGISTER TYPE instructions.
    //        - 2'b11: For IMMEDIATE TYPE instructions.
    output logic [1:0] ALUOp,

    // Branch: Asserted for Branch instructions.
    output logic Branch,

    // Jump: Asserted for JAL instruction.
    output logic Jump,

    // JumpR: Asserted for JALR instruction.
    output logic JumpR
);

  // Local wires are used to make the code readable (names to binary codes).
  logic [6:0] R_TYPE, LW, SW, BR, IMM, JAL, JALR;

  assign R_TYPE = 7'b0110011;  // For R-Type instructions.
  assign LW = 7'b0000011;      // For Load instructions.
  assign SW = 7'b0100011;      // For Store instructions.
  assign BR = 7'b1100011;      // For Branch instructions;
  assign IMM = 7'b0010011;     // For I-type arithmetic instructions.
  assign JAL = 7'b1101111;     // For JAL.
  assign JALR = 7'b1100111;    // For JALR.

  assign ALUSrc = (Opcode == LW || Opcode == SW || Opcode == IMM || Opcode == JALR);

  assign MemtoReg = (Opcode == LW) ? 2'b01 : (Opcode == JAL || Opcode == JALR) ? 2'b10 : 2'b00;

  assign RegWrite = (Opcode == R_TYPE || Opcode == LW || Opcode == IMM || Opcode == JAL || Opcode == JALR);

  assign MemRead = (Opcode == LW);

  assign MemWrite = (Opcode == SW);

  assign ALUOp[0] = (Opcode == BR || Opcode == IMM || Opcode == JALR);
  assign ALUOp[1] = (Opcode == R_TYPE || Opcode == IMM || Opcode == JALR);

  assign Branch = (Opcode == BR);
  assign Jump = (Opcode == JAL);
  assign JumpR = (Opcode == JALR);
endmodule
