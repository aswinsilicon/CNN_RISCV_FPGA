`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 10:45:57 AM
// Design Name: 
// Module Name: ex_mem_reg_ctrl
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


module ex_mem_reg_ctrl(clk, reset,RegWriteE, MemWriteE, ResultSrcE,
                                  RegWriteM, MemWriteM, ResultSrcM);

    input clk, reset;
    input RegWriteE, MemWriteE;
    input [1:0] ResultSrcE;
    
    output reg RegWriteM, MemWriteM;
    output reg [1:0] ResultSrcM;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            RegWriteM <= 0;
            MemWriteM <= 0;
            ResultSrcM <= 0;
        end 
        
        else begin
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            ResultSrcM <= ResultSrcE;
        end
    end
endmodule
