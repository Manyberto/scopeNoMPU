
module substract #(
parameter	REG_WIDTH = 16	//Q12
)
(
input		wire signed [REG_WIDTH-1:0]	in1,
input		wire signed [REG_WIDTH-1:0]	in2,
output	wire signed [REG_WIDTH-1:0]	out
);

assign out = in1 - in2;	

endmodule