`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [1:0] ALUOp,  // 2-bit opcode field from the Controller--00: LW/SW/AUIPC; 01:Branch; 10: Rtype; 11:Itype
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // operation selection for ALU
);
always_comb begin
    case (ALUOp)
      2'b00: // LW || SW
        Operation = 4'b0010; // (DOES ADD)

      2'b01: // BRANCH
        case (Funct3)
          3'b000: Operation = 4'b1000; // BEQ
          3'b001: Operation = 4'b1100; // BNE alteracao
          3'b100: Operation = 4'b0101; // BLT
          3'b101: Operation = 4'b1010; // BGE
          default: Operation = 4'bxxxx;
        endcase

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
      default: Operation = 4'bxxxx;
    endcase
  end

endmodule
