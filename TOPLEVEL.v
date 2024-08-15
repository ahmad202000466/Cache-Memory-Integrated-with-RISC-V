`include "DataUnit.v"
`include "Control.v"

module TOPLEVEL (input clk,reset);

wire ALUSrc,Memwrite,RegWrite;

wire [1:0] ResultSrc, ImmSrc,PCSrc;

wire [2:0] ALUControl;

wire [6:0] opcode;

wire [2:0] funct3;

wire funct7,zero;

 Data datapath (.PCSrc(PCSrc),.ALUSrc(ALUSrc), .RegWrite(RegWrite),.clk(clk),.reset(reset),.Memwrite(Memwrite),.ImmSrc(ImmSrc) , .ALUControl(ALUControl),.ResultSrc(ResultSrc),
.opcode(opcode),.funct3(funct3),.funct7(funct7),.zero(zero));

ControlUnit controlpath(.opcode(opcode),.funct3(funct3),.funct7(funct7),.zero(zero),
.PCSrc(PCSrc),.ALUSrc(ALUSrc), .RegWrite(RegWrite),.Memwrite(Memwrite),.ImmSrc(ImmSrc) , .ALUControl(ALUControl),.ResultSrc(ResultSrc)
);


endmodule