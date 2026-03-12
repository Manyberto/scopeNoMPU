

module half_multiplier_D3 #(
parameter	REG_WIDTH = 16,
parameter	REG_WIDTH_EXT = 20, 
parameter	V_INTERP_MAX_WIDTH = 6,
parameter	QN_BASE	 		= 15,
parameter	QM_COEF	 		= 3
)
(
input		wire										clk,
input		wire										reset,
input		wire										enable,
input		wire										clear_datapath,
input		wire										acc_en,
input		wire										acc_rst,
input		wire										bypass_flag,
input		wire signed[REG_WIDTH-1:0]			P0,
input		wire signed[REG_WIDTH-1:0]			xi_base,
input		wire signed[REG_WIDTH-1:0]			xi2_base,
input		wire[V_INTERP_MAX_WIDTH-1:0]		index,
output 	wire signed[REG_WIDTH_EXT-1:0]	yi
);

wire 	signed[REG_WIDTH-1:0]	yi_inter;

reg 	signed[REG_WIDTH-1:0]	xi_acc;
reg 	signed[REG_WIDTH-1:0]	xi2_reg;
reg 	signed[REG_WIDTH-1:0]	aux_reg;

wire 	signed[REG_WIDTH-1:0]	shift_in_2;
wire 	signed[REG_WIDTH-1:0]	shift_out_2;

wire 	signed[REG_WIDTH-1:0]	add_in_1;
wire 	signed[REG_WIDTH-1:0]	add_in_2;
wire 	signed[REG_WIDTH-1:0] 	add_out;
	
wire 	signed[REG_WIDTH-1:0]	mux2_in_1;
wire 	signed[REG_WIDTH-1:0]	mux2_in_2;
wire 	signed[REG_WIDTH-1:0] 	mux2_out;

wire	rst;

assign rst = clear_datapath || ~acc_rst;

assign add_in_1 = xi2_reg;
assign add_in_2 = aux_reg;

assign shift_in_2 = xi2_base;

assign mux2_in_1 = xi2_base;
assign mux2_in_2 = shift_out_2;


assign mux2_out = (index == {V_INTERP_MAX_WIDTH{1'd0}} ) ? mux2_in_1 : mux2_in_2; 


always@(posedge clk, negedge reset)begin

	if(reset == 1'd0)begin
		xi_acc 	<= {REG_WIDTH{1'd0}};
		xi2_reg 	<= {REG_WIDTH{1'd0}};
		aux_reg 	<= {REG_WIDTH{1'd0}};
	end
	
	else begin
	
		if(rst == 1'd0)begin
			xi_acc 	<= {REG_WIDTH{1'd0}};
			xi2_reg 	<= {REG_WIDTH{1'd0}};
			aux_reg 	<= {REG_WIDTH{1'd0}};
		end
		
		else begin
	
			xi_acc 	<= xi_acc;
			xi2_reg 	<= xi2_reg;
			aux_reg	<= aux_reg;
		
			if(enable == 1'd1 && acc_en == 1'd1)begin
				xi_acc 	<= xi_acc + xi_base; 
				xi2_reg	<= add_out;
				aux_reg	<= aux_reg + mux2_out;
			end
		
		end
	
	end

end

//  Shifter (Multiplicador*2)  :: Instancia
shifter_I_1	#(
			.REG_WIDTH		(REG_WIDTH)
)
MULTI_2 (
			.data_in			(shift_in_2),
			.data_shifted	(shift_out_2)
);

// Fin instancia 
// --------------------------------------------------------------------------------

// Sumador  :: Instancia
adder	#(
		.REG_WIDTH		(REG_WIDTH)
)
ADD_1	(
		.in1				(add_in_1),
		.in2				(add_in_2),
		.out				(add_out)
);

// Fin instancia 
// -------------------------------------------------------------------------------

assign	yi_inter = (bypass_flag == 1'd1) ? P0 : P0  + xi_acc + add_out;

assign	yi = yi_inter[REG_WIDTH-3-1 -: QM_COEF-3+QN_BASE];

//assign	yi =  (yi_inter[REG_WIDTH-1] == 1'd0) ? 
//				   (yi_inter <= SATURATION) ? {yi_inter[REG_WIDTH-1], yi_inter[REG_WIDTH-QM_COEF-1 -: QN_BASE]} 
//					: SATURATION_EXT 
//					: (yi_inter > -SATURATION) ? {yi_inter[REG_WIDTH-1], yi_inter[REG_WIDTH-QM_COEF-1 -: QN_BASE]} 
//					: -SATURATION_EXT;

endmodule
