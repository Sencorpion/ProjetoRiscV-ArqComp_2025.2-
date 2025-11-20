`timescale 1ns / 1ps

/*
* ARITHMETIC LOGIC UNIT (ALU)
* Description: Performs various arithmetic and logical operations on two
*              32-bit operands (SrcA, SrcB) based on a 4-bit operation code
*              (Operation).
*/

module alu#(

        // PARAMETERS
        // DATA_WIDTH: Defines the bit-width of the input operands and the
        //             result. Hardcoded to 32 for a standard 32-bit RISC
        //             V architecture.
        parameter DATA_WIDTH = 32,

        // OPCODE_LENGTH: Defines the bit-width of the Operation control
        //                signal. A 4-bit lenght allows for 16 different
        //                operations.
        parameter OPCODE_LENGTH = 4
        )
        (

        // INPUTS
        // SrcA: The first 32-bit input operand.
        input logic [DATA_WIDTH-1:0]    SrcA,

        // SrcB: The second 32-bit input operand.
        input logic [DATA_WIDTH-1:0]    SrcB,

        // Operation: The 4-bit control code from the ALUController that
        //            selects which function this ALU will perform.
        input logic [OPCODE_LENGTH-1:0]    Operation,

        // OUPUTS
        // ALUResult: The 32-bit result of the performed operation.
        output logic [DATA_WIDTH-1:0] ALUResult
        );

        always_comb
        begin
            case(Operation)
            // LOGICAL OPERATIONS:
            4'b0000:                           // AND
                    ALUResult = SrcA & SrcB;
            4'b0001:                           // OR
                    ALUResult = SrcA | SrcB;
            4'b0011:                           // XOR
                    ALUResult = SrcA ^ SrcB;

            // ARITHMETIC OPERATIONS
            4'b0010:                           // ADD
                    ALUResult = SrcA + SrcB;
            4'b0100:                           // SUB
		                ALUResult = SrcA - SrcB;

            // SHIFT OPERATIONS
            // Note: For immediate shifts, the RISC V ISA uses only the
            //       5 least significant bits of the immediate value as the
            //       shift ammount.
            4'b0110:                           // SLL (SHIFT LEFT LOGICAL)
                    ALUResult = SrcA << SrcB[4:0];
            4'b0111:                           // SRL (SHIFT RIGHT LOGICAL)
                    ALUResult = SrcA >> SrcB[4:0];
            4'b1001:                           // SRAI (SHIFT RIGHT ARITHMETIC)
                    ALUResult = $signed(SrcA) >>> SrcB[4:0];

            // COMPARISON OPERATIONS
            4'b1000:                           // EQ (EQUAL)
                    ALUResult = (SrcA == SrcB) ? 1 : 0;
            4'b0101:                           // LT (LESSER THAN) (SIGNED)
		                ALUResult = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;

            default:
            // If the operation isn't recognized, outputs 0.
                    ALUResult = 32'b0;
            endcase
        end
endmodule
