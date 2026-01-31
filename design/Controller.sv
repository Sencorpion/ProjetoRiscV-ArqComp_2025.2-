`timescale 1ns / 1ps

module Controller (
    //Input
    input logic [6:0] Opcode,   // 7-bit opcode field from the instruction

    //Outputs
    output logic ALUSrc,
    //0: The second ALU operand comes from the second register file output (Read data 2);
    //1: The second ALU operand is the reconstructed immediate value from the instruction.
    output logic PCtoALU, 
    //0: The first ALU operand comes from the first register file output (Read data 1);
    //1: The first ALU operand is value of the PC when the instruction was fetched.
    output logic [1:0] MemtoReg,
    //00: The value fed to the register Write data input comes from the ALU;
    //01: The value fed to the register Write data input comes from the data memory;
    //10: The value fed to the register Write data input comes from the PC (+4);
    //11: The value fed to the register Write data input comes from the generated immediate value.
    output logic RegWrite,      // The register on the Write register input is written with the value on the Write data input
    output logic MemRead,       // Data memory contents designated by the address input are put on the Read data output
    output logic MemWrite,      // Data memory contents designated by the address input are replaced by the value on the Write data input.
    output logic [1:0] ALUOp,
    //00: The operation performed by the ALU is a part of a Load/Store/AUIPC instruction;
    //01: The operation performed by the ALU is a part of a Branch instruction;
    //10: The operation performed by the ALU is a part of a Register type instruction;
    //11: The operation performed by the ALU is a part of a Immediate type instruction.
    output logic Branch,        // Asserts that the current instruction is a Conditional Branch instruction.
    output logic Jump,          // Asserts that the current instruction is a Inconditional Branch (that branches from the current PC value) instruction.
    output logic JumpR,         // Asserts that the current instruction is a Inconditional Branch (that branches from a register value) instruction.
    output logic Halt           // Asserts that the current instruction is a Halt.
);

  logic [6:0] R_TYPE, LOAD, STORE, BRANCH, I_TYPE, JAL, JALR, HALT, AUIPC, LUI;

  assign R_TYPE = 7'b0110011;  // Arithmetic/Logical/Shift operation between registers.
  assign LOAD = 7'b0000011;    // Load from memory into a register.
  assign STORE = 7'b0100011;   // Store from a register into memory.
  assign BRANCH = 7'b1100011;  // Conditional branch based on register comparison.
  assign I_TYPE = 7'b0010011;  // Arithmetic/Logical/Shift operation with a 12-bit immediate.
  assign JAL = 7'b1101111;     // Jump and Link: Inconditional jump to PC + Offset.
  assign JALR = 7'b1100111;    // Jump and Link Register: Inconditional jump to Register + Offset.
  assign AUIPC = 7'b0010111;   // Add Upper Immediate to PC: PC + (Imm << 12).
  assign LUI = 7'b0110111;     // Load Upper Immediate: Register = (Imm << 12).
  assign HALT = 7'b1111111;    // Custom Halt instruction to stop execution.

  assign ALUSrc = (Opcode == LOAD || Opcode == STORE || Opcode == I_TYPE || Opcode == JALR || Opcode == AUIPC);
  assign PCtoALU = (Opcode == AUIPC);
  assign MemtoReg = (Opcode == LOAD) ? 2'b01 :
                    (Opcode == JAL || Opcode == JALR) ? 2'b10 :
                    (Opcode == LUI) ? 2'b11 :
                    2'b00;
  assign RegWrite = (Opcode == R_TYPE || Opcode == LOAD || Opcode == I_TYPE || Opcode == JAL || Opcode == JALR || Opcode == AUIPC || Opcode == LUI);
  assign MemRead = (Opcode == LOAD);
  assign MemWrite = (Opcode == STORE);
  assign ALUOp[0] = (Opcode == BRANCH || Opcode == I_TYPE || Opcode == JALR);
  assign ALUOp[1] = (Opcode == R_TYPE || Opcode == I_TYPE || Opcode == JALR);
  assign Branch = (Opcode == BRANCH);
  assign Jump = (Opcode == JAL);
  assign JumpR = (Opcode == JALR);
  assign Halt = (Opcode == HALT);

endmodule



