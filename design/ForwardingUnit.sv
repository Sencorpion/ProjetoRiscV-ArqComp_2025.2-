`timescale 1ns / 1ps

/*
* Forwarding Unit
* Description: Implements the data forwarding (or bypassing) logic to resolve
*              Read-After-Write (RAW) data hazards. It compares the source
*              registers (rs1, rs2) of an instruction in the EX stage with the
*              destination registers (rd) of instructions in the MEM and WB
*              stages. If a dependency is found, it generates control signals
*              ('Forward_A', 'Forward_B') to tell forwarding mux in the EX
*              stage to the newer, correct data from a later pipeline stage,
*              rather than the stale data read from the register file.
*/

module ForwardingUnit (
    // INPUTS
    // RS1: The 5-bit address of the first source register for the instruction
    //      in the EX stage
    input logic [4:0] RS1,

    // RS2: The 5-bit address of the second source register for the
    //      instruction in the EX stage
    input logic [4:0] RS2,

    // EX_MEM_rd: The 5-bit address of the destination register for the
    //            instruction in the MEM stage
    input logic [4:0] EX_MEM_rd,

    // MEM_WB_rd: The 5-bit address of the destination register for the
    //            instruction in the WB stage.
    input logic [4:0] MEM_WB_rd,

    // EX_MEM_RegWrite: The RegWrite signal for the instruction in the MEM
    //                  stage. Must be asserted for forwarding to occur
    input logic EX_MEM_RegWrite,

    // MEM_WB_rd: The RegWrite signal for the instruction in the WB stage
    input logic MEM_WB_RegWrite,

    // OUTPUTS
    // Forward_A: Control signal for the first ALU operand (SrcA)
    // - 2'b00: No forwarding. Use the value from the Register File.
    // - 2'b01: Forward the result from the WB stage (MEM/WB register)
    // - 2'b10: Forward the result from the MEM stage (EX/MEM register)
    output logic [1:0] Forward_A,

    // Forward_B: Control signal for the second ALU operand (SrcB)
    //            (Same encoding as Forward_A)
    output logic [1:0] Forward_B
);

  assign Forward_A =
    // First priority: Checks for hazard from the MEM stage.
    // If the instruction in MEM is writing to a register (EX_MEM_RegWrite),
    // and its destination register is not x0, and its destination register
    // matches rs1 of the instruction in EX, then forward teh ALU result from
    // the MEM stage.
    ((EX_MEM_RegWrite) && (EX_MEM_rd != 0) && (EX_MEM_rd == RS1))
    ? 2'b10 :

    // Second priority: Checks for hazard from the WB stage.
    // If the instruction in WB is writing to a register (MEM_WB_rd), and its
    // destination register is not x0, and its destination register matches
    // rs1 of the instruction in EX, then forward the final result from the WB
    // stage.
    ((MEM_WB_RegWrite) && (MEM_WB_rd != 0) && (MEM_WB_rd == RS1)) ? 2'b01 :

    // No hazard. No forwarding is needed.
    2'b00;

  assign Forward_B =
    // First priority: Check for hazard from the MEM stage.
    ((EX_MEM_RegWrite) && (EX_MEM_rd != 0) && (EX_MEM_rd == RS2))
    ? 2'b10 :

    // Second priority: Check for hazard from the WB stage
    ((MEM_WB_RegWrite) && (MEM_WB_rd != 0) && (MEM_WB_rd == RS2))
    ? 2'b01 :

    // No hazard. No forwarding is needed.
    2'b00;

endmodule
