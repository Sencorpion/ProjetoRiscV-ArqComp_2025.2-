`timescale 1ns / 1ps

/*
* GENERIC 2 to 1 MULTIPLEXER
* Description: Selects one of two N-bit data input (d0 or d1) based on the
*              state of a single-bit select signal (s), and routes chosen input to the
*              N-bit output (y).
*/

module mux2 #(

    // PARAMETERS
    // WIDTH: Defines the bit-widht of the two data inputs and the output.
    //        This parameter allows the 'mux2' module to be reused for different data
    //        sizes.
    parameter WIDTH = 32
) (

    // INPUTS
    // d0: The first N-bit data input. Selected when 's' is zero.
    input logic [WIDTH-1:0] d0,

    // d1: The second N-bit data input. Selected when 's' is one.
    d1,

    // s: The 1-bit select signal
    input logic s,

    // OUTPUTS
    // y: The N-bit output, which reflects the currently selected data input.
    output logic [WIDTH-1:0] y
);

  // Quite intuitive, no?
  assign y = s ? d1 : d0;

endmodule
