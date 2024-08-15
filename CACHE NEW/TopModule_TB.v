
`include "top_module.v"

module TopModule_TB;

    reg clk;
    reg rst;
    reg [31:0] proc_address;
    reg write_data;
    reg read_data;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire stall;

    // Instantiate the top module
    TopModule uut (
        .clk(clk),
        .rst(rst),
        .proc_address(proc_address),
        .write_data(write_data),
        .read_data(read_data),
        .data_in(data_in),
        .data_out(data_out),
        .stall(stall)
    );

    // Generate clock signal
    always #20 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst = 0;
        proc_address = 32'b0;
        write_data = 0;
        read_data = 0;
        data_in = 32'b0;

        // Apply reset
        #10;
        rst = 1;

        // Test write operation
        #10;
        proc_address = 32'h00000010; // Address 16
        data_in = 32'hDEADBEEF;
        write_data = 1;
        read_data = 0;
        #10;
        write_data = 0;

        // Test read operation (should hit if write was successful)
        #10;
        proc_address = 32'h00000010; // Address 16
        read_data = 1;
        write_data = 0;
        #10;
        read_data = 0;

        // Test read operation with a different address (should miss)
        #10;
        proc_address = 32'h00000020; // Address 32
        read_data = 1;
        write_data = 0;
        #10;
        read_data = 0;

        // Finish simulation
        #50;
        $stop;
    end

endmodule

