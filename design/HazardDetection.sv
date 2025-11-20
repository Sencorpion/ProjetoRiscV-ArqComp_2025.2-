`timescale 1ns / 1ps

/*
* HAZARD DETECTION UNIT
* Description: Detects a specific type of data hazard called "Load-Use
*              Hazard". A Load-Use hazard occurs when an instruction
*              immediatly following a Load instruction tries to use the data
*              that the Load instruction is fetching from memory. Since the
*              Load instruction's data is only available after the MEM stage,
*              the dependent instruction in the EX stage would attempt to use
*              incorrect data.
*              To resolve this, this unit generates a 'stall' signal, which
*              injects NOPs into the pipeline, preventing the dependent
*              instruction from proceeding until the load data is ready.
*/

module HazardDetection (

    // INPUTS
    // IF_ID_RS1: The 5-bit address of the first source register (rs1) of the
    //            instruction currently in the ID stage
    input logic [4:0] IF_ID_RS1,

    // IF_ID_RS2: The 5-bit address of the second source register (rs2) of the
    //            instruction currently in the ID stage
    input logic [4:0] IF_ID_RS2,

    // ID_EX_rd: The 5-bit address of the destination register (rd) of the
    //           instruction currently in the EX stage. This is the register that a Load
    //           instruction would write its data into
    input logic [4:0] ID_EX_rd,

    // ID_EX_MemRead: The MemRead control signal for the instruction currently
    //                in the EX stage. This signal is asserted if the instruction in EX is
    //                a Load instruction
    input logic ID_EX_MemRead,

    // OUTPUTS
    // stall: A 1-bit signal. When asserted, it indicates that a load-use
    //        hazard has been detected and the pipeline should stall for one cycle.
    //        This prevents the instruction in the ID stage from moving to EX, and
    //        causes the IF stage to refetch the same instruction
    output logic stall
);

  // The stall is generated if and only if all the following conditions are true:
  // 1. The instruction currently in the EX stage is a Load instruction.
  // 2. The destination register of that Load instruction isn't register x0
  // 3. The destination register of the Load instruction matches either the first source register or the second source register
  //    of the instruction currently in the ID stage
  assign stall = (ID_EX_MemRead) ? ((ID_EX_rd == IF_ID_RS1) || (ID_EX_rd == IF_ID_RS2)) : 0;

endmodule
