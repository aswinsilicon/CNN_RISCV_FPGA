`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/10/2025 11:17:43 PM
// Design Name: 
// Module Name: controller
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

module controller(
    input clk,
    input reset,
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7bit5,
    input Zero_E,
    input Sign_E,
    input Flush_E,
    output ResultSrcE0,
    output [1:0] ResultSrcW,
    output MemWriteM,
    output PCJalSrcE,
    output PCSrcE,
    output ALUSrcAE,
    output [1:0] ALUSrcBE,
    output RegWriteM,
    output RegWriteW,
    output [2:0] ImmSrcD,
    output [3:0] ALUControlE,
    output AXI_MemWriteM,     // Now driven properly
    output AXI_MemReadM       // Now driven properly
);

    wire [1:0] ALUOpD;
    wire [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
    wire RegWriteD, RegWriteE;
    wire [3:0] ALUControlD;
    wire ALUSrcAD;
    wire BranchD, BranchE;
    wire MemWriteD, MemWriteE;
    wire JumpD, JumpE;
    wire [1:0] ALUSrcBD;
    wire SignOp, BranchOp, ZeroOp;
    wire MemReadE;

    // Control from main decoder
    main_decoder m(
        .opcode(opcode),
        .ALUOp(ALUOpD),
        .ALUSrcA(ALUSrcAD),
        .ALUSrcB(ALUSrcBD),
        .RegWrite(RegWriteD),
        .MemWrite(MemWriteD),
        .ResultSrc(ResultSrcD),
        .Branch(BranchD),
        .Jump(JumpD),
        .ImmSrc(ImmSrcD)
    );

    // ALU operation decoding
    alu_decoder a(
        .opcodebit5(opcode[5]),
        .funct3(funct3),
        .funct7bit5(funct7bit5),
        .ALUOp(ALUOpD),
        .ALUControl(ALUControlD)
    );

    // Pipeline registers (ID/EX)
    id_ex_reg_ctrl pipe0(
        .clk(clk),
        .reset(reset),
        .clear(Flush_E),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD), 
        .JumpD(JumpD),
        .BranchD(BranchD), 
        .ALUSrcAD(ALUSrcAD),
        .ALUSrcBD(ALUSrcBD),
        .ResultSrcD(ResultSrcD),
        .ALUControlD(ALUControlD),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUSrcAE(ALUSrcAE),
        .ALUSrcBE(ALUSrcBE),
        .ResultSrcE(ResultSrcE),
        .ALUControlE(ALUControlE) 
    );

    assign ResultSrcE0 = ResultSrcE[0];

    // Pipeline registers (EX/MEM)
    ex_mem_reg_ctrl pipe1(
        .clk(clk),
        .reset(reset),
        .RegWriteE(RegWriteE),
        .MemWriteE(MemWriteE),
        .ResultSrcE(ResultSrcE),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM)
    );

    // Pipeline registers (MEM/WB)
    mem_wb_reg_ctrl pipe2(
        .clk(clk),
        .reset(reset),
        .RegWriteM(RegWriteM),
        .MemWriteM(MemWriteM),
        .ResultSrcM(ResultSrcM),
        .RegWriteW(RegWriteW),
        .MemWriteW(),                 // unused
        .ResultSrcW(ResultSrcW)
    );

    // Branch Logic
    assign ZeroOp  = Zero_E ^ funct3[0];
    assign SignOp  = Sign_E ^ funct3[0];
    assign BranchOp = funct3[2] ? SignOp : ZeroOp;

    assign PCSrcE = (BranchE & BranchOp) | JumpE;
    assign PCJalSrcE = JumpE;

    // ? Generate AXI memory operation flags based on opcode
    wire is_load_E, is_store_E;

    // Define memory opcodes
    localparam OPCODE_LOAD  = 7'b0000011;
    localparam OPCODE_STORE = 7'b0100011;

    assign is_load_E  = (opcode == OPCODE_LOAD);
    assign is_store_E = (opcode == OPCODE_STORE);

    // Pipeline them to MEM stage in your datapath; for now:
    assign AXI_MemReadM  = is_load_E;
    assign AXI_MemWriteM = is_store_E;

endmodule
