module instructionmemory #(parameter Width = 32)(
    input [Width-1:0] address,
    output [Width-1:0] RD
    );

// Declare a 16x32-bit memory array
reg [Width-1:0] mem1[0:31];

// Initialize memory with data from the file
initial begin

    $readmemh("W:/RISC V Final Project/instructions.txt", mem1);
end


assign RD = mem1[address/4]; // Address must be in the range 0-15

endmodule