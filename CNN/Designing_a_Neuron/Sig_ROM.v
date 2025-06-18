`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 09:50:57 AM
// Design Name: 
// Module Name: Sig_ROM
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

// ROM module for sigmoid function lookup
// Reads from a binary file "sigContent.mif" which stores precomputed sigmoid values
// Addressing is symmetric: handles signed input x by shifting into the unsigned address space

module Sig_ROM #(parameter 
    inWidth = 10,    // Width of the input (address lines), i.e., log2(depth)
    dataWidth = 16   // Width of the data (output sigmoid value)
)(
    input clk,                          // Clock input
    input [inWidth-1:0] x,              // Input address (can be signed, treated as offset)
    output [dataWidth-1:0] out          // Output sigmoid value from ROM
);
    // Memory declaration: depth = 2^inWidth, each entry is dataWidth bits
    reg [dataWidth-1:0] mem [2**inWidth-1:0];
    
    // Internal address register after signed to unsigned adjustment
    reg [inWidth-1:0] y;
    
	// Initialize ROM content from file using binary format
    initial begin
        $readmemb("sigContent.mif", mem);  // Load precomputed sigmoid values
    end
    
    // On every positive clock edge, calculate the ROM address
    // The input x is treated as signed, shifted to positive address range:
    // Example: for 10-bit address, x ∈ [-512, 511] becomes y ∈ [0, 1023]
    always @(posedge clk)
    begin
        if($signed(x) >= 0)
            y <= x+(2**(inWidth-1));   // Map positive signed x to upper half
        else 
            y <= x-(2**(inWidth-1));   // Map negative signed x to lower half  
    end
    
    // Output the value from ROM at computed address
    // since it is a combinational statement,
        // it will be used by distributed RAMs.
    assign out = mem[y];
    
endmodule