module ControlUnit (
input [6:0] opcode,
 input [2:0] funct3,
 input funct7,
input zero,
output  [1:0] PCSrc,
output  [1:0] ResultSrc,
output  [1:0] ImmSrc,
output  Memwrite,
output  Memread,
output  ALUSrc,
output  [2:0] ALUControl,
output  RegWrite
);
wire [2:0] ALUOp;
wire op5 = opcode[5];
ControlDecoder CU1 (.opcode(opcode),.zero(zero), .nonzero(nonzero),.PCSrc(PCSrc),.ResultSrc(ResultSrc),.ImmSrc(ImmSrc),.Memwrite(Memwrite),.ALUSrc(ALUSrc),.ALUOp(ALUOp),.RegWrite(RegWrite));

ALUDecoder CU2  (
.ALUOp(ALUOp),.funct3(funct3),.funct7(funct7),.op5(op5),.ALUControl(ALUControl));

endmodule 


module ControlDecoder(
input [6:0] opcode,
input zero, nonzero,
output [1:0] PCSrc,
output reg [1:0] ResultSrc,
output  reg [1:0] ImmSrc,
output reg Memwrite,
output reg  ALUSrc,
output reg [2:0] ALUOp,
output reg RegWrite

);

reg branch, jump,jalr;

always@ (*)begin

		//initialization
		RegWrite = 0; 
		ImmSrc = 2'b00 ; 
		ALUSrc = 0 ; 
		Memwrite = 0; 
		ResultSrc = 2'b00; 
		branch = 0; 
		ALUOp = 2'b00 ;
		jump = 0; 
Memread = 0;
branchne = 0;
jalr = 0;

case (opcode)

//R-type
	7'b0110011 : begin 
		RegWrite = 1; 
		ImmSrc = 2'bxx ; 
		ALUSrc = 0 ; 
		Memwrite = 0; 
		ResultSrc = 2'b00; 
		branch = 0; 
		ALUOp = 2'b10 ;
		jump = 0; //ImmSrc = xx
		jalr = 0;
Memread = 0;
end




//I-type ALU
7'b0010011 : begin 
RegWrite = 1; 
ImmSrc = 2'b00 ; 
ALUSrc = 1 ; 
Memwrite = 0; 
ResultSrc = 2'b00; 
branch = 0; 
ALUOp = 2'b10 ; 
jump = 0;
jalr = 0;
branchne = 0;
Memread = 0;
end

//I-type : lw
7'b0000011 : begin
RegWrite = 1; 
ImmSrc = 2'b00 ;
 ALUSrc = 1 ; 
Memwrite = 0; 
ResultSrc = 2'b01; 
branch = 0; 
ALUOp = 2'b00 ; 
jump = 0;
jalr = 0;
branchne = 0;
Memread = 1;
end

//I-type : jalr
7'b1100111: begin
RegWrite = 1; 
ImmSrc = 2'b00 ; //
ALUSrc = 1 ; 
Memwrite = 0; 
ResultSrc = 2'b11; 
branch = 0; 
ALUOp = 2'b10 ; 
jump = 1; //ALUSrc = x , ALUOp = xx
jalr = 1;
branchne = 0;
Memread = 0;
end
//B-type : beq

7'b1100011 : begin
RegWrite = 0; 
ImmSrc = 2'b10 ; 
ALUSrc = 0 ; 
Memwrite = 0; 
ResultSrc = 2'bxx; 
branch = 1; 
ALUOp = 2'b01 ; 
jump = 0;
jalr = 0;
branchne = 0;
Memread = 0;
end
//B-type : bne

7'b1100011 : begin
RegWrite = 0; 
ImmSrc = 2'b10 ; 
ALUSrc = 0 ; 
Memwrite = 0; 
ResultSrc = 2'bxx; 
branch = 0; 
ALUOp = 2'b01 ; 
jump = 0;
jalr = 0;
branchne = 1;
Memread = 0;
end
//J-type : jal
7'b1101111: begin
RegWrite = 1; 
ImmSrc = 2'b11 ; 
ALUSrc = 1'bx ; 
Memwrite = 0; 
ResultSrc = 2'b11; 
branch = 0; 
ALUOp = 2'bxx ; 
jump = 1; //ALUSrc = x , ALUOp = xx
jalr = 0;
branchne = 0;
Memread = 0;
end
//S-type : sw
7'b0100011 : begin
RegWrite = 0; 
ImmSrc = 2'b01 ; 
ALUSrc = 1 ; 
Memwrite = 1;
 ResultSrc = 2'bxx; 
branch = 0; 
ALUOp = 2'b00 ; 
jump = 0;
jalr = 0;
branchne = 0;
Memread = 0;
end



endcase
end
assign PCSrc[0] = ((zero & branch) | (jump)) | (branchne & ~zero);
assign PCSrc[1] = jalr;


endmodule


module ALUDecoder (
input [2:0] ALUOp,
input [2:0] funct3,
input funct7,
input op5,
output reg [2:0] ALUControl
);
always @ (*) begin
case (ALUOp)

2'b00 : begin
ALUControl = 3'b000; // lw,sw
end

2'b01 : begin
ALUControl = 3'b001; // beq
end

2'b10 : begin

case (funct3)
3'b000: begin
if ({op5, funct7} == 2'b11)
ALUControl = 3'b001;	//sub
else
ALUControl = 3'b000;	//add
end
3'b010: ALUControl = 3'b101;	//slt
3'b110: ALUControl = 3'b011;	//or
3'b111: ALUControl = 3'b010;	//and
endcase
end



endcase
end

endmodule





