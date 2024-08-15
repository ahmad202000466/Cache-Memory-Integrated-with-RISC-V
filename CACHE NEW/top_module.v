`include "CasheMemory.v"
`include "CasheController.v"
`include "data_memory.v"

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

    // Internal signals
	wire [31:0] mem_read_data;
	wire [31:0] mem_write_data;
	wire mem_read;
	wire mem_write;
	wire valid_bit;
	wire read_cache;
	wire write_cache;
	wire read_data_memory;
	wire write_data_memory;
	wire write_from_memory;
	wire ready;
	wire data_from_memory_to_cache;

    // CasheController instantiation
CasheController cache_controller(.clk(clk),.rst(rst),.address(address),.write_data(write_data),.read_data(read_data),.ready(ready),.read_cache(read_cache),.write_cache(write_cache),.stall(stall),
.read_data_memory(read_data_memory),
.write_data_memory(write_data_memory),
.write_from_memory(write_from_memory)
);

    // Data memory instantiation
    data_memory data_mem (
        .clk(clk),
        .rst(rst),
        .din(data_in),
        .dout(data_from_memory_to_cache),
        .wr_en(write_data_memory),
        .rd_en(read_data_memory),
        .address(address),
	.ready(ready)
    );


    // cache memory instantiation
CasheMemory cache_memory(
        .clk(clk),
        .rst(rst),
        .address(address),
.write_from_memory(write_from_memory),
        .data_in(data_in),
.data_in_memory(data_from_memory_to_cache),
.read_cache(read_cache),.write_cache(write_cache),
.data_out(data_out)
);



endmodule
