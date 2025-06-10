`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 12:03:43 PM
// Design Name: 
// Module Name: pc_mux
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


module pc_mux(PCplus4F,JumpTarget_E,PCSrcE,pc_next);


    input [31:0] PCplus4F;       //PC +4 value in IF stage
    input [31:0] JumpTarget_E;   //Jumping to another address
     
    input PCSrcE;                //select pin from Control Unit
    
    output [31:0] pc_next;       //result of the selection
    //                            1              0
    assign pc_next = PCSrcE ? JumpTarget_E : PCplus4F ;
    
endmodule
