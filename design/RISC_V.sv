`timescale 1ns / 1ps

/*
* RISC-V CPU TOP-LEVEL
* Description: A wrapper module for the entire RISC-V processor. It
*              instantiates the three main components of the CPU:
*              1. Controller: The main controll unit.
*              2. ALUController: The ALU's subcontrol unit.
*              3. Datapath: The main datapath containing the pipeline stages.
*
*              It defines internal wires that connects these components,
*              forming the complete processor.
*/

module riscv #(
    // PARAMETERS
    // DATA_W: The native data width of the processor
    parameter DATA_W = 32
) (
    // INPUTS
    // clk: Main system's clock
    input logic clk,

    // reset: System's reset signal
    reset,

    // OUTPUTS
    // OBS: Primary output
    // WB_Data: The final data value being written back to the register file.
    //          Useful for verifying instruction results.
    output logic [31:0] WB_Data,

    // OBS2: Debugging/Verification outputs
    output logic [4:0] reg_num,           // The destination register number in the WB stage
    output logic [31:0] reg_data,         // The data being written to the register in the WB stage
    output logic reg_write_sig,           // The RegWrite signal as seen in the WB stage
    output logic wr,                      // The MemWrite signal as seen in the MEM stage
    output logic rd,                      // The MemRead signal as seen in the MEM stage
    output logic [8:0] addr,              // The address sent to data memory in the MEM stage
    output logic [DATA_W-1:0] wr_data,    // The data sent to data memory in the MEM stage
    output logic [DATA_W-1:0] rd_data     // The data read from data memory in the MEM stage
);

  // WIRES
  // Connections between Datapath and Controller
  logic [6:0] opcode;       // From Datapath (ID stage) to Controller
  logic ALUSrc,             // From Controller to Datapath
    RegWrite,               // From Controller to Datapath
    MemRead,                // From Controller to Datapath
    MemWrite,               // From Controller to Datapath
    Branch,                 // From Controller to Datapath
    Jump,                   // From Controller to Datapath
    JumpR;                  // From Controller to Datapath
  logic [1:0] MemtoReg;     // From Controller to Datapath
  logic [1:0] ALUop;        // From Controller to Datapath

  // Connections between Datapath and ALUController
  logic [1:0] ALUop_Reg;    // ALUOp signal from the EX stage of the Datapath. From Datapath to ALUController.
  logic [6:0] Funct7;       // Funct7 field from the EX stage of the Datapath. From Datapath to ALUController.
  logic [2:0] Funct3;       // Funct3 field from the eX stage of the Datapath. From Datapath to ALUController.
  logic [3:0] Operation;    // Specific 4-bit ALU operation code for the ALU. From ALUController to Datapath.

  // COMPONENTS

  // 1. Controller: Decodes the opcode and generates high-level control signals
  Controller c (
      opcode,
      ALUSrc,
      MemtoReg,
      RegWrite,
      MemRead,
      MemWrite,
      ALUop,
      Branch,
      Jump,
      JumpR
  );

  // 2. ALU Controller: Decodes ALUOp, Funct3, and Funct7 to generate the
  //    Specific 4-bit operation code for the ALU
  ALUController ac (
      ALUop_Reg,
      Funct7,
      Funct3,
      Operation
  );

  // 3. Datapath: Contains the pipeline, register file, ALU, memories, and all
  //    data related hardware
  Datapath dp (
      clk,
      reset,
      RegWrite,
      ALUSrc,
      MemWrite,
      MemRead,
      Branch,
      Jump,
      JumpR,
      MemtoReg,
      ALUop,
      Operation,
      opcode,
      Funct7,
      Funct3,
      ALUop_Reg,
      WB_Data,
      reg_num,
      reg_data,
      reg_write_sig,
      wr,
      rd,
      addr,
      wr_data,
      rd_data
  );

endmodule
