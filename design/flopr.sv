`timescale 1ns / 1ps

/*
* GENERIC N-BIT REGISTER
* Description: Implements a generic, parameterizable N-bit D-type flip-flop.
*              It features an active-high asynchronous reset and an active-high stall
*              signal.
*/

module flopr #(

    // PARAMETERS
    // Description: Defines the bit-width of the register, making it
    //              reusable to store data of any size. Examples:
    //              9-bit PC, 32-bit instruction...
    // OBS: The default bit-width value is set to 8.
    parameter WIDTH = 8
) (

    // INPUTS
    // clk: The system's clock system.
    input logic clk,

    // reset: Asynchronous, active-high reset signal. When the signal is
    //        high, the register's output is forced to zero, regardless of
    //        clock edge.
    reset,

    // d: The N-bit data input to the register. This is the value that will
    //    be latched into the register on the next valid clock edge.
    input logic [WIDTH-1:0] d,

    // stall: Active-high stall signal. When asserted, it prevents the
    //        register, from latching new data, causing it to hold its current value.
    //        This is used to stop a pipeline stage. Effectively acts as an
    //        active-low enable signal (enable = !stall).
    input logic stall,

    // OUTPUTS
    // q: The N-bit registered output. It holds the value of 'd' from the last
    //    valid (non-stalled) clock-edge.
    output logic [WIDTH-1:0] q
);

  always_ff @(posedge clk, posedge reset) begin
    if (reset) q <= 0;        // If reset is high, 'q' is immediatly cleared to 0.
    else if (!stall) q <= d;  // If stall isn't asserted, the register is enabled and latches 'd' into 'q'.
    // If stall is asserted, no assignment to 'q' is made, so it holds its previous value.
  end

endmodule
