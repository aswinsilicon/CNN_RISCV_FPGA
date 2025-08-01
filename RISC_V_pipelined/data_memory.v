`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/09/2025 12:14:01 PM
// Design Name: 
// Module Name: data_memory
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


module data_memory(clk, write_enable,data_address,write_data,read_data);

    input clk;                   //clock signal
    input write_enable;          //controls whether data is written or not
    input [31:0] data_address;   //memory address generated by ALU
    input [31:0] write_data;     //data from reg_file to be written in memory
    output [31:0] read_data;     //data read from memory at data_address
    
    reg [31:0] RAM [0:32767];     //32767 x 32-bit memory (~ 128KB)
                                 //this increased memory is needed for hardcore accelaration.
                                 //I might change later if needed.
                                 //each entry in RAM is 32 bit (word)
    
    assign read_data = RAM[data_address[31:2]];    //read operation
                                                   //ignoring lower 2 bits
                                                       //because for each byte address, 
                                                       //the last two bits are always 00
    always @ (posedge clk)
        if (write_enable)                           //if write_enable = 1
            RAM[data_address[31:2]] <= write_data ; //write operation
            
endmodule
