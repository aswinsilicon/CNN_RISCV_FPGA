`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 09:57:01 PM
// Design Name: 
// Module Name: immediate_extend
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


module immediate_extend(instruction, result);

    input [31:0] instruction;
    output reg [31:0] result;

    //opcode types for instruction
    localparam I_Load   = 7'b0000011;  //I type (for Load) 
    localparam I        = 7'b0010011;  //I type
    localparam S        = 7'b0100011;  //S type (for store)
    localparam R        = 7'b0110011;  //R type
    localparam B        = 7'b1100011;  //B type
    localparam J        = 7'b1101111;  //J type
    localparam I_Jalr   = 7'b1100111;  //I type (for jalr)
    
    always @ (instruction)
        begin
            case (instruction[6:0])
                I_Load, I: 
                    result <= {{20{instruction[31]}}, instruction[31:20]};
                    //Uses bits [31:20].
                    //Sign-extends from bit 31
                S: 
                    result <= {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                    //Uses bits [31:25] and [11:7] (split immediate)
                    //Sign-extends from bit 31.
                B: 
                    result <= {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    //imm[12]    = instr[31]
                    //imm[10:5]  = instr[30:25]
                    //imm[4:1]   = instr[11:8]
                    //imm[11]    = instr[7]
                    //imm[0]     = 0 (LSB of offset is always 0 for alignment)        
                J, I_Jalr:
                    result <= {{12{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                    //imm[20]    = instr[31]
                    //imm[10:1]  = instr[30:21]
                    //imm[11]    = instr[20]
                    //imm[19:12] = instr[19:12]
                    //imm[0]     = 0 (LSB always 0)
                default: result <= 0;
            endcase
        end
endmodule