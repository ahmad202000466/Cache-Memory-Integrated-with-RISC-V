module Regfile (
	input Regwrite,
	input clk,
	input rst,
	input [4:0] rs1,
	input [4:0] rs2,
	input [4:0] rd,
	input [31:0] WD3,
	output reg [31:0] RD1,
	output reg [31:0] RD2
);

// register file with 32 regsiters, each of 32 bit
reg [31:0] registers [0:31]; 
integer i;
always @(posedge clk or negedge rst) begin
	if (!rst) begin

		for (i = 0; i < 32; i = i + 1) begin
			registers [i] <= 32'b0;
		end
	end


	// load data
	if (Regwrite)
		registers [rd] <= WD3;



end
always @(*) begin
	RD1 = registers [rs1];
	RD2 = registers [rs2];
end
endmodule
	