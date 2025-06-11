`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 11:19:04 AM
// Design Name: 
// Module Name: reset_ff
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
module reset_ff (clk,reset,d,q,StallD);
    input       clk, reset;
    input       [31:0] d;
    
    input       StallD;
    
    output reg  [31:0] q;
    


always @(posedge clk or posedge reset) begin
    if (reset) q <= 0;
    else if(!StallD)    q <= d;
end

endmodule