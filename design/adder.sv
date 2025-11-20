`timescale 1ns / 1ps

/*
* GENERIC N-BIT ADDER
* Description: Takes two n-bit numbers as input and outputs their (n-bit) sum.
*/

module adder #(

    // PARAMETERS
    // WIDTH: Defines the bit width of the input operands 'a' and 'b',
    //        as well as the output sum 'y'.
    //        This parameter allows the module to be reused for different data
    //        sizes without modification. Examples: Can be set to 9 for PC
    //        calculations, and 32 for general data path operations.
    // OBS: The default bit width value is set to 8.
    parameter WIDTH = 8
) (

    // INPUTS
    // a: First n-bit input operand
    // b: Second n-bit input operand
    input  logic [WIDTH-1:0] a,
    b,

    // OUTPUTS
    // y: The n-bit output representing the sum of input a and input b.
    //
    // OBS: Notice that there aren't any carry-out bits, so the result of the
    //      sum will result in the least significant WIDTH-bits of the binary
    //      sum.
    output logic [WIDTH-1:0] y
);

  // Quite self-evident, isn't it?
  assign y = a + b;

endmodule
