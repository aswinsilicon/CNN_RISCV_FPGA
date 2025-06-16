`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 10:34:52 AM
// Design Name: 
// Module Name: weight_memory
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

`include "pre_defined.v"  // Include file for global parameters/macros

module weight_memory #(parameter
    numWeight   = 3,                // Total number of weights (depth of memory)
    neuronNo    = 5,                // Current neuron number (not used inside this module)
    layerNo     = 1,                // Current layer number (not used inside this module)
    addressWidth = 10,              // Width of address input (log2(numWeight) if numWeight = 1024 => 10 bits)
    dataWidth    = 16,              // Width of data stored per memory location
    weightFile   = "w_1_15.mif"     // File for initial weight values (used if pretrained mode: ROM)
)(
    input clk,                                // Clock input
    input write_enable,                       // Write enable signal for writing data
    input read_enable,                        // Read enable signal for reading data
    input [addressWidth-1:0] write_address,   // Address to write data
    input [addressWidth-1:0] read_address,    // Address to read data
    input [dataWidth-1:0] write_in,           // Data to be written into memory
    output reg [dataWidth-1:0] write_out      // Data read from memory (output)
);

    // Declare internal memory array
    // Memory depth = numWeight; each location stores dataWidth bits
    reg [dataWidth-1:0] memory [numWeight-1:0];

    // ROM mode: Pretrained weights loaded from external file
    `ifdef pretrained
        initial begin
            $readmemb(weightFile, memory);  // Load weights from file into memory at start
        end

    // RAM mode: Runtime write support for dynamic weight loading
    `else
        always @(posedge clk) begin
            if (write_enable) begin
                memory[write_address] <= write_in;  // Store new weight value at specified address
            end
        end
    `endif

    // Memory read logic
    always @(posedge clk) begin
        if (read_enable) begin
            write_out <= memory[read_address];  // Read weight value from specified address
        end
    end

    
    // - If read block is written as combinational logic using assign or always @*,
           //   the memory may get implemented as distributed RAM (LUTs).
    // - If read block is written as sequential logic, using clk,
           //   it will infer Block RAMs (BRAMs), which are more efficient for large memories.

endmodule
