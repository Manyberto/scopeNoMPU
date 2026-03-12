
module booth_core #(
parameter	DATAPATH_WIDTH = 16,
parameter	ELEMENTS			= 4	
)
(
input 	wire											clk,
input		wire											rstn,
input		wire											start,
input		wire signed[DATAPATH_WIDTH-1:0]		data_1, 
input		wire signed[DATAPATH_WIDTH-1:0]		data_2,
output	wire											valid_data,
output	wire											done,
output	wire signed[2*DATAPATH_WIDTH-1:0]	data_out			
);

// Declaración de parámetros locales --------------------------

// Declaración de señales -------------------------------------

wire	sel_muxPi;

// DATAPATH ---------------------------------------------------

booth_datapath #(
		.DATAPATH_WIDTH			(DATAPATH_WIDTH),
		.ELEMENTS					(ELEMENTS)
)
BDP(
		.clk							(clk),
		.rstn							(rstn),
		.valid						(valid_data),
		.sel_muxPi					(sel_muxPi),	
		.data_1						(data_1),
		.data_2						(data_2),
		.data_out					(data_out)
);

// CONTROLPATH -------------------------------------------------

booth_controlpath #(
		.DATAPATH_WIDTH			(DATAPATH_WIDTH),
		.ELEMENTS					(ELEMENTS)
)
BCP(
		.clk							(clk),
		.rstn							(rstn),
		.start						(start),
		.sel_muxPi					(sel_muxPi),
		.valid_data					(valid_data),
		.done							(done)
);

endmodule
