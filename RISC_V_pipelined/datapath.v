`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/11/2025 10:54:35 AM
// Design Name: 
// Module Name: datapath
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

module datapath(
    input clk,
    input reset,
    input [1:0] ResultSrcW,
    input PCJalSrcE,
    input PCSrcE,
    input ALUSrcAE,
    input [1:0] ALUSrcBE,
    input RegWriteW,
    input [2:0] ImmSrcD,
    input [3:0] ALUControlE,
    input [31:0] Instr_F,
    input [1:0] ForwardAE,
    input [1:0] ForwardBE,
    input Stall_D,
    input Stall_F,
    input Flush_D,
    input Flush_E,
    input AXI_MemWriteM,
    input AXI_MemReadM,

    input awready_dp,
    input wready_dp,
    input bvalid_dp,
    input [1:0] bresp_dp,
    input arready_dp,
    input rvalid_dp,
    input [31:0] rdata_dp,
    input [1:0] rresp_dp,
    
    input stall_axi, // NEW: AXI stall input

    output Zero_E,
    output Sign_E,
    output [31:0] PCF,
    output [31:0] Instr_D,
    output [31:0] ALUResultM,
    output [31:0] WriteDataM,
    output [4:0] rs1_D, rs2_D, rs1_E, rs2_E,
    output [4:0] rd_E, rd_M, rd_W,
    output [31:0] ResultW,
    output reg awvalid_dp,
    output reg [31:0] awaddr_dp,
    output reg [2:0] awprot_dp,
    output reg wvalid_dp,
    output reg [31:0] wdata_dp,
    output reg [3:0] wstrb_dp,
    output reg bready_dp,
    output reg arvalid_dp,
    output reg [31:0] araddr_dp,
    output reg [2:0] arprot_dp,
    output reg rready_dp,
    output [31:0] ReadDataM,
    
    output [2:0] funct3M // NEW: pass funct3 to AXI bridge for byte enable
);

    // Internal Wires
    wire [31:0] PCD, PCE, PCNextF, PCplus4F, PCplus4D, PCplus4E, PCplus4M, PCplus4W;
    wire [31:0] PCTargetE, JumpTargetE;
    wire [31:0] WriteDataE, ImmExtD, ImmExtE, SrcAEfor, SrcAE, SrcBE;
    wire [31:0] RD1_D, RD2_D, RD1_E, RD2_E;
    wire [31:0] ALUResultE, ALUResultW;
    wire [31:0] ReadDataW, mem_read_data;
    wire [4:0] rd_D;
    wire MemWriteM;

    // Address Range
    localparam AXI_BASE_ADDR = 32'h4000_0000;
    localparam AXI_HIGH_ADDR = 32'h4000_FFFF;
    wire axil_write_en = MemWriteM && (ALUResultM >= AXI_BASE_ADDR && ALUResultM <= AXI_HIGH_ADDR);
    wire axil_read_en  = ~MemWriteM && (ALUResultM >= AXI_BASE_ADDR && ALUResultM <= AXI_HIGH_ADDR);

    // AXI Read Buffer
    reg [31:0] axi_read_buffer;
    reg        axi_read_valid;

    // PC logic
    mux_2_1 jalr(.A(PCTargetE), 
                 .B(ALUResultE), 
                 .select(PCJalSrcE), 
                 .out(JumpTargetE));
                 
    pc_mux pcmux(.PCplus4F(PCplus4F), 
                 .JumpTargetE(JumpTargetE), 
                 .PCSrcE(PCSrcE), 
                 .pc_next(PCNextF));
                 
    reset_ff pcSel(.clk(clk), 
                   .reset(reset), 
                   .d_in(PCNextF), 
                   .q_out(PCF), 
                   .Stall_D(~Stall_F));
                   
    adder pcadd4(.A(PCF), 
                 .B(32'd4), 
                 .out(PCplus4F));

    // IF/ID
    if_id_reg pipefd(.clk(clk), 
                     .reset(reset), 
                     .clear(Flush_D), 
                     .enable(~Stall_D),
                     .InstrF(Instr_F), 
                     .PCF(PCF), 
                     .PCplus4F(PCplus4F),
                     .InstrD(Instr_D), 
                     .PCD(PCD), 
                     .PCplus4D(PCplus4D));

    assign rs1_D = Instr_D[19:15];
    assign rs2_D = Instr_D[24:20];
    assign rd_D  = Instr_D[11:7];

    reg_file r(.clk(clk),
               .RegWrite(RegWriteW), 
               .rs1(rs1_D), 
               .rs2(rs2_D),
               .rd_w(rd_W), 
               .write_data(ResultW), 
               .RD1_D(RD1_D), 
               .RD2_D(RD2_D));

    immediate_extend im_ext(.instr(Instr_D[31:7]), 
                            .imm_src(ImmSrcD), 
                            .imm_ext(ImmExtD));

    id_ex_reg pipeidex(.clk(clk), 
                       .reset(reset), 
                       .clear(Flush_E),
                       .RD1_D(RD1_D), 
                       .RD2_D(RD2_D), 
                       .PCD(PCD), 
                       .rs1_D(rs1_D), 
                       .rs2_D(rs2_D), 
                       .rd_D(rd_D),
                       .immediate_extend_D(ImmExtD), 
                       .PCplus4D(PCplus4D),
                       .RD1_E(RD1_E), 
                       .RD2_E(RD2_E), 
                       .PCE(PCE), 
                       .rs1_E(rs1_E), 
                       .rs2_E(rs2_E), 
                       .rd_E(rd_E),
                       .immediate_extend_E(ImmExtE), 
                       .PCplus4E(PCplus4E));

    forward_Amux forwardmuxA(.RD1_E(RD1_E),
                             .write_back_result(ResultW), 
                             .ALUResult_M(ALUResultM),
                             .ForwardA(ForwardAE), 
                             .outA(SrcAEfor));
                             
    mux_2_1 srcAmux(.A(SrcAEfor), 
                    .B(32'b0),
                    .select(ALUSrcAE), 
                    .out(SrcAE));

    forward_Bmux forwardmuxB(.RD2_E(RD2_E), 
                             .write_back_result(ResultW), 
                             .ALUResult_M(ALUResultM), 
                             .ForwardB(ForwardBE), 
                             .outB(WriteDataE));
                             
    mux_3_1 srcBmux(.A(WriteDataE), 
                    .B(ImmExtE), 
                    .C(PCTargetE), 
                    .select(ALUSrcBE), 
                    .out(SrcBE));

    adder pcadder(.A(PCE), 
                  .B(ImmExtE), 
                  .out(PCTargetE));

    alu al(.SourceA(SrcAE), 
           .SourceB(SrcBE), 
           .ALUControl(ALUControlE),
           .ALUResult(ALUResultE), 
           .Zero(Zero_E), 
           .Sign(Sign_E));

    wire stall_mem = stall_axi; // stall_axi stalls Memory stage

    ex_mem_reg pipeexmem(.clk(clk), 
                         .reset(reset),
                         .ALUResult_E(ALUResultE), 
                         .write_data_E(WriteDataE), 
                         .rd_E(rd_E), 
                         .PCplus4E(PCplus4E),
                         .ALUResult_M(ALUResultM), 
                         .write_data_M(WriteDataM), 
                         .rd_M(rd_M), 
                         .PCplus4M(PCplus4M));

    // Replace with your actual memory instance
    data_memory dm(.clk(clk), 
                   .write_enable(MemWriteM && ~axil_write_en), 
                   .data_address(ALUResultM), 
                   .write_data(WriteDataM), 
                   .read_data(mem_read_data));

    // ReadDataM MUX
    assign ReadDataM = axil_read_en ? axi_read_buffer : mem_read_data;

    // AXI Master FSM (Simple)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            awvalid_dp <= 0; wvalid_dp <= 0; bready_dp <= 0;
            arvalid_dp <= 0; rready_dp <= 0; axi_read_valid <= 0;
            axi_read_buffer <= 32'b0;
        end else begin
            // AXI Write
            if (AXI_MemWriteM && !awvalid_dp && !wvalid_dp) begin
                awvalid_dp <= 1;
                awaddr_dp  <= ALUResultM;
                awprot_dp  <= 3'b000;
                wvalid_dp  <= 1;
                wdata_dp   <= WriteDataM;
                wstrb_dp   <= 4'b1111;
            end else if (awvalid_dp && awready_dp && wvalid_dp && wready_dp) begin
                awvalid_dp <= 0;
                wvalid_dp  <= 0;
                bready_dp  <= 1;
            end else if (bvalid_dp && bready_dp) begin
                bready_dp  <= 0;
            end

            // AXI Read
            if (AXI_MemReadM && !arvalid_dp && !rready_dp) begin
                arvalid_dp <= 1;
                araddr_dp  <= ALUResultM;
                arprot_dp  <= 3'b000;
            end else if (arvalid_dp && arready_dp) begin
                arvalid_dp <= 0;
                rready_dp  <= 1;
            end else if (rvalid_dp && rready_dp) begin
                axi_read_buffer <= rdata_dp;
                axi_read_valid  <= 1;
                rready_dp       <= 0;
            end
        end
    end

    mem_wb_reg pipememwb(.clk(clk), 
                         .reset(reset),
                         .ALUResult_M(ALUResultM), 
                         .read_data_M(ReadDataM), 
                         .rd_M(rd_M), 
                         .PCplus4M(PCplus4M),
                         .ALUResult_W(ALUResultW), 
                         .read_data_W(ReadDataW), 
                         .rd_W(rd_W), 
                         .PCplus4W(PCplus4W));

    wb_mux wr(.ALUResult_W(ALUResultW), 
              .read_data_W(ReadDataW), 
              .PCplus4W(PCplus4W),
              .ResultSrcW(ResultSrcW), 
              .write_back_result(ResultW));
endmodule
