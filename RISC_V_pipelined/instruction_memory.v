`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 04:30:00 PM
// Design Name: 
// Module Name: instruction_memory
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


module instruction_memory(pc,instruction_data);
   
    input [31:0] pc;               //from program counter fetch
    output [31:0] instruction_data;     //output instruction, read from memory
    
    reg [7:0] RAM[0:65536];        //65536 x 8-bit = 64KB 
    
    assign instruction_data = {RAM[pc+3],RAM[pc+2],RAM[pc+1],RAM[pc+0]};
    
    initial begin
        $readmemh("test1.hex",RAM);
        $readmemh("test2.hex",RAM);
        $readmemh("test3.hex",RAM);
        $readmemh("test4.hex",RAM);
        $readmemh("test5.hex",RAM);
        $readmemh("test6.hex",RAM);
        $readmemh("test7.hex",RAM);
        $readmemh("test8.hex",RAM);
        $readmemh("test9.hex",RAM);
        $readmemh("test10.hex",RAM);
        $readmemh("test11.hex",RAM);
        $readmemh("test12.hex",RAM);
        $readmemh("test13.hex",RAM);
        $readmemh("test14.hex",RAM);
        $readmemh("test15.hex",RAM);
    end 
          
endmodule
