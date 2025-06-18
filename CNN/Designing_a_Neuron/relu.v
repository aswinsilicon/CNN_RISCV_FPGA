`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 09:54:03 AM
// Design Name: 
// Module Name: relu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ReLU #(parameter 
              dataWidth = 16,          // Bit-width of fixed-point output
              weightIntWidth = 4       // Bit-width of integer part in fixed-point format
)(
    input clk,                         // Clock signal for sequential logic
    input [2*dataWidth-1:0] x,         // Input value in wider fixed-point format (e.g., product of two 16-bit values)
    output reg [dataWidth-1:0] out     // Output value after applying ReLU and possible saturation
);

// Sequential logic block triggered on rising edge of the clock
always @(posedge clk)
begin
    if($signed(x) >= 0) // Check if input `x` is positive
                        // 1 signbit-weightIntWidth-inputIntWidth-weightFrac-inputFrac
    begin
        // Check for overflow into the integer sign bit region
        // If any bit in the extended integer part is high, it's a saturation condition
        if(|x[2*dataWidth-1-:weightIntWidth+1]) //over flow to sign bit of integer part
            out <= {1'b0,{(dataWidth-1){1'b1}}}; //positive saturate
        else
             // No overflow, extract the appropriate dataWidth bits starting after the integer part(inputIntWidth,inputFrac)       
            out <= x[2*dataWidth-1-weightIntWidth-:dataWidth];
    end
    else 
        out <= 0;   // If input is negative, ReLU outputs zero
end

endmodule