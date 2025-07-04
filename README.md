
# Hardware-Accelerated Convolutional Neural Network on RISC-V Processor integrated with FPGA

Progress :
- ### 17th April: Revised Python Programming language
- ### 18th April: Revised Verilog HDL basics through NPTEL Lectures
- ### 19th April: Tried solving HDL Bits questions
- ### 20th April: Convolutional Neural Networks by Prof. Fei Fei

- ### 6th June: Got introduced to Digilent ZedBoard. Read the Zedboard datasheet.
- ### 7th June: RISC-V Add, immediate instructions
- ### 8th June: RISCV ISA, RISCV Fields: R,I,S. Designed 32-bit ALU in Verilog.
- ### 9th June: Designed ALU Decoder, Main Decoder, Data Memory, Instruction Memory,    32-bit Adder, 2x1,3x1,4x1 Multiplexer
- ### 10th June: Designed fetch_decode register, decode_execute register, execute_memory register, memory_writeback register, write back multiplexer, register file, program counter multiplexer,
- ### 11th June: ForwardAmux,ForwardBmux,id_ex_ctrl,ex_mem_ctrl,mem_wb_ctrl, datapath, controller,hazard unit, Zedboard OLED display was tested, datapath and controller bugs and instantiation issues were resolved and further issues and reports need to be made.
- ### 12th June: Started with Introduction of Neural Networks. Understood the concept of Perceptrons, perceptron bias 
- ### 13th June: Sigmoid Neurons, sigmoid functions, Feedforward neural networks, recurrent neural networks, theory on A simple network designing to classify handwritten digits, algorithm to find weights and biases
- ### 16th June: Activation Functions basic, 2's complement representation, Designing a Single Neuron.
- ### 17th June: Activation Functions: ReLU and Sigmoid implementation in verilog. SigmoidContent Memory initialization file generation using python. Layer 1,2,3,4 designing in verilog, Introduction to DMA (bus arbitrator,DMA Controller,round-robin arbitration), AXI (advanced extensible interface is memory mapped) LITE Interface, AXI4 Stream, AXI4 Interface
- ### 18th June: Generation of Custom User IP using verilog IP packaging, performed software simulation by integrating AXI Stream and AXI Lite interfaces with the neural network. Got 98% accuracy with Sigmoid size 10,5 and 96% accuracy with Sigmoid size 5,5. and 90% accuracy with ReLU function. 

- ### 19th June: Created ZyNet IP (neural network IP) and integrated it with Zynq processor, AXI Interconnect, AXI DMA, and Concat.
- ### 20th June: Generated bitstrem of the zynet ip interfaced with AXI interface and DMA controller, and exported hardware to the Software Developement Kit for final deployment on the hardware
- ### 23rd June: Introduction to Image Processing on Zynq, Designed a Line Buffer (we are building a grayscale picture (512 x 512) in which 1 pixel will be of size 1 byte), Designed a MAC (multiply accumulate unit), used a 512x512 RGB image and used MATLAB for converting it into grayscale. Then used this grayscale image of size 512 x 512 to make an average normalized Box Blur of size 514 x 514. 
- ### 24th June: Designed the control logic for multiplexers and instantiation of line buffers, and storing data.
- ### 25th June: Designed testbench for the image processing
