
module coeficient_math #(
parameter	REG_WIDTH	=	31
)
(
input		wire[REG_WIDTH-1:0]		M0,
input		wire[REG_WIDTH-1:0]		M1,
input		wire[REG_WIDTH-1:0]		M2,
output	wire[REG_WIDTH-1:0]		PI,
output	wire[REG_WIDTH-1:0]		PJ,
output	wire[REG_WIDTH-1:0]		PK	
);

wire[REG_WIDTH-1:0] 				M0_P_M2;
wire[REG_WIDTH-1:0]				M0_P_M2_D2;

wire[REG_WIDTH-1:0]				M1_P_M1;
wire[REG_WIDTH-1:0]				M1_P_M1_S_M0;

// -----------------------------------------------------------------------------------
// Sumador 1 -> M2 + M0 :: Instancia
adder	#(
		.REG_WIDTH		(REG_WIDTH)
)
Add_1	(
		.in1				(M0),
		.in2				(M2),
		.out				(M0_P_M2)
);

// Fin instancia 
// -------------------------------------------------------------------------------


// Shifter (Divisor/2) -> (M2 + M0)/2 :: Instancia
shifter_D_1	#(
			.REG_WIDTH		(REG_WIDTH)
)
Shift_D_1 (
			.data_in			(M0_P_M2),
			.data_shifted	(M0_P_M2_D2)
);

// Fin instancia 
// -------------------------------------------------------------------------------


// Shifter (Multiplicador*2) -> 2M1 :: Instancia
shifter_I_1	#(
			.REG_WIDTH		(REG_WIDTH)
)
Shift_I_1 (
			.data_in			(M1),
			.data_shifted	(M1_P_M1)
);

// Fin instancia 
// --------------------------------------------------------------------------------


// Restador 1 -> 2M1 - M0 :: Instancia
substract	#(
		.REG_WIDTH		(REG_WIDTH)
)
Sub_1	(
		.in1				(M1_P_M1),
		.in2				(M0),
		.out				(M1_P_M1_S_M0)
);

// Fin instancia
// -------------------------------------------------------------------------------


// Restador 2 -> (2M1 - M0 ) - ((M2 + M0)/2 ) = P1 :: Instancia
substract	#(
		.REG_WIDTH		(REG_WIDTH)
)
Sub_2	(
		.in1				(M1_P_M1_S_M0),
		.in2				(M0_P_M2_D2),
		.out				(PJ)
);

// Fin instancia 
// --------------------------------------------------------------------------------


// Restador 3 -> M1 - ((M2 + M0)/2 ) = P2 :: Instancia
substract	#(
		.REG_WIDTH		(REG_WIDTH)
)
Sub_3	(
		.in1				(M0_P_M2_D2),
		.in2				(M1),
		.out				(PK)
);

// Fin instancia 
// ---------------------------------------------------------------------------------


assign PI = M0;

endmodule