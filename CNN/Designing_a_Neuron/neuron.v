`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 10:19:07 AM
// Design Name: 
// Module Name: neuron
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

`include "pre_defined.v"

module neuron #(parameter
    layerNo = 0,                      // This neuron's layer index 
    neuronNo = 0,                     // This neuron's index within the layer
    numWeight = 784,                  // Number of weights (or inputs) to this neuron
    dataWidth = 16,                   // Bit-width of input/output data (16-bit fixed-point)
    sigmoidSize = 5,                  // Size of output from sigmoid lookup table (i.e 5 outputs)
    weightIntWidth = 1,               // Integer bit-width in fixed-point weight representation
    addressWidth = clog2(numWeight),  // $clog2 is the verilog function to find log base 2
    activation_func = "relu",         // Activation function used (here "relu"/ "sigmoid")
    biasFile = "b_1_0.mif",                    // File to preload bias (for ROM-based init)
    weightFile = "w_1_0.mif"                   // File to preload weigt-3hts (for ROM-based init)
)(
    input clk,                           // Clock signal for sequential logic
    input reset,                         // Asynchronous or synchronous reset signal

    input [dataWidth-1:0] myinput,       // Input data to this neuron (from previous layer or input vector)
    input myinputValid,                  // Valid signal for input data (handshaking/control)
    
    input weightValid,                   // Valid signal indicating incoming weightValue is valid (for config/load)
    input biasValid,                     // Valid signal indicating incoming biasValue is valid (for config/load)

    input [31:0] weightValue,            // 32-bit value used to configure or load weights dynamically
    input [31:0] biasValue,              // 32-bit value used to configure or load bias dynamically
                                               //mostly upper 16 bits are not used, 
                                               // but since AXI interface uses 32 bit address we need 32 bits

    input [31:0] config_layer_num,       // Layer number to compare with parameter `layerNo` for selective configuration
    input [31:0] config_neuron_num,      // Neuron number to compare with parameter `neuronNo` for selective configuration

    output [dataWidth-1:0] out,          // Output of the neuron (after weighted sum and activation function)
    output reg outValid                  // Indicates that output is valid and can be consumed
);

    //user defined function to find log base 2 of numWeight
    function integer clog2;
    input integer value;
    begin
        value = value - 1;
        for (clog2 = 0; value > 0; clog2 = clog2 + 1)
            value = value >> 1;
    end
    endfunction

   
    reg  write_enable;
    wire read_enable;
    reg  [addressWidth-1:0] write_address;
    reg  [addressWidth:0]   read_address; //read address has to reach until numWeight hence width is 1 bit more
    reg  [dataWidth-1:0] write_in;
    wire [dataWidth-1:0] write_out;
    
    reg  [2*dataWidth-1:0]  multiply; 
    reg  [dataWidth-1:0] myinput_delay;
    
    wire mux_valid;
    reg  [2*dataWidth-1:0]  sum;
    wire [2*dataWidth:0] ComboAdd;
    wire [2*dataWidth:0] BiasAdd;
    
    reg  mult_valid;
    reg  [2*dataWidth-1:0]  bias;
    reg  muxValid_f;
    
    reg  weight_valid;
    reg  sigValid; 
    reg  muxValid_delay;
    
    reg  [31:0]    biasReg[0:0];
    reg  addr=0;


     //loading the weight values into the memory
     always @ (posedge clk)
         begin
         if (reset)
             // On reset, set write address to max value 
             begin
                 write_address <= {addressWidth{1'b1}};  //if addresssWidth=10, 10'b1111111111
                 write_enable  <= 0;                     //disable writing during reset
             end
              
         else if (weightValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
              // When weightValid signal is high AND this neuron matches the configuration target 
              begin
                  write_in      <= weightValue;           // Load incoming weight into write_in register
                  write_address <= write_address + 1;     // Increment write address to store next weight
                  write_enable  <= 1;                     // Enable writing to memory
              end
    
         else
                  write_enable  <= 0;                     //disable writing
     end
     
     // Simple combinational assignments used within the neuron
    assign mux_valid = mult_valid;         // Valid signal propagation from multiplier to mux
    assign ComboAdd  = multiply + sum;     // Sum of product and partial sum from previous operation
    assign BiasAdd   = bias + sum;         // Sum of bias and accumulated sum
    assign read_enable = myinputValid;     // Trigger read operation when new input is valid

     
     
     
    `ifdef pretrained
    // If using pretrained mode (weights and biases already known and stored in files)
    initial begin
        $readmemb(biasFile, biasReg);  // Load bias values from file into bias register array
    end

    always @(posedge clk) begin
        // For current neuron, select bias from biasReg using address
        // and shift left by dataWidth bits (multiplies by 2^dataWidth) to match fixed-point format
        bias <= {biasReg[addr][dataWidth-1:0], {dataWidth{1'b0}}};
    end

`else
    // In training or dynamic update mode: bias is sent in externally
    always @(posedge clk) begin
        if (biasValid && (config_layer_num == layerNo) && (config_neuron_num == neuronNo)) begin
            // Check if the bias being received is for this particular layer and neuron
            // If so, store it into the bias register (left-shifted for fixed-point precision)
            bias <= {biasValue[dataWidth-1:0], {dataWidth{1'b0}}};
        end
    end
`endif

     
     
     //inputs are coming one after the other, sequentially
     //our weight memory has one clock delay
     //so input has to get delayed by one clock
     always @ (posedge clk)
         begin
             myinput_delay <= myinput;
             weight_valid <= myinputValid;
             mult_valid <= weight_valid;
             sigValid <= ((read_address == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
             outValid <= sigValid;
             muxValid_delay <= mux_valid;
             muxValid_f <= !mux_valid & muxValid_delay;
         end
         
     always @ (posedge clk)
         begin
             multiply <= $signed(myinput_delay) * $signed(write_out); 
         end
     
     always @ (posedge clk)
         begin
             if (reset | outValid)
                 sum <= 0;
                 
             //now taking overflow & underflow conditions
             else if (mux_valid)
                 begin
                     if (!multiply[2*dataWidth-1:0] & !sum[2*dataWidth-1:0] & ComboAdd[2*dataWidth-1:0])
                         begin
                             sum[2*dataWidth-1:0] <= 1'b0;  //sign bit of sum is positive
                             sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};  //largest positive number
                         end
                         
                     else if (multiply[2*dataWidth-1:0] & sum[2*dataWidth-1:0] & !ComboAdd[2*dataWidth-1:0])
                         begin
                             sum[2*dataWidth-1:0] <= 1'b1; //sign bit of sum is negative
                             sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};  //smallest negative number
                         end
                         
                     else
                         sum <= ComboAdd;
                end
                
            //now taking FINAL overflow & underflow conditions
             else if ((read_address == numWeight) & muxValid_f)
                 begin
                     if (!bias[2*dataWidth-1:0] & !sum[2*dataWidth-1:0] & BiasAdd[2*dataWidth-1:0])
                         begin
                             sum[2*dataWidth-1:0] <= 1'b0;  //sign bit of sum is positive
                             sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};  //largest positive number
                         end
                         
                     else if (bias[2*dataWidth-1:0] & sum[2*dataWidth-1:0] & !BiasAdd[2*dataWidth-1:0])
                         begin
                             sum[2*dataWidth-1:0] <= 1'b1; //sign bit of sum is negative
                             sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};  //smallest negative number
                         end
                         
                     else
                         sum <= BiasAdd;
             end
        end
                                 
             
     
     //instantiation of memory for weights
     weight_memory #(.numWeight(numWeight),
                     .neuronNo(neuronNo),
                     .layerNo(layerNo),
                     .addressWidth(addressWidth),
                     .dataWidth(dataWidth),
                     .weightFile(weightFile) )
                     
                (.clk(clk),
                 .write_enable(write_enable),
                 .read_enable(read_enable),
                 .write_address(write_address),
                 .read_address(read_address),
                 .write_in(write_in),
                 .write_out(write_out)
                );
     
     //sum we generated goes to the activation function (sigmoid)
     generate  //to selectively instantiate same module mutliple times
     if (activation_func == "sigmoid") 
         begin: sig_inst
             //Instantiation of ROM for sigmoid
                 Sigmoid_ROM #(.inWidth(sigmoidSize), .dataWidth(dataWidth)) 
                 s(.clk(clk), .x(sum[2*dataWidth-1-:sigmoidSize]), .out(out));  //sending sum's upper bits - whatever is the sizgmoidsize
         end
         
     else
         begin:relu_inst
             //Instantiation of ROM for ReLU (rectified linear unit)
                 ReLU #(.dataWidth(dataWidth),.weightIntWidth(weightIntWidth)) 
                 r(.clk(clk), .x(sum), .out(out));
         end
     endgenerate
     
     
     `ifdef DEBUG
    always @(posedge clk)
    begin
        if(outValid)
            $display(neuronNo,,,,"%b",out);
    end
    `endif

endmodule
