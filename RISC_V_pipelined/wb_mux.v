`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 11:24:42 AM
// Design Name: 
// Module Name: wb_mux
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


module wb_mux(ALUResult_W,read_data_W,PCplus4W,ResultSrcW,write_back_result);
  
    input [31:0] ALUResult_W;          //ALU result obtained from mem_wb_reg
    input [31:0] read_data_W;          //read_data obtained from mem_wb_Reg
    input [31:0] PCplus4W;             //PC + 4 value obtained from mem_wb_reg 
    
    input [1:0] ResultSrcW;            //control signal from the Control Unit during ID stage
    
    output [31:0] write_back_result;   //writing back the result according to ResultSrcW control signal
    //                                           10                            01           00 
    assign write_back_result = ResultSrcW[1]? PCplus4W : (ResultSrcW[0] ? read_data_W : ALUResult_W);
    
endmodule
