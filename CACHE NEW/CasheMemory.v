module CasheMemory (
input clk, rst,
input [9:0] address,
input write_from_memory,
input [31: 0] data_in,
input [31: 0] data_in_memory,
input write_cache, //from controller
input read_cache, //from controller
output reg [31:0] data_out
);

wire [4: 0] index = address[9:2]; // 512 bytes (32 blocks)  
wire [1: 0] offset = address[1:0]; // 4 words in a block

parameter line_width = 4;
parameter mem_width = 32;
parameter mem_depth = 32;

reg [mem_width-1: 0] cache [0: mem_depth-1] [0: line_width-1]; // cashe data 32 bits, 32 blocks, 4 words

integer i;
integer j;

always @(posedge clk or negedge rst) begin
	if (!rst) begin
		data_out <= 0;
		for (i = 0; i < mem_depth; i = i + 1) begin
		for (j = 0; j < line_width; j = j + 1) begin
			cache [i][j] <= 32'b0;
		end
		end
	end

else if (write_cache) begin
	cache [index] [offset] <= data_in;
end

else if (read_cache) begin

	data_out <= cache [index][offset];
end

else if (write_from_memory) begin
	cache [index] [offset] <= data_in_memory;
end

end
endmodule