
`timescale 1ns / 1ps

/*
* INSTRUCTION MEMORY INTERFACE UNIT
* Description: Receives a read address (Program Counter) and outputs the
*              32-bit instruction stored at that address. It acts as a wrapper around the
*              generic 'Memoria32 component, adapting its interface for instruction
*              fetching. It is primarily a read-only interface during CPU operation.
*/

module instructionmemory #(

    // PARAMETERS
    // INS_ADDRESS: The width of the address bus for the instruction memory.
    //              Matches the PC_W parameter from Datapath.
    parameter INS_ADDRESS = 9,

    // INS_W: The width of instructions, 32-bit for RISC-V.
    parameter INS_W = 32
) (

    // INPUTS
    // clk: The system's clock
    input logic clk,

    // ra: The read address for the instruction memory, provided by
    //     the PC
    input logic [INS_ADDRESS -1:0] ra,

    // OUTPUTS
    // rd: The 32-bit instruction read from the memory at the given address.
    output logic [INS_W -1:0] rd
);

  // A wire to capture the raw 32-bit data output from the underlying
  // Memoria32 module
  logic [INS_W-1 : 0] get_dataOut;

  // Instantiates teh generic 'Memoria32' module to serve as the instruction
  // memory.
  // - raddress: The read address from the PC (ra) is cast to 32 bits.
  // - waddress: Fixed to zero as instruction memory is not written by teh CPU
  // - Clk: Inverted System's clock
  // - Datain: Data input is unused for instruction reads.
  // - Dataout: The 32-bit instruction read from memory.
  // - Wr: Write enable is deasserted (write not used)
  Memoria32 meminst (
      .raddress(32'(ra)),
      .waddress(32'b0),  // unused
      .Clk(~clk),
      .Datain(32'b0),  // unused
      .Dataout(get_dataOut),
      .Wr(1'b0)  // unused
  );

  // The instruction read from the memory component is directly assigned to
  // the module's output
  assign rd = get_dataOut;

endmodule
