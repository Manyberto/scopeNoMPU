
module shifter_D_X_D3 #(
parameter			REG_WIDTH	=	16,
parameter			V_INTERP_MAX_WIDTH	= 8
)
(
input		wire [V_INTERP_MAX_WIDTH-1:0]	shift_D_X,
input		wire signed[REG_WIDTH-1:0]		shift_X_in,
output	wire signed[REG_WIDTH-1:0]		shift_X_out
);


assign shift_X_out = shift_X_in >>> shift_D_X;

endmodule
