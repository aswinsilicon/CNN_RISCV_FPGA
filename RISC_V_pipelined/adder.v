`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 10:42:26 PM
// Design Name: 
// Module Name: adder
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


module adder(A,B,out); 

    input [31:0] A;    //input A (32-bit)
    input [31:0] B;    //input B (32-bit)
    output wire [31:0] out; //output out (32-bit)
 
    assign out = A + B; //out is summation of A and B

endmodule
