`timescale 1ns / 1ps

/*
* GENERIC 4 to 1 Multiplexer
* Description: Selects one of four N-bit data inputs (d00, d01, d10, d11)
*              based on the state of a 2-bit select signal (s) and routes the chosen input
*              to the N-bit output (y).
*/

module mux4 #(

    // PARAMETERS
    // WIDTH: Defines the bit-widht of the two data inputs and the output.
    //        This parameter allows the 'mux4' module to be reused for different data
    //        sizes.
    parameter WIDTH = 32
) (

    // INPUTS
    // d00: The first N-bit data input. Selected when 's' is 2'b00
    input logic [WIDTH-1:0] d00,

    // d01: The second N-bit data input. Selected when 's' is 2'b01
    d01,

    // d10: The third N-bit data input. Selected when 's' is 2'b10
    d10,

    // d11: The fourth N-bit data input. Selected when 's' is 2'b11
    d11,

    // s: The 2-bit select signal
    input logic [1:0] s,

    // OUTPUTS
    // y: The N-bit output, which reflects the currently selected data input
    output logic [WIDTH-1:0] y
);

  // I love ternary operators
  assign y = (s == 2'b11) ? d11 : (s == 2'b10) ? d10 : (s == 2'b01) ? d01 : d00;

endmodule
