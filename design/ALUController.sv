`timescale 1ns / 1ps

/*
* ALU CONTROL UNIT
* Description: Acts as the sub-controller for the ALU. It translates a 2-bit
*              high-level ALU Operation (ALUOp) code from the Controller ,
*              along with specific instruction fields (Funct3, Funct7), into
*              a 4-bit operation code (Operation) that directly tells the
*              ALU which function to perform.
*/

module ALUController (

    // INPUTS
    // ALUOp: A 2-bit control signal from the Controller. It indicates the
    //        type of ALU operation required by the current instruction.
    //        - 2'b00: LOAD/STORE     - Requires ADD for address calculation
    //        - 2'b01: BRANCH         - Requires comparison checks (equal, less
    //                                  than, etc)
    //        - 2'b10  REGISTER TYPE  - Requires Funct3 and Funct7 for specific
    //                                  operations between registers
    //        - 2'b11  IMMEDIATE TYPE - Requires Funct3 and (very, very rarely) Funct7 for specific
    //                                  operations between a register and
    //                                  a fixed, immediate value
    input logic [1:0] ALUOp,

    // Funct7: Bits[31:25] of the instruction. Used primarily for R-Type
    //         instructions, and occasionally for I-Type instruction (mostly
    //         shift operations) to differentiate instructions with the exact
    //         Funct3 code.
    input logic [6:0] Funct7,

    // Funct3: Bits[14:12] of the instruction. Used for R-Type and I-Type
    //         instructions to specific the required ALU operation.
    input logic [2:0] Funct3,

    // OUTPUTS
    // Operation: A 4-bit control signal that directly selects the function to
    //            be performed by the ALU. The encoding depends on how the ALU
    //            module interprets the data.
    output logic [3:0] Operation
);
always_comb begin
    case (ALUOp)
      2'b00: // STORE || LOAD
        Operation = 4'b0010; // (DOES ADD)

      2'b01: // BRANCH
        Operation = 4'b1000; // BEQ

      2'b10: // REGISTER TYPE
        case (Funct3)
          3'b000: Operation = (Funct7 == 7'b0100000) ? 4'b0100 : 4'b0010; // SUB || ADD
          3'b010: Operation = 4'b0101;                                    // SLT
          3'b100: Operation = 4'b0011;                                    // XOR
          3'b110: Operation = 4'b0001;                                    // OR
          3'b111: Operation = 4'b0000;                                    // AND
          default: Operation = 4'bxxxx;
        endcase
      2'b11: // IMMEDIATE TYPE
        case (Funct3)
          3'b000: Operation = 4'b0010;                                    // ADDI
          3'b001: Operation = 4'b0110;                                    // SLLI
          3'b010: Operation = 4'b0101;                                    // SLTI
          3'b101: Operation = (Funct7 == 7'b0100000) ? 4'b1001 : 4'b0111; // SRAI || SRLI
          default: Operation = 4'bxxxx;
        endcase
      default: Operation = 4'bxxxx; // Default to an undefined state to catch unhandled cases.
    endcase
  end

endmodule
