`timescale 1ns / 1ps

/*
* DATA MEMORY INTERFACE UNIT
* Description: Translates CPU Load/Store requests into signals for the
*              underlying memory component (Memoria32Data). Handles the logic
*              for bit-addressability, supporting reads and writes of
*              different sizes (word, half-word, etc).
*/

module datamemory #(

    // PARAMETERS
    // DM_ADDRESS: The width of the address bus used for data memory.
    //             Matches the ALU result bits used.
    parameter DM_ADDRESS = 9,

    // DATA_W: Native data width of the processor.
    parameter DATA_W = 32
) (

    // INPUTS
    // clk: The system's clock.
    input logic clk,

    // MemRead: Control signal from the Controller. Asserted to perform memory read.
    input logic MemRead,

    // MemWrite: Control signal from the Controller. Asserted to perform memory write
    input logic MemWrite,

    // a: The memory address, usually the 9 least significant bits of the ALU
    //    result. The address is byte-alligned, but the memory is
    //    word-alligned.
    input logic [DM_ADDRESS - 1:0] a,

    // wd: The 32-bit data to be written to memory for Store operations.
    input logic [DATA_W - 1:0] wd,

    // Funct3: Bits [14:12] of the instruction. Useful for distringuishing
    // different memory instructions amongst themselves (LW and LB, SW and SH, etc).
    input logic [2:0] Funct3,

    // OUTPUTS
    // rd: The 32-bit data read from memory.
    output logic [DATA_W - 1:0] rd
);

  logic [31:0] raddress; // The 32-bit read address sent to the memory component.
  logic [31:0] waddress; // The 32-bit write address sent to the memory component.
  logic [31:0] Datain;   // The 32-bit data sent to the memory component for writing.
  logic [31:0] Dataout;  // The 32-bit raw data received from the memory component.
  logic [ 3:0] Wr;       // The 4-bit the 4-bit write-enable signal, one bit of each byte in a word. 

  // Instantiates the Memoria32Data module, which provides a 32-bit wide,
  // byte-addressable data memory.
  Memoria32Data mem32 (
      .raddress(raddress),
      .waddress(waddress),
      .Clk(~clk),
      .Datain(Datain),
      .Dataout(Dataout),
      .Wr(Wr)
  );

  always_ff @(*) begin

    // The byte address 'a' is converted to a word-alligned address
    // for the Memoria32Data module by turning the 2 least significant bits to
    // zero.
    raddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    waddress = {{22{1'b0}}, {a[8:2], {2{1'b0}}}};
    Datain = wd; // Default data to write is the full word.
    Wr = 4'b0000;

    // LOAD LOGIC
    if (MemRead) begin
      case (Funct3)
          3'b000: begin                                         // LB (Load Byte) (SIGNED)

          // Select the correct byte from the 32-bit Dataout base on
          // the byte offset. Then, sign-extend it to 32-bits.
          case(a[1:0])
            2'b00: rd <= {{24{Dataout[7]}}, Dataout[7:0]}
            2'b01: rd <= {{24{Dataout[15]}}, Dataout[15:8]};
            2'b10: rd <= {{24{Dataout[23]}}, Dataout[23:16]};
            2'b11: rd <= {{24{Dataout[31]}}, Dataout[31:24]};
          endcase
        end
        3'b001: begin                                           // LH (Load Half-word)

          // Select the correct half-word from the 32-bit Dataout based on
          // the alignment. Then, sign-extend it to 32-bits.
          case(a[1:0])
            2'b00: rd <= {{16{Dataout[15]}}, Dataout[15:0]};
            2'b10: rd <= {{16{Dataout[31]}}, Dataout[31:16]};
            default: rd <= 32'hxxxx; 
          endcase
        end
        3'b010:                                                 // LW (Load Word)
          // For full word, just load the entire word.
          rd <= Dataout;
          3'b100: begin                                         // LB (Load Byte) (UNSIGNED)

          // Similar to LB, but zero-extended (instead of sign-extended).
          case(a[1:0])
            2'b00: rd <= {{24{1'b0}}, Dataout[7:0]};
            2'b01: rd <= {{24{1'b0}}, Dataout[15:8]};
            2'b10: rd <= {{24{1'b0}}, Dataout[23:16]};
            2'b11: rd <= {{24{1'b0}}, Dataout[31:24]};
          endcase
        end
        default: rd <= Dataout;
      endcase

    // WRITE LOGIC
    end else if (MemWrite) begin
      case (Funct3)
          3'b000: begin                                         // SB (Store Byte)

          // Selects which byte to write based on the byte offset.
          case(a[1:0])
            2'b00: begin                        // Store to byte 0
              Wr <= 4'b0001;                    // Enables writing only to byte 0.
              Datain <= {24'b0, wd[7:0]};       // Place the 8-bit data in byte 0.
            end
            2'b01: begin                        // Store to byte 1
              Wr <= 4'b0010;                    // Enables writing only to byte 1.
              Datain <= {16'b0, wd[7:0], 8'b0}; // Place the 8-bit data in byte 1.
            end
            2'b10: begin                        // Store to byte 2
              Wr <= 4'b0100;                    // Enables writing only to byte 2.
              Datain <= {8'b0, wd[7:0], 16'b0}; // Place the 8-bit data in byte 2.
            end
            2'b11: begin                        // Store to byte 3
              Wr <= 4'b1000;                    // Enables writing only to byte 3.
              Datain <= {wd[7:0], 24'b0};       // Place the 8-bit data in byte 3.
            end
          endcase
        end
        3'b001: begin                                          // SH (Store Half-word)

          // Selects which half-word to write based on the byte alignment.
          case(a[1])
            1'b0: begin                         // Store to lower half-word.
              Wr <= 4'b0011;                    // Enables writing to bytes 1 and 0
              Datain <= {16'b0, wd[15:0]};      // Place the 16-bit data in the lower half
            end
            1'b1: begin                         // Store to upper half-word
              Wr <= 4'b1100;                    // Enables writing to bytes 3 and 2
              Datain <= {wd[15:0], 16'b0};      // Place the 16-bit data in the upper half
            end
          endcase
        end
        3'b010: begin                                          // SW (Store Word)
          Wr <= 4'b1111;                        // Enables writing to all 4 bytes.
          Datain <= wd;                         // Place the entire 32-bit data to the word.
        end
        default: begin
          Wr <= 4'b1111;
          Datain <= wd;
        end
      endcase
    end
  end

endmodule
