`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 07:04:08 PM
// Design Name: 
// Module Name: forward_Amux
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


module forward_Amux(RD1_E,ALUResult_M,write_back_result,ForwardA,outA);

    input [31:0] RD1_E;              //value coming from id_ex_reg (initially from reg_file)
    input [31:0] ALUResult_M;        //forwarded value from mem_wb_reg
    input [31:0] write_back_result;  //forwarded value from mem_wb_reg
    input [1:0] ForwardA;            //select pin to choose between forwarded values or reg_file value
    
    output [31:0] outA;              //32 bit output
    //                             10                             01              00            
    assign outA = ForwardA[1] ? ALUResult_M : (ForwardA[0] ? write_back_result : RD1_E);
endmodule
