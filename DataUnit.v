`include "PC.v"
`include "Regfile.v"
`include "ALU.v"
`include "inst_mem.v"
`include "DataMemory.v"
`include "top_module.v"

module Data (input ALUSrc, stall,RegWrite,clk,reset,Memwrite,input [1:0] ImmSrc ,PCSrc, input [2:0] ALUControl,input [1:0] ResultSrc,
output zero,
output [6:0] opcode,
output [2:0] funct3,
output funct7
);

wire [31:0] PCNext,PC,PCPlus4,RD1,RD2,ImmExt,SrcB,PCTarget,WD3,PCNextstall;
wire [31:0] RD,ReadData,ALUResult;

//RD = Instr
wire [4:0] A1,A2,A3; 
wire [31:0] Extend;
assign A1 = RD [19:15];
assign A2 = RD [24:20];
assign A3 = RD [11:7];
assign Extend = RD;


//instructions to control unit
assign opcode = RD [6:0];
assign funct3 = RD [14:12];
assign funct7 = RD [30];
// PC block
mux_4x1 PCMUX (.zero(PCPlus4),.one(PCTarget), .switch(PCSrc),.out32(PCNext),.three(ALUResult));

mux_2x1 stall (
.zero(PCNext),
 .one(PC),
.switch(stall),
.out32(PCNextstall)
);

PC_Register counter(.CLK(clk), .RSTn(reset),.PCNext(PCNextstall),.PC(PC));

PCPlus4 adder( .PC(PC),.PCPlus4(PCPlus4));


//instruction memory
instructionmemory instructions (.address(PC),.RD(RD));

//Register file

Regfile register_file (.clk(clk), .rst(reset),.Regwrite(RegWrite),.rs1(A1),.rs2(A2),.rd(A3),.WD3(WD3),.RD1(RD1),.RD2(RD2));

//ALU

mux_2x1 ALUMUX (.zero(RD2),.one(ImmExt), .switch(ALUSrc),.out32(SrcB));

ALU alu(.SrcA(RD1),.SrcB(SrcB),.ALUControl(ALUControl),.ALUResult(ALUResult),.zero(zero));

//Extender

Extend extender(.Instr(Extend),.ImmSrc(ImmSrc),.ImmExt(ImmExt));

PCTarget address_Adder(.ImmExt(ImmExt),.PC(PC),.PCTarget(PCTarget));

//data memory
DataMemory Datam  (.WE(Memwrite),.clk(clk),.address(ALUResult),.rst(reset),.write_data(RD2),.RD(ReadData));

//4x1 mux

mux_4x1 resultmux (.zero(ALUResult),.one(ReadData),.three(PCPlus4), .switch(ResultSrc),.out32(WD3));

endmodule 



module TopModule_cache (
    input clk,
    input rst,
    input [9:0] address, // Full address from the processor
    input write_data,
    input read_data,
    input [31:0] data_in,
    output [31:0] data_out,
    output stall
);



module mux_2x1 (
	input [31:0] zero,
	input [31:0] one,
	input switch,

	output reg [31:0] out32
);


always @(*) begin

		if (switch == 0)
			out32 <= zero;
		else
			out32 <= one;
end
endmodule
	

module mux_4x1 (
	input [31:0] zero,
	input [31:0] one,
	input [31:0] three,
	input [1:0] switch,

	output reg [31:0] out32
);


always @(*) begin
case (switch)
2'b00 : out32 <= zero;
2'b01 : out32 <= one;
2'b11 : out32 <= three;
default : out32 <= 0;	
endcase
end
endmodule	

	

module Extend #(parameter INSTR_WIDTH = 32, IMM_SRC_WIDTH = 2, IMM_WIDTH = 32)(
    input 		[INSTR_WIDTH-1:0] 	Instr,
    input 		[IMM_SRC_WIDTH-1:0] ImmSrc,
    output reg 	[IMM_WIDTH-1:0] 	ImmExt
);

    always @(*) begin
        case (ImmSrc)
            2'b00: // I-Type: addi, andi, ori, lw, jalr
                ImmExt = {{(IMM_WIDTH-12){Instr[31]}}, Instr[31:20]};
            2'b01: // S-Type: sw
                ImmExt = {{(IMM_WIDTH-12){Instr[31]}}, Instr[31:25], Instr[11:7]};
            2'b10: // B-Type: beq, bne
                ImmExt = {{(IMM_WIDTH-12){Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            2'b11: // J-Type: jal
                ImmExt = {{(IMM_WIDTH-20){Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            default:
                ImmExt = {IMM_WIDTH{1'b0}};
        endcase
    end

endmodule

module PCTarget #(parameter ADDR_WIDTH = 32, IMM_WIDTH = 32) (
    input 	[IMM_WIDTH-1:0]  ImmExt	,
    input 	[ADDR_WIDTH-1:0] PC		,
    output 	[ADDR_WIDTH-1:0] PCTarget
);

    assign PCTarget = PC + ImmExt;

endmodule
