`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2025
// Design Name: 
// Module Name: riscv_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: RISC-V top module integrated with AXI4-Lite bridge
//
// Dependencies: datapath.v, controller.v, hazard_detection_unit.v,
//               instruction_memory.v, data_memory.v, axi_lite_bridge.v
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module riscv_top(
    input clk,
    input reset,

    // AXI4-Lite Master Interface Signals
    output awvalid,
    output [31:0] awaddr,
    output [2:0] awprot,
    input awready,

    output wvalid,
    output [31:0] wdata,
    output [3:0] wstrb,
    input wready,

    input bvalid,
    input [1:0] bresp,
    output bready,

    output arvalid,
    output [31:0] araddr,
    output [2:0] arprot,
    input arready,

    input rvalid,
    input [31:0] rdata,
    input [1:0] rresp,
    input rlast,
    output rready
);

    // Instruction Fetch/Decode wires
    wire [31:0] Instr_F;
    wire [31:0] PCF;
    wire [31:0] Instr_D;
    wire [4:0] rs1_D, rs2_D, rs1_E, rs2_E, rd_E, rd_M, rd_W;

    // ALU / Control wires
    wire [31:0] ALUResultM;
    wire [31:0] WriteDataM;
    wire [3:0] ALUControlE;
    wire Zero_E, Sign_E;
    wire [1:0] ALUSrcBE, ResultSrcW;
    wire ALUSrcAE, RegWriteM, RegWriteW, PCJalSrcE, PCSrcE, ResultW;
    wire [2:0] ImmSrcD;

    // Hazard and pipeline control
    wire [1:0] ForwardAE, ForwardBE;
    wire Stall_D, Stall_F, Flush_D, Flush_E, ResultSrcE0;
    
    wire AXI_MemWriteM;
    wire AXI_MemReadM;
    

    // Controller
    controller cnt (
        .clk(clk), .reset(reset),
        .opcode(Instr_D[6:0]),
        .funct3(Instr_D[14:12]),
        .funct7bit5(Instr_D[30]),
        .Zero_E(Zero_E),
        .Sign_E(Sign_E),
        .Flush_E(Flush_E),
        .ResultSrcE0(ResultSrcE0),
        .ResultSrcW(ResultSrcW),
        .MemWriteM(MemWriteM),
        .PCJalSrcE(PCJalSrcE),
        .PCSrcE(PCSrcE),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ImmSrcD(ImmSrcD),
        .ALUControlE(ALUControlE),
        .AXI_MemWriteM(AXI_MemWriteM),
        .AXI_MemReadM(AXI_MemReadM)
    );

    // Data Memory bridge wires
    wire [31:0] DataAdrM_to_bridge = ALUResultM;
    wire [31:0] WriteDataM_to_bridge = WriteDataM;
    wire MemWriteM_to_bridge = MemWriteM;
    wire [31:0] ReadDataM_from_bridge;

    // RAM wires
    wire [31:0] ram_addr;
    wire [31:0] ram_write_data;
    wire ram_write_enable;
    wire [31:0] ram_read_data;

    // Datapath instantiation
    datapath dp (
        .clk(clk),
        .reset(reset),
        .ResultSrcW(ResultSrcW),
        .PCJalSrcE(PCJalSrcE),
        .PCSrcE(PCSrcE),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .RegWriteW(RegWriteW),
        .ImmSrcD(ImmSrcD),
        .ALUControlE(ALUControlE),
        .Instr_F(Instr_F),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .Stall_D(Stall_D),
        .Stall_F(Stall_F),
        .Flush_D(Flush_D),
        .Flush_E(Flush_E),
        .AXI_MemWriteM(AXI_MemWriteM),
        .AXI_MemReadM(AXI_MemReadM),

        .awready_dp(awready_dp),
        .wready_dp(wready_dp),
        .bvalid_dp(bvalid_dp),
        .bresp_dp(bresp_dp),
        .arready_dp(arready_dp),
        .rvalid_dp(rvalid_dp),
        .rdata_dp(rdata_dp),
        .rresp_dp(rresp_dp),

        .stall_axi(stall_axi),

        .Zero_E(Zero_E),
        .Sign_E(Sign_E),
        .PCF(PCF),
        .Instr_D(Instr_D),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .rs1_D(rs1_D),
        .rs2_D(rs2_D),
        .rs1_E(rs1_E),
        .rs2_E(rs2_E),
        .rd_E(rd_E),
        .rd_M(rd_M),
        .rd_W(rd_W),
        .ResultW(ResultW),

        .awvalid_dp(awvalid_dp),
        .awaddr_dp(awaddr_dp),
        .awprot_dp(awprot_dp),
        .wvalid_dp(wvalid_dp),
        .wdata_dp(wdata_dp),
        .wstrb_dp(wstrb_dp),
        .bready_dp(bready_dp),
        .arvalid_dp(arvalid_dp),
        .araddr_dp(araddr_dp),
        .arprot_dp(arprot_dp),
        .rready_dp(rready_dp),
        .ReadDataM(ReadDataM),

        .funct3M(funct3M)
    );

    // Hazard detection
    hazard_detection_unit hdu (
        .rs1_D(rs1_D), 
        .rs2_D(rs2_D),
        .rs1_E(rs1_E), 
        .rs2_E(rs2_E),
        .rd_E(rd_E), 
        .rd_M(rd_M), 
        .rd_W(rd_W),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ResultSrcE0(ResultSrcE0),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .Flush_E(Flush_E),
        .Flush_D(Flush_D),
        .Stall_D(Stall_D),
        .Stall_F(Stall_F)
    );

    // Instruction memory
    instruction_memory im (
        .pc(PCF),
        .instruction_data(Instr_F)
    );

    // AXI4-Lite Bridge
    axi_lite_bridge axibridge (
        .clk(clk), 
        .reset(reset),
        .mem_addr(DataAdrM_to_bridge),
        .mem_write_data(WriteDataM_to_bridge),
        .mem_write_en(MemWriteM_to_bridge),
        .mem_read_data(ReadDataM_from_bridge),
        .stall_axi(stall_axi),
        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_write_en(ram_write_enable),
        .ram_read_data(ram_read_data),
        .awvalid(awvalid), 
        .awaddr(awaddr), 
        .awprot(awprot), 
        .awready(awready),
        .wvalid(wvalid), 
        .wdata(wdata), 
        .wstrb(wstrb), 
        .wready(wready),
        .bvalid(bvalid), 
        .bresp(bresp), 
        .bready(bready),
        .arvalid(arvalid), 
        .araddr(araddr), 
        .arprot(arprot), 
        .arready(arready),
        .rvalid(rvalid), 
        .rdata(rdata), 
        .rresp(rresp), 
        .rlast(rlast),
        .rready(rready)
    );

    // Data memory (RAM)
    data_memory dm (
        .clk(clk),
        .write_enable(ram_write_enable),
        .data_address(ram_addr),
        .write_data(ram_write_data),
        .read_data(ram_read_data)
    );

endmodule
