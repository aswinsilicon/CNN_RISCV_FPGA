`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 09:51:48 AM
// Design Name: 
// Module Name: Weight_Memory
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


`include "pre_Define.v"

module Weight_Memory #(parameter 
    numWeight   = 3,                // Total number of weights (depth of memory)
    neuronNo    = 5,                // Current neuron number (not used inside this module)
    layerNo     = 1,                // Current layer number (not used inside this module)
    addressWidth = 10,              // Width of address input (log2(numWeight) if numWeight = 1024 => 10 bits)
    dataWidth    = 16,              // Width of data stored per memory location
    weightFile   = "w_1_15.mif"     // File for initial weight values (used if pretrained mode: ROM)
)(
    input clk,                              // Clock input
    input wen,                              // Write enable signal for writing data
    input ren,                              // Read enable signal for reading data
    input [addressWidth-1:0] wadd,          // Address to write data
    input [addressWidth-1:0] radd,          // Address to read data
    input [dataWidth-1:0] win,              // Data to be written into memory
    output reg [dataWidth-1:0] wout);       // Data read from memory (output)
    
    // Declare internal memory array
    // Memory depth = numWeight; each location stores dataWidth bits
    reg [dataWidth-1:0] mem [numWeight-1:0];

    // ROM mode: Pretrained weights loaded from external file
    `ifdef pretrained
        initial
		begin
	        $readmemb(weightFile, mem);
	    end
	    
    // RAM mode: Runtime write support for dynamic weight loading
	`else
		always @(posedge clk)
		begin
			if (wen)
			begin
				mem[wadd] <= win;
			end
		end 
    `endif
    
    // Memory read logic
    always @(posedge clk)
    begin
        if (ren)
        begin
            wout <= mem[radd];
        end
    end 
    
     // - If read block is written as combinational logic using assign or always @*,
           //   the memory may get implemented as distributed RAM (LUTs).
    // - If read block is written as sequential logic, using clk,
           //   it will infer Block RAMs (BRAMs), which are more efficient for large memories.

endmodule