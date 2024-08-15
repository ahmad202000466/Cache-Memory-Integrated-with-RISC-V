module DataMemory (
	// write enable
	input WE,
	input [31:0] address,
	input clk,
	input rst,
	// WD in the graph
	input [31:0] write_data,
	
	output [31:0] RD
);

reg [31:0] memory [0:3999];
integer i;
always @(posedge clk or negedge rst) begin
	
	if (!rst) begin

		for (i = 0; i < 4000; i = i + 1) begin
			memory [i] <= 32'b0;
		end
	end
	// SW instruction 
	if (WE) begin
		memory [address] <= write_data;
		//RD <= memory [address];
	end
	
		
end
assign RD = memory [address];
endmodule
	