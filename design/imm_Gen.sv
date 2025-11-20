`timescale 1ns / 1ps

/*
* IMMEDIATE VALUE GENERATOR
* Description: Extracts and formats the immediate value from the 32-bit
*              instruction word. Reconstructs the correct 32-bit sign-extended
*              immediate value from various different instruction formats.
*/

module imm_Gen (

    // INPUTS
    // inst_code: The full 32-bit instruction word from which the immediate
    //            value gets to be extracted
    input  logic [31:0] inst_code,

    // OUTPUTS
    // Imm_out: The final 32-bit sign-extended immediate value, ready to be
    //          used by the ALU or Branch Unit
    output logic [31:0] Imm_out
);

  always_comb
    case (inst_code[6:0]) // Decodes 7-bit opcode to determine the immediate format and reconstruct the value
      7'b0000011,  // I-Type for Load instructions
      7'b0010011,  // I-type for Arithmetic/Logical instructions with immediate
      7'b1100111:  // I-type for Jump and Link Register (JALR)

      // Reconstruction:
      // - inst_code[31] is the sign bit. It is replicated 20 times to perform
      //   sign extension
      // - inst_code[31:20] forms the 12-bit immediate value
      Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:20]};

      7'b0100011:  // S-Type for Store instructions

      // Reconstruction:
      // - inst_code[31] is the sign bit. It is replicated 20 times to perform
      //   sign extension
      // - The immediate is formed by concatenating inst_code[31:25] and
      //   inst_code[11:7], resulting in a 12-bit immediate
      Imm_out = {inst_code[31] ? 20'hFFFFF : 20'b0, inst_code[31:25], inst_code[11:7]};

      7'b1100011:  // B-Type for Branch instructions

      // Reconstruction:
      // - inst_code[31]: sign bit
      // - inst_code[7]: immediate bit 11
      // - inst_code[30:25]: immediate bits 10:5
      // - inst_code[11:8]: immediate bits 4:1
      // - 1'b0 : immediate bit 0 (always zero for branch targets)
      // Forms a 13-bit signal, which is sign-extended
      Imm_out = {
        inst_code[31] ? 19'h7FFFF : 19'b0,
        inst_code[31],
        inst_code[7],
        inst_code[30:25],
        inst_code[11:8],
        1'b0
      };

      7'b1101111:  // J-Type for Jump And Link (JAL)

        // Reconstruction:
        // - inst_code[31]: immediate bit 20
        // - inst_code[19:12]: immediate bits 19:12
        // - inst_code[20]: immediate bit 11
        // - inst_code[30:21]: immediate bits 10:1
        // - 1'b0: immediate bit 0 (always zero for jump targets)
        // This forms a 21-bit immediate, which is sign-extended.
        Imm_out = {
          {11{inst_code[31]}},
          inst_code[19:12],
          inst_code[20],
          inst_code[30:21],
          1'b0
          };

      default: Imm_out = {32'b0};

    endcase

endmodule
