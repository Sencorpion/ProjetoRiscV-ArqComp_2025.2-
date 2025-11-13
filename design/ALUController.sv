`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [1:0] ALUOp,  // 2-bit opcode field from the Controller--00: LW/SW/AUIPC; 01:Branch; 10: Rtype/Itype; 11:JAL/LUI
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // operation selection for ALU
);
    // OBS: and command results in Operation == 0000
//Operation[0] = 1 : OR(0001), XOR(0011), SLT(0101), SRLI(0111), SRAI(1001)
assign Operation[0] = ((ALUOp == 2'b10) && (Funct3 == 3'b110)) || // R/I-or
    ((ALUOp == 2'b10) && (Funct3 == 3'b100)) || // R/I-xor
    ((ALUOp == 2'b10) && (Funct3 == 3'b010)) || // R/I-slt 
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) || // R/I->> (SRLI) 
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000));   // R/I->>> (SRAI) 

//Operation[1] = 1 : ADD(0010), XOR(0011), SLLI(0110), SRLI(0111), LW/SW(0010)
assign Operation[1] = (ALUOp == 2'b00) || // LW\SW
    ((ALUOp == 2'b10) && (Funct3 == 3'b000) && (Funct7 == 7'b0000000)) || // R\I-add
    ((ALUOp == 2'b10) && (Funct3 == 3'b100)) || // R/I-xor
    ((ALUOp == 2'b10) && (Funct3 == 3'b001)) || // R\I-<< (SLLI) 
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000));   // R/I->> (SRLI) 

//Operation[2] = 1 : SUB(0100), SLT(0101), SLLI(0110), SRLI(0111)
assign Operation[2] =  ((ALUOp==2'b10) && (Funct3==3'b000) && (Funct7==7'b0100000)) || // R\I-sub
    ((ALUOp == 2'b10) && (Funct3 == 3'b010)) || // R/I-slt 
    ((ALUOp == 2'b10) && (Funct3 == 3'b001)) || // R\I-<< (SLLI) 
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000));   // R/I->> (SRLI) 

//Operation[3] = 1 : BEQ(1000), SRAI(1001)
assign Operation[3] = (ALUOp == 2'b01) || // BEQ
    ((ALUOp == 2'b10) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000));   // R/I->>> (SRAI) 
endmodule
