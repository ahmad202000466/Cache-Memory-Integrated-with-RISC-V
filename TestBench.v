`include "TOPLEVEL.v"

module TestBench ();

reg clk,reset;

always  begin
clk=~clk; #20;
end

//----------Test_case----------//

initial begin

clk=0; #5
reset=1; #5	 
reset=0; #5	
reset=1;	 
	end

TOPLEVEL RISC_TEST (
.clk(clk),
.reset(reset)
);
endmodule