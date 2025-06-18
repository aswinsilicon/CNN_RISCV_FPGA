`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2025 09:53:17 AM
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

//`define DEBUG
`include "pre_Define.v"

module neuron #(parameter
    layerNo = 0,                      // This neuron's layer index 
    neuronNo = 0,                     // This neuron's index within the layer
    numWeight = 784,                  // Number of weights (or inputs) to this neuron
    dataWidth = 16,                   // Bit-width of input/output data (16-bit fixed-point)
    sigmoidSize = 10,                  // Size of output from sigmoid lookup table (i.e 5 outputs)
    weightIntWidth = 1,               // Integer bit-width in fixed-point weight representation
    addressWidth = clog2(numWeight),  // $clog2 is the verilog function to find log base 2
    actType = "sigmoid",         // Activation function used (here "relu"/ "sigmoid")
    biasFile = "b_1_0.mif",                    // File to preload bias (for ROM-based init)
    weightFile = "w_1_0.mif"                   // File to preload weigt-3hts (for ROM-based init)
)(
    input clk,                           // Clock signal for sequential logic
    input rst,                         // Asynchronous or synchronous reset signal

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
    output reg outvalid                  // Indicates that output is valid and can be consumed
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
    
    reg         wen;
    wire        ren;
    reg [addressWidth-1:0] w_addr;
    reg [addressWidth:0]   r_addr;//read address has to reach until numWeight hence width is 1 bit more
    reg [dataWidth-1:0]  w_in;
    wire [dataWidth-1:0] w_out;
    reg [2*dataWidth-1:0]  mul; 
    reg [2*dataWidth-1:0]  sum;
    reg [2*dataWidth-1:0]  bias;
    reg [31:0]    biasReg[0:0];
    reg         weight_valid;
    reg         mult_valid;
    wire        mux_valid;
    reg         sigValid; 
    wire [2*dataWidth:0] comboAdd;
    wire [2*dataWidth:0] BiasAdd;
    reg  [dataWidth-1:0] myinputd;
    reg muxValid_d;
    reg muxValid_f;
    reg addr=0;
    
    
   //loading weight values into the momory
    always @(posedge clk)
    begin
        if(rst)
        // On reset, set write address to max value 
        begin
            w_addr <= {addressWidth{1'b1}};  //if addresssWidth=10, 10'b1111111111
            wen <=0;                         //disable writing during reset
        end
        else if(weightValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
        // When weightValid signal is high AND this neuron matches the configuration target        
        begin
            w_in <= weightValue;             // Load incoming weight into write_in register
            w_addr <= w_addr + 1;            // Increment write address to store next weight
            wen <= 1;                        // Enable writing to memory                      
        end
        else
            wen <= 0;                        //disable writing
    end 
	 // Simple combinational assignments used within the neuron
    assign mux_valid = mult_valid;         // Valid signal propagation from multiplier to mux
    assign comboAdd  = mul + sum;          // Sum of product and partial sum from previous operation
    assign BiasAdd   = bias + sum;         // Sum of bias and accumulated sum
    assign ren = myinputValid;             // Trigger read operation when new input is valid

    
	`ifdef pretrained
	// If using pretrained mode (weights and biases already known and stored in files)
		initial
		begin
			$readmemb(biasFile,biasReg);  // Load bias values from file into bias register array
		end
		always @(posedge clk)
		begin
		// For current neuron, select bias from biasReg using address
        // and shift left by dataWidth bits (multiplies by 2^dataWidth) to match fixed-point format   
            bias <= {biasReg[addr][dataWidth-1:0],{dataWidth{1'b0}}};
        end
	`else
     // In training or dynamic update mode: bias is sent in externally
	    always @(posedge clk)
		begin
		if(biasValid & (config_layer_num==layerNo) & (config_neuron_num==neuronNo))
			begin
		       // Check if the bias being received is for this particular layer and neuron
               // If so, store it into the bias register (left-shifted for fixed-point precision)
				bias <= {biasValue[dataWidth-1:0],{dataWidth{1'b0}}};
			end
		end
	`endif
    
    
    always @(posedge clk)
    begin
        if(rst|outvalid)
            r_addr <= 0;
        else if(myinputValid)
            r_addr <= r_addr + 1;
    end
    
    always @(posedge clk)
    begin
        mul  <= $signed(myinputd) * $signed(w_out);
    end
    
    //sum generation
    always @(posedge clk)
    begin
        if(rst|outvalid)
            sum <= 0;
            
        //now taking bias overflow & underflow conditions   
        else if((r_addr == numWeight) & muxValid_f)
        begin
            if(!bias[2*dataWidth-1] &!sum[2*dataWidth-1] & BiasAdd[2*dataWidth-1]) //If bias and sum are positive and after adding bias to sum, if sign bit becomes 1, saturate
            begin
                sum[2*dataWidth-1] <= 1'b0;                    //sign bit of sum is positive
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}}; //largest positive number
            end
            else if(bias[2*dataWidth-1] & sum[2*dataWidth-1] &  !BiasAdd[2*dataWidth-1]) //If bias and sum are negative and after addition if sign bit is 0, saturate
            begin
                sum[2*dataWidth-1] <= 1'b1;                    //sign bit of sum is negative
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}}; //smallest negative number
            end
            else
                sum <= BiasAdd; 
        end
        
        //now taking overflow & underflow conditions
        else if(mux_valid)
        begin
            if(!mul[2*dataWidth-1] & !sum[2*dataWidth-1] & comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b0;                     //sign bit of sum is positive
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b1}};  //largest positive number 
            end
            else if(mul[2*dataWidth-1] & sum[2*dataWidth-1] & !comboAdd[2*dataWidth-1])
            begin
                sum[2*dataWidth-1] <= 1'b1;                     //sign bit of sum is negative
                sum[2*dataWidth-2:0] <= {2*dataWidth-1{1'b0}};  //smallest negative number
            end
            else
                sum <= comboAdd; 
        end
    end
    
    //inputs are coming one after the other, sequentially
    //our weight memory has one clock delay
    //so input has to get delayed by one clock
    always @(posedge clk)
    begin
        myinputd <= myinput;
        weight_valid <= myinputValid;
        mult_valid <= weight_valid;
        sigValid <= ((r_addr == numWeight) & muxValid_f) ? 1'b1 : 1'b0;
        outvalid <= sigValid;
        muxValid_d <= mux_valid;
        muxValid_f <= !mux_valid & muxValid_d;
    end
    
    
    //Instantiation of memory for weights
    Weight_Memory #(.numWeight(numWeight),
                    .neuronNo(neuronNo),
                    .layerNo(layerNo),
                    .addressWidth(addressWidth),
                    .dataWidth(dataWidth),
                    .weightFile(weightFile)) 
    WM(
        .clk(clk),
        .wen(wen),
        .ren(ren),
        .wadd(w_addr),
        .radd(r_addr),
        .win(w_in),
        .wout(w_out)
    );
    
    //sum we generated goes to the activation function (sigmoid)
    generate   //to selectively instantiate same module mutliple times
        if(actType == "sigmoid")
        begin:siginst
        //Instantiation of ROM for sigmoid
            Sig_ROM #(.inWidth(sigmoidSize),.dataWidth(dataWidth)) 
            
        s(
            .clk(clk),
            .x(sum[2*dataWidth-1-:sigmoidSize]),
            .out(out)
        );
        end
        else
        begin:ReLUinst
            //Instantiation of ReLU (rectified linear unit)
            ReLU #(.dataWidth(dataWidth),.weightIntWidth(weightIntWidth)) 
        r (
            .clk(clk),
            .x(sum),
            .out(out)
        );
        end
    endgenerate

    `ifdef DEBUG
    always @(posedge clk)
    begin
        if(outvalid)
            $display(neuronNo,,,,"%b",out);
    end
    `endif
endmodule
