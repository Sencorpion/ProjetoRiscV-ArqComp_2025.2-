`timescale 1ns / 1ps

module imm_Gen (
    input  logic [31:0] inst_code,
    output logic [31:0] Imm_out
);


  always_comb
    case (inst_code[6:0])
      7'b0000011,  // I-Type load
      7'b0010011,  // I-type arithmetic
      7'b1100111:  // I-type JALR
      Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b0100011:  // S-Type
      Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:25], inst_code[11:7]};

      7'b1100011:  // B-Type
      Imm_out = {
        inst_code[31] ? 19'h7FFFF : 19'b0,
        inst_code[31],
        inst_code[7],
        inst_code[30:25],
        inst_code[11:8],
        1'b0
      };

      7'b1101111:  // J-Type
        Imm_out = {
          {11{inst_code[31]}}, // SIGN EXTENSION
          inst_code[19:12],    // IMM[19:12]
          inst_code[20],       // IMM[11]
          inst_code[30:21],    // IMM[10:1]
          1'b0                 // IMM[0]
          };

      default: Imm_out = {32'b0};

    endcase

endmodule
