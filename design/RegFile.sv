`timescale 1ns / 1ps

/*
* GENERIC REGISTER FILE
* Description: : This module implements the processor's register file, which
*                is an array of general-purpose registers used to store data
*                for computation. It supports two asynchronous read ports and
*                one synchronous write port.
*/

module RegFile #(

    // PARAMETERS
    // DATA_WIDTH: Number of bits in each individual register.
    //             32 bits for RISC-V.
    parameter DATA_WIDTH = 32,

    // ADDRESS_WIDTH: The number of bits required to address a register.
    //                For 32 bits, it's 5 bits.
    parameter ADDRESS_WIDTH = 5,

    // NUM_REGS: The total number of registers in the file.
    parameter NUM_REGS = 32
) (

    // INPUTS
    // clk: The system's clock
    input clk,

    //rst: Synchronous reset signal. When asserted, all registers are cleared
    //     to zero.
    input rst,

    // rg_wrt_en: Write enable signal. When asserted, data is written to the register specified by 'rg_wrt_dest'
    input rg_wrt_en,

    // rg_wrt_dest: The 5-bit address of the register to which data will be
    //              written.
    input  [ADDRESS_WIDTH-1:0] rg_wrt_dest,

    // rg_rd_addr1: The 5-bit address of the first register to be read
    input [ADDRESS_WIDTH-1:0] rg_rd_addr1,

    // rg_rd_addr2: The 5-bit address of the second register to be read 
    input [ADDRESS_WIDTH-1:0] rg_rd_addr2,

    // rg_wrt_data: The 32-bit data to be written into a register specified by 'rg_wrt_dest'
    input  [DATA_WIDTH-1:0] rg_wrt_data,

    // OUTPUTS
    // rg_rd_data1: The 32-bit content of the register specified by 'rg_rd_addr1'
    output logic [DATA_WIDTH-1:0] rg_rd_data1,

    // rg_rd_data2: The 32-bit content of the register specified by 'rg_rd_addr2'
    output logic [DATA_WIDTH-1:0] rg_rd_data2

  integer i;

  // The array of registers.
  logic [DATA_WIDTH-1:0] register_file[NUM_REGS-1:0];

  always @(negedge clk) begin
    if (rst == 1'b1) for (i = 0; i < NUM_REGS; i = i + 1) register_file[i] <= 0; // If reset is asserted, all registers are cleared to zero

    // If reset is not asserted and rg_wrt_en is high, data is written to the
    // specified destination register
    else if (rst == 1'b0 && rg_wrt_en == 1'b1) begin
      register_file[rg_wrt_dest] <= rg_wrt_data;
    end
  end

  // Read logic
  assign rg_rd_data1 = register_file[rg_rd_addr1];
  assign rg_rd_data2 = register_file[rg_rd_addr2];

endmodule
