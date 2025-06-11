`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 12:25:40 PM
// Design Name: 
// Module Name: hazard_detection_unit
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


module hazard_detection_unit(rs1_D,rs2_D,rs1_E,rs2_E,rd_E,rd_M,rd_W,
                             RegWriteM,RegWriteW,ResultSrcE0,PCSrcE,
                             ForwardAE,ForwardBE,Flush_E,Flush_D,
                             Stall_D,Stall_F);
 
    input [4:0] rs1_D, rs2_D,rs1_E,rs2_E;
    input [4:0] rd_E,rd_M,rd_W;
    input RegWriteM,RegWriteW;
    input PCSrcE,ResultSrcE0;
    output reg [1:0] ForwardAE,ForwardBE;
    output Stall_D,Stall_F;       //correctly handles data and control hazards
    output Flush_E,Flush_D;       //correctly handles data and control hazards
    

//Read after write Hazard
    //bypassing data from later stages back to earlier ones in next clock cycle

    wire lwstall; //stalls the fetch and decode stages and 
                  //inserts NOP into the execute stage
    
    always @ (*) begin
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;
        
        if ((rs1_E == rd_M) & (RegWriteM) & (rs1_E !=0))
            ForwardAE = 2'b10;         //forwarding ALUResult in Memory stage
        else if ((rs1_E == rd_W) & (RegWriteW) & (rs1_E !=0))
            ForwardAE = 2'b01;         //forwarding write_back_result in WB stage
            
        if ((rs2_E == rd_M) & (RegWriteM) & (rs2_E !=0))
            ForwardBE = 2'b10;         //forwarding ALUResult in Memory stage
        else if ((rs2_E == rd_W) & (RegWriteW) & (rs2_E !=0))
            ForwardBE = 2'b01;         //forwarding write_back_result in WB stage
    end 
    
    assign lwstall = (ResultSrcE0 == 1) & (rd_E == rs1_D) | (rd_E == rs2_D);
    
    assign Stall_F = lwstall;          //freeze the fetch stage if lwstall is 1
    assign Stall_D = lwstall;          //freeze the fetch stage if lwstall is 1
    assign Flush_E = lwstall | PCSrcE; //insert NOP into execute stage if lwstall is 1 or JumpPC 
    assign Flush_D = PCSrcE;           //flush decode stage if JumpPC
   
   
endmodule
