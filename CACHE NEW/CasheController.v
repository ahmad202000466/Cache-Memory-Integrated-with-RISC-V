module CasheController (
	input clk,
	input rst,
	input [9:0] address,
	input write_data, // signal from cpu
	input read_data, 
	input ready,
	output reg read_cache,
	output reg write_cache,
	output reg read_data_memory,
	output reg write_data_memory,
	output reg write_from_memory,
	output reg stall
);
	wire [4: 0] index = address[6:2]; // 512 bytes (32 blocks)  
	wire [1: 0] offset = address[1:0]; // 4 words in a block
	wire [2: 0] tag = address[9:7]; // data in cashe corresponds to requested data

reg hit, miss;

reg [2: 0] tags [0: 31];
reg valids [0: 31];

// FSM states
parameter IDLE = 2'b00;
parameter READ_MEM = 2'b01;
parameter WRITE_MEM = 2'b10;
integer i;

reg [1:0] current_state, next_state;

always @(posedge clk or negedge rst) begin
	if (!rst)
		current_state <= IDLE;
	else 
		current_state <= next_state;

	// IDLE status 
	case (current_state)	
		IDLE: begin
			stall <= 0;
			read_cache <= 0;
			write_cache <= 0;
			read_data_memory <=0;
			write_data_memory <=0;
			hit <= 0;
			miss <= 0;
			for (i = 0; i < 32; i = i + 1) begin
		 		valids[i] <= 0;
		 		tags[i] <= 3'b0;
			end

			if (read_data) 
				next_state <= READ_MEM;
			else if (write_data)
				next_state <= WRITE_MEM;
			else 
				next_state <= IDLE;
			end
		
		//LW
		READ_MEM: begin
if (valids [index] == 1 && tags[index] == tag && read_data == 1) begin
	hit <= 1;
	miss <= 0;
	read_cache <=1;
	stall <=0;
	
end
else if  (valids [index] == 0 || tags[index] != tag && read_data == 1 && ready ==0) begin
	hit <= 0;
	miss <= 1;
	stall <=1;
	read_data_memory <=1;
	next_state <= WRITE_MEM;
	
end

else begin
next_state <= IDLE;
end
end
		// SW instr
		WRITE_MEM: begin
			if (tags[index] == tag && write_data == 1) begin	//write to cache and data
				hit <= 1;
				miss <= 0;
				stall <=0;
				write_cache <= 1;
				write_data_memory <=1;
			end 
			else if (ready == 1) begin	//write to cache from data
				write_from_memory <=1;
				tags[index] <= tag;
				valids [index] <= 1;
				//write_cache <= 1;
			next_state <= READ_MEM;
			end 
			else if (tags[index] != tag && write_data == 1) begin	//write to data only
				hit <= 0;
				miss <= 1;
				stall <= 0;
				write_data_memory <=1;
				write_cache <= 0;
			end 
			else begin
			next_state <= IDLE;
			end
		end
		
		default: begin
			next_state <= IDLE;
		end
	endcase

end
endmodule








//always @(posedge clk or negedge rst) begin
//if (!rst) begin
//	hit <= 0;
//	miss <= 0;
//	valid_bit <= 0;
//	data_out <= 32'b0;
//	for (i = 0; i < 32; i = i + 1) begin
//		 valids[i] <= 0;
//		 tags[i] <= 25'b0;
//	end
//end
//
//else if (write_enable) begin
//	memory [index] [offset] <= data_in;
//	valids [index] <= 1;
//	tags [index] <= tag;
//end
//
//else if (valids [index] == 1 && tags[index] == tag) begin
//	hit <= 1;
//	miss <= 0;
//	data_out <= memory [index][offset];
//end
//
//else if (valids [index] == 0 || tags[index] != tag) begin
//	hit <= 0;
//	miss <= 1;	
//end
//
//end
//endmodule
//else if (valids [index] == 1 && tags[index] == tag) begin
//	hit <= 1;
//	miss <= 0;
//	data_out <= memory [index][offset];
//end
//
//			if (cashe_data [index][offset] == data_in && hit == 1) begin
//				// hit <= 1;
//				data_out <= data_in;
//			end 
//			else if (cashe_data [index][offset] != data_in  || miss == 1) begin
//				stall <= 1; // stall signal to cpu
//				// miss <= 1;
//				mem_read <= 1;
//				cashe_data [index][offset] <= mem_read_data;
//				valids [index] <= 1;
//				tags [index] <= tag;
//				data_out <= mem_read_data;
//				stall <= 0;
//			end 
//			next_state <= IDLE;
//		end
