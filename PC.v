module PC_Register #(parameter ADDR_WIDTH = 32) (
    input                       CLK, RSTn, 
    input      [ADDR_WIDTH-1:0] PCNext,
    output reg [ADDR_WIDTH-1:0] PC
);

    always @(posedge CLK or negedge RSTn) begin
        if (!RSTn)
            PC <= 0;
        else
            PC <= PCNext;
    end

endmodule



module PCPlus4 #(parameter ADDR_WIDTH = 32) (
    input  [ADDR_WIDTH-1:0] PC,
    output [ADDR_WIDTH-1:0] PCPlus4
);

    assign PCPlus4 = PC + 4;

endmodule