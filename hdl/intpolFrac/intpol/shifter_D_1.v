
module shifter_D_1 #(
parameter	REG_WIDTH = 16	//Q12
)
(
input		wire signed[REG_WIDTH-1:0]	data_in,
output	wire signed[REG_WIDTH-1:0]	data_shifted
);


assign data_shifted = data_in >>> 1;

endmodule