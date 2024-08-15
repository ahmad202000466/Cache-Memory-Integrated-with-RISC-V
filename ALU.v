module ALU (
	// write enable
	input [31:0] SrcB,
	input [31:0] SrcA,
	input [2:0] ALUControl,

	output reg [31:0] ALUResult,
output zero
//output zero
);


always @(*) begin


		case (ALUControl)
			3'b000: ALUResult <= SrcA + SrcB; // addition
			3'b001: ALUResult <= SrcA - SrcB; // sub
			3'b101: ALUResult <= (SrcA < SrcB) ? 32'b1 : 32'b0; // slt
			3'b011: ALUResult <= SrcA | SrcB; // or
			3'b010: ALUResult <= SrcA & SrcB; // and
			default: ALUResult <= 32'b0;
		endcase
end
assign zero = (ALUResult == 32'b0);
endmodule
	