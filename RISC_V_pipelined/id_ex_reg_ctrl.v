`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 10:44:39 AM
// Design Name: 
// Module Name: id_ex_reg_ctrl
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


module id_ex_reg_ctrl(clk, reset, clear,RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcAD, ALUSrcBD, ResultSrcD, ALUControlD,
                                        RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcAE, ALUSrcBE, ResultSrcE, ALUControlE);

    input clk, reset, clear;
    
    input RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcAD;
    input [1:0] ALUSrcBD;
    input [1:0] ResultSrcD;
    input [3:0] ALUControlD;
    
    output reg RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcAE;
    output reg [1:0] ALUSrcBE;
    output reg [1:0] ResultSrcE;
    output reg [3:0] ALUControlE;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegWriteE   <= 0;
            MemWriteE   <= 0;
            JumpE       <= 0;
            BranchE     <= 0;
            ALUSrcAE    <= 0;
            ALUSrcBE    <= 0;
            ResultSrcE  <= 0;
            ALUControlE <= 0;
        end 
        
        else if (clear) begin
            RegWriteE   <= 0;
            MemWriteE   <= 0;
            JumpE       <= 0;
            BranchE     <= 0;
            ALUSrcAE    <= 0;
            ALUSrcBE    <= 0;
            ResultSrcE  <= 0;
            ALUControlE <= 0;
        end 
        
        else begin
            RegWriteE   <= RegWriteD;
            MemWriteE   <= MemWriteD;
            JumpE       <= JumpD;
            BranchE     <= BranchD;
            ALUSrcAE    <= ALUSrcAD;
            ALUSrcBE    <= ALUSrcBD;
            ResultSrcE  <= ResultSrcD;
            ALUControlE <= ALUControlD;
        end
    end
endmodule

