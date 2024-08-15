
module TopModule (
    input clk,
    input rst,
    input [31:0] proc_address, // Full address from the processor
    input write_data,
    input read_data,
    input [31:0] data_in,
    output [31:0] data_out,
    output stall
);

    // Extracting tag, index, and offset from the full address
    wire [4:0] index = proc_address[10:6]; // Adjust bits according to your address mapping
    wire [1:0] offset = proc_address[5:4]; // Adjust bits according to your address mapping
    wire [24:0] tag = proc_address[31:7];  // Adjust bits according to your address mapping
    wire [9:0] address = proc_address[9:0]; // Full address bits for data memory

    // Internal signals
    wire [31:0] mem_read_data;
    wire [31:0] mem_write_data;
    wire mem_read;
    wire mem_write;
    wire valid_bit;
    wire hit;
    wire miss;

    // CasheController instantiation
    CasheController cache_controller (
        .clk(clk),
        .rst(rst),
        .index(index),
        .offset(offset),
        .tag(tag),
        .write_data(write_data),
        .read_data(read_data),
        .data_in(data_in),
        .mem_read_data(mem_read_data),
        .valid_bit(valid_bit),
        .hit(hit),
        .miss(miss),
        .mem_write_data(mem_write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .data_out(data_out),
        .stall(stall)
    );

    // CasheMemory instantiation
    CasheMemory cache_memory (
        .clk(clk),
        .rst(rst),
        .index(index),
        .offset(offset),
        .tag(tag),
        .data_in(mem_write_data),
        .write_enable(mem_write),
        .hit(hit),
        .miss(miss),
        .valid_bit(valid_bit),
        .data_out(mem_read_data)
    );

    // Data memory instantiation
    data_memory data_mem (
        .clk(clk),
        .rst(rst),
        .din(mem_write_data),
        .dout(mem_read_data),
        .wr_en(mem_write),
        .rd_en(mem_read),
        .addr(address) // Full address from processor for main memory access
    );

endmodule



module CasheController (
	input clk,//from processor
	input rst, //from processor
	input [4: 0] index, // 512 bytes (32 blocks)  from processor 
	input [1: 0] offset, // 4 words in a block
	input [24: 0] tag, // data in cashe corresponds to requested data

	input write_data, // signal enable from processor
	input read_data, // signal enable from processor

	input [31: 0] data_in,
	input [31: 0] mem_read_data, 
	
	input valid_bit, // input from cache memory
	input hit, // input from cache memory
	input miss, // input from cache memory

	output reg [31: 0] mem_write_data,
	output reg mem_read, // request enable to data memory
	output reg mem_write,// request enable to data memory

	output reg [31: 0] data_out, // data to cpu

	output reg stall // data to processor
);

reg write_enable;
reg [31: 0] cashemem_data_in;
/*
CasheMemory uut (
	.clk (clk),
	.rst (rst),
	.index (index),  
	.offset (offset), 
	.tag (tag), 
	.data_in (cashemem_data_in),
	.write_enable (write_enable),
	.hit (hit),
	.miss (miss),
	.valid_bit (valid_bit),
	.data_out (data_in)
);*/

reg [31: 0] cashe_data [0: 31] [0: 3];
reg [24: 0] tags [0: 31];
reg valids [0: 31];

// FSM states
parameter IDLE = 2'b00;
parameter READ_MEM = 2'b01;
parameter WRITE_MEM = 2'b10;

reg [1:0] current_state, next_state;


always @(posedge clk or negedge rst) begin
	if (!rst)
		current_state <= IDLE;
	else 
		current_state <= next_state;

	// IDLE status 
	case (current_state)	
		IDLE: begin
			// hit <= 0;
			// miss <= 0;
			stall <= 0;
			data_out <= 32'b0;
			mem_read <= 0;
			mem_write <= 0;
			mem_write_data <= 32'b0;
			if (read_data) 
				next_state <= READ_MEM;
			else if (write_data)
				next_state <= WRITE_MEM;
			else 
				next_state <= IDLE;
			end
		
		//LW
		READ_MEM: begin
			if (cashe_data [index][offset] == data_in && hit == 1) begin
				// hit <= 1;
				data_out <= data_in;
			end 
			else if (cashe_data [index][offset] != data_in  || miss == 1) begin
				stall <= 1; // stall signal to cpu
				// miss <= 1;
				mem_read <= 1;
				cashe_data [index][offset] <= mem_read_data;
				valids [index] <= 1;
				tags [index] <= tag;
				data_out <= mem_read_data;
				stall <= 0;
			end 
			next_state <= IDLE;
		end
		
		// SW instr
		WRITE_MEM: begin
			if (cashe_data [index][offset] == data_in && hit == 1) begin
				// hit <= 1;
				// write in cashe and data mem simultaneously
				write_enable <= 1;
				cashemem_data_in <= data_in; 
				cashe_data [index][offset] <= cashemem_data_in;
				stall <= 1;
				mem_write <= 1;
				mem_write_data <= data_in;
				stall <= 0;
			// cashe miss write to data memory only
			end 
			else if (cashe_data [index][offset] != data_in || miss == 1) begin
				// miss <= 1;
				stall <= 1;
				mem_write <= 1;
				mem_write_data <= data_in;
				valids [index] <= 1;
            			tags [index] <= tag;
				stall <= 0;
			end 
			next_state <= IDLE;
		end
		
		default: begin
			next_state <= IDLE;
		end
	endcase

end
endmodule

module CasheMemory (
input clk, rst,
input [4: 0] index, // 512 bytes (32 blocks)  
input [1: 0] offset, // 4 words in a block
input [24: 0] tag, // remaining bits in address
input [31: 0] data_in, // from data memory 

input write_enable, 

output reg hit, // output to cache controller
output reg  miss, // output to cache controller
output reg valid_bit, // output to cache controller
output reg [31:0] data_out // output to processor 
);

reg [31: 0] memory [0: 31] [0: 3]; // cashe data 32 bits, 32 blocks, 4 words
reg [24: 0] tags [0: 31];
reg valids [0: 31]; // valid bit for word 
integer i;


always @(posedge clk or negedge rst) begin
if (!rst) begin
	hit <= 0;
	miss <= 0;
	valid_bit <= 0;
	data_out <= 32'b0;
	for (i = 0; i < 32; i = i + 1) begin
		 valids[i] <= 0;
		 tags[i] <= 25'b0;
	end
end

else if (write_enable) begin
	memory [index] [offset] <= data_in;
	valids [index] <= 1;
	tags [index] <= tag;
end

else if (valids [index] == 1 && tags[index] == tag) begin
	hit <= 1;
	miss <= 0;
	data_out <= memory [index][offset];
end

else if (valids [index] == 0 || tags[index] != tag) begin
	hit <= 0;
	miss <= 1;	
end

end
endmodule

module data_memory ( clk , rst , din , dout , wr_en , rd_en , addr);

parameter addr_width = 10;
parameter mem_width = 32;
parameter mem_depth = 1024;

input wire clk , rst ;

input wire wr_en ; //from cache controller
input wire rd_en ; //from cache controller

input wire [mem_width-1:0] din; //from processor
input wire [addr_width-1:0] addr ;//from processor

output reg [mem_width-1:0] dout;

reg[addr_width-1:0] RAM[mem_depth-1:0 ] ;

always @(posedge clk )
begin
    if (rst) 
    begin
        dout<=0;
    end
    else 
    begin 
        if (wr_en)
            RAM[addr]<= din;

        if (rd_en)
            dout <= RAM[addr];
    end
end


endmodule

