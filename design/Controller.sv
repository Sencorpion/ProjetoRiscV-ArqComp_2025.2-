`timescale 1ns / 1ps

module Controller (
    //Input
    input logic [6:0] Opcode,
    //7-bit opcode field from the instruction

    //Outputs
    output logic ALUSrc,
    //0: The second ALU operand comes from the second register file output (Read data 2); 
    //1: The second ALU operand is the sign-extended, lower 16 bits of the instruction.
    output logic [1:0] MemtoReg,
    //00: The value fed to the register Write data input comes from the ALU.
    //01: The value fed to the register Write data input comes from the data memory.
    //10: The value fed to the register Write data input comes from the Program Counter (plus 4)
    output logic RegWrite,      // The register on the Write register input is written with the value on the Write data input
    output logic MemRead,       // Data memory contents designated by the address input are put on the Read data output
    output logic MemWrite,      // Data memory contents designated by the address input are replaced by the value on the Write data input.
    output logic [1:0] ALUOp,   // 00: LW/SW; 01:Branch; 10: Rtype; 11 Itype
    output logic Branch,        // 0: branch is not taken; 1: branch is taken
    output logic Jump,          //
    output logic JumpR,          //
    output logic halt
);

  logic [6:0] R_TYPE, LW, SW, BR, IMM, JAL, JALR;

  assign R_TYPE = 7'b0110011;  // add,and,sub,slt,xor,or
  assign LW = 7'b0000011;      // lw,lh,lb,lbu
  assign SW = 7'b0100011;      // sw,sh,sbu
  assign BR = 7'b1100011;      // beq
  assign IMM = 7'b0010011;     // addi, slti, slli, srli, srai
  assign JAL = 7'b1101111;     // jal
  assign JALR = 7'b1100111;    // jalr
  assign HALT = 7'b0000000;    // halt

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
  assign halt = (Opcode == HALT); 
endmodule

