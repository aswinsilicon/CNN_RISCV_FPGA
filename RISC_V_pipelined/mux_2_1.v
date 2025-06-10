`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 10:45:27 PM
// Design Name: 
// Module Name: mux_2_1
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

module mux_2_1(A, B, select, out);

    input [31:0] A;    //input A (32-bit)
    input [31:0] B;    //input B (32-bit)
    input select;      //select pin

    output wire [31:0] out; //output out (32-bit)

    assign out = (select == 0) ? A : B;
    //if select = 0, out = A
    //else if select = 1, out = B

endmodule