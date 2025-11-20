/*
* PIPELINE BUFFER REGISTERS package
* Description: This package defines the structures for all the pipeline
*              inter-stage registers (A,B,C,D,E) in the 5-stage pipelined CPU datapath
*/


package Pipe_Buf_Reg_PKG;
  //--------------------------------
  // Reg A: IF/ID
  //--------------------------------
  // Transfers instruction and PC information from the IF stage to the ID stage
  typedef struct packed {

    // Curr_Pc: The Program Counter value of the instruction currently in the
    //          ID stage. Used for calculating branch/jump targets and for JAL/JALR
    //          link address.
    logic [8:0]  Curr_Pc;

    // Curr_Instr:The 32-bit instruction fetched from memory, now in the ID stage
    logic [31:0] Curr_Instr;
  } if_id_reg;

  //--------------------------------
  // Reg B: ID/EX
  //--------------------------------
  // Transfers decoded instruction fields, read register data, immediate values,
  // and all necessary control signals from the ID stage to the EX stage.

  typedef struct packed {
    // CONTROL SIGNALS
    // ALUSrc: Selects the ALU's second operand (ID to EX)
    logic        ALUSrc;

    // MemtoReg: Selects the data source for register write-back (ID to WB)
    logic [1:0]  MemtoReg;

    // RegWrite: Enables writing to the register file (ID to WB)
    logic        RegWrite;

    // MemRead: Enables reading from data memory (ID to MEM)
    logic        MemRead;

    // MemWrite: Enables writing to data memory (ID to MEM)
    logic        MemWrite;

    // ALUOp: High-level ALU operation category for ALU controller (ID to EX)
    logic [1:0]  ALUOp;

    // Branch: Indicates a conditional branch instruction (ID to EX)
    logic        Branch;

    // Jump: Indicates a JAL instruction (ID to EX)
    logic        Jump;

    // JumpR: Indicates a JALR instruction (ID to EX)
    logic        JumpR;

    // DATA/ADDRESS INFO
    // Curr_Pc: PC of the instruction (original PC_W bits), passed to Branch Unit
    logic [8:0]  Curr_Pc;

    // RD_One: Data read from the first source register (rs1) (ID TO EX)
    logic [31:0] RD_One;

    // RD_Two: Data read from the second source register (rs2) (ID to EX and MEM)
    logic [31:0] RD_Two;

    // RS_One: Address of the first source register (rs1). Used for forwarding. (ID to EX)
    logic [4:0]  RS_One;

    // RS_Two: Address of the second source register (rs2). Used for forwarding (ID to EX)
    logic [4:0]  RS_Two;

    // rd: Address of the destination register (ID to WB, used by forwarding unit)
    logic [4:0]  rd;

    // ImmG: Sign-extended immediate value (ID to EX)
    logic [31:0] ImmG;

    // func3: Funct3 field of the instruction (ID to EX and MEM)
    logic [2:0]  func3;

    // func7: Funct7 field of the instruction (ID to EX)
    logic [6:0]  func7;

    // Curr_Instr: The raw instruction
    logic [31:0] Curr_Instr;
  } id_ex_reg;

  //--------------------------------
  // Reg C: EX/MEM
  //--------------------------------
  // Transfers ALU results, data to be stored, and control signals from the
  // EX stage to the MEM stage.
  typedef struct packed {
    // CONTROL SIGNALS (Same ones from Reg B)
    logic        RegWrite;

    logic [1:0]  MemtoReg;

    logic        MemRead;

    logic        MemWrite;

    // DATA/ADDRESS SIGNALS (Same from Reg B, except for Alu_Result, Pc_Imm, Pc_Four and Imm_Out)
    // Pc_Imm: Calculated PC + Immediate for branches/JAL
    logic [31:0] Pc_Imm;

    // Pc_Four: Calculated PC + 4 value (link address for JAL and JALR) (EX to WB)
    logic [31:0] Pc_Four;

    // Imm_Out: Sign-extended immediate value (for forwarding)
    logic [31:0] Imm_Out;

    // Alu_Result: Result from the ALU. Used for memory address or write-back (EX to MEM and WB)
    logic [31:0] Alu_Result;

    logic [31:0] RD_Two;

    logic [4:0]  rd;

    logic [2:0]  func3;

    logic [6:0]  func7;

    logic [31:0] Curr_Instr;
  } ex_mem_reg;

  //--------------------------------
  // Reg D: MEM/WB
  //--------------------------------
  // Transfers data read from memory, ALU results, and control signals from the
  // MEM stage to the WB stage.
  typedef struct packed {
    // CONTROL SIGNALS (same from register B and C)
    logic        RegWrite;

    logic [1:0]  MemtoReg;

    // DATA/ADDRESS SIGNALS (same for B and C, except for MemReadData)
    logic [31:0] Pc_Imm;

    logic [31:0] Pc_Four;

    logic [31:0] Imm_Out;

    logic [31:0] Alu_Result;

    // MemReadData: Data read from data memory. (MEM to WB)
    logic [31:0] MemReadData;

    logic [4:0]  rd;

    logic [31:0] Curr_Instr;
  } mem_wb_reg;
endpackage
