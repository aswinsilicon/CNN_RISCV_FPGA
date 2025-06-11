`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 07:11:36 PM
// Design Name: 
// Module Name: forward_Bmux
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


module forward_Bmux(RD2_E,ALUResult_M,write_back_result,ForwardB,outB);

    input [31:0] RD2_E;              //value coming from id_ex_reg (initially from reg_file)
    input [31:0] ALUResult_M;        //forwarded value from mem_wb_reg
    input [31:0] write_back_result;  //forwarded value from mem_wb_reg
    input [1:0] ForwardB;            //select pin to choose between forwarded values or reg_file value
    
    output [31:0] outB;              //32 bit output 
    //                             10                             01              00            
    assign outA = ForwardB[1] ? ALUResult_M : (ForwardB[0] ? write_back_result : RD2_E);
endmodule
