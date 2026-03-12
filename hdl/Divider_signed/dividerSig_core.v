
module dividerSig_core #(
parameter	DATAPATH_WIDTH = 16,
parameter	ELEMENTS			= 1	
)
(
input 	wire											clk,
input		wire											rstn,
input		wire											start,
input		wire signed[DATAPATH_WIDTH-1:0]		dividendo, 
input		wire signed[DATAPATH_WIDTH-1:0]		divisor,
output	wire											valid_data,
output	wire											done,
output	wire signed[DATAPATH_WIDTH-1:0]		cociente,
output	wire signed[DATAPATH_WIDTH-1:0]		residuo				
);

// Declaración de parámetros locales --------------------------

// Declaración de señales -------------------------------------

wire	sel_muxPi;
wire	enable;
wire signed[2*DATAPATH_WIDTH-1:0]	data_out;

assign cociente = data_out[DATAPATH_WIDTH-1:0];
						
assign residuo =  data_out[2*DATAPATH_WIDTH-1 -: DATAPATH_WIDTH];	

// DATAPATH ---------------------------------------------------

dividerSig_datapath #(
		.DATAPATH_WIDTH			(DATAPATH_WIDTH),
		.ELEMENTS					(ELEMENTS)
)
DDP(
		.clk							(clk),
		.rstn							(rstn),
		.valid						(valid_data),
		.sel_muxPi					(sel_muxPi),	
		.data_1						(dividendo),
		.data_2						(divisor),
		.data_out					(data_out)
);

// CONTROLPATH -------------------------------------------------

dividerSig_controlpath #(
		.DATAPATH_WIDTH			(DATAPATH_WIDTH),
		.ELEMENTS					(ELEMENTS)
)
DCP(
		.clk							(clk),
		.rstn							(rstn),
		.start						(start),
		.sel_muxPi					(sel_muxPi),
		.valid_data					(valid_data),
		.done							(done)
);

endmodule