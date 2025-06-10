`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 10:49:16 AM
// Design Name: 
// Module Name: ex_mem_reg
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

//we have not included hazard detection using "clear" for this register because 
    //typically hazard control occurs in ID and EX stages
    
module ex_mem_reg(clk,reset,ALUResult_E,write_data_E,rd_E,PCplus4E,
                           ALUResult_M,write_data_M,rd_M,PCplus4M);

    input clk;                        //clock input
    input reset;                      //active high reset to clear register contents
     
    input [31:0] ALUResult_E;         //ALU result in execute stage
    input [31:0] write_data_E;        //PC value in execute stage
    input [4:0] rd_E;                 //destination register in execute
    input [31:0] PCplus4E;            //PC + 4 value in execute stage 
    
    output reg [31:0] ALUResult_M;    //ALU result in memory stage
    output reg [31:0] write_data_M;   //PC value in memory stage
    output reg [4:0] rd_M;            //destination register in memory
    output reg [31:0] PCplus4M;       //PC + 4 value in memory stage 
    
    always @ (posedge clk, posedge reset) begin
        if (reset) begin         
            ALUResult_M   <= 0;
            write_data_M  <= 0;
            rd_M          <= 0;
            PCplus4M      <= 0; 
        end
        
        else  begin
            ALUResult_M   <= ALUResult_E;  
            write_data_M  <= write_data_E;
            rd_M          <= rd_E;
            PCplus4M      <= PCplus4E; 
        end
    end   
endmodule