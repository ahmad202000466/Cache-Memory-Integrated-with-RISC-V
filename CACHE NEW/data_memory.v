module data_memory (
    input wire clk,
    input wire rst,
    input wire wr_en,  // from cache controller
    input wire rd_en,  // from cache controller
    input wire [31:0] din, // from processor
    input wire [9:0] address, // from processor
    output reg [31:0] dout,
output reg ready
);

parameter line_width = 4;
parameter mem_width = 32;
parameter mem_depth = 256;
integer i;
integer j;

wire [4: 0] index = address[9:2]; // 512 bytes (32 blocks)  
wire [1: 0] offset = address[1:0]; // 4 words in a block

// Declare memory
reg [mem_width-1: 0] RAM [0: mem_depth-1] [0: line_width-1];

always @(posedge clk or negedge rst) begin
	if (!rst) begin

		for (i = 0; i < mem_depth; i = i + 1) begin
		for (j = 0; j < line_width; j = j + 1) begin
			RAM [i][j] <= 32'b0;
		end
		end
	end
    else begin
        if (wr_en) begin
            RAM[index][offset] <= din;
        end
        if (rd_en) begin
            dout <= RAM[index][offset];
	ready <= 1;
        end
    end
end

endmodule
