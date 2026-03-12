

module mux_p_xi_base_D3 #(
parameter				QN_WIDTH = 15,
parameter				REG_WIDTH = 16,
parameter				V_INTERP_MAX_WIDTH = 7,
parameter				SEL_INTERP_WIDTH = 3
)
(
input		wire												clk,
input		wire												reset,
input		wire signed[REG_WIDTH-1:0]					P1,
input		wire signed[REG_WIDTH-1:0]					P2,
input		wire[SEL_INTERP_WIDTH-1:0]					SEL_INTERP,
input		wire[V_INTERP_MAX_WIDTH-1:0]				shift_D_X,
input		wire[V_INTERP_MAX_WIDTH-1:0]				shift_D_2X,
output	wire[REG_WIDTH-1:0]							p1_xi_base,
output	wire[REG_WIDTH-1:0]							p2_xi2_base
);


wire	signed[REG_WIDTH-1:0]	shift_in_xi_div_X;

wire	signed[REG_WIDTH-1:0]	shift_in_xi2_div_X;

wire	signed[REG_WIDTH-1:0]	shift_out_xi_div_X;

wire	signed[REG_WIDTH-1:0]	shift_out_xi2_div_X;

assign	shift_in_xi_div_X = P1; 
 
assign	shift_in_xi2_div_X = P2; 


assign p1_xi_base = shift_out_xi_div_X;
assign p2_xi2_base = shift_out_xi2_div_X;

// Shifter (Divisor/X)  :: Instancia
shifter_D_X_D3	#(
			.REG_WIDTH					(REG_WIDTH),
			.V_INTERP_MAX_WIDTH		(V_INTERP_MAX_WIDTH)
)
DIVISOR_P1_X (
			.shift_D_X		(shift_D_X),
			.shift_X_in		(shift_in_xi_div_X),
			.shift_X_out	(shift_out_xi_div_X)
);

// Fin instancia 
// --------------------------------------------------------------------------------

// Shifter (Divisor/X)  :: Instancia
shifter_D_X_D3	#(
			.REG_WIDTH					(REG_WIDTH),
			.V_INTERP_MAX_WIDTH		(V_INTERP_MAX_WIDTH)
)
DIVISOR_P2_X (
			.shift_D_X		(shift_D_2X),
			.shift_X_in		(shift_in_xi2_div_X),
			.shift_X_out	(shift_out_xi2_div_X)
);

// Fin instancia 
// --------------------------------------------------------------------------------



endmodule