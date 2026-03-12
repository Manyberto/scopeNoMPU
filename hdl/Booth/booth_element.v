
module booth_element #(
parameter	DATAPATH_WIDTH = 16
)
(
input		wire signed [DATAPATH_WIDTH-1:0]		data_M,
input		wire signed [DATAPATH_WIDTH-1:0]		data_Mn,
input		wire signed [DATAPATH_WIDTH-1:0]		data_P_in,
output	wire signed [DATAPATH_WIDTH-1:0]		data_P_out
);

// Declaración de parámetros locales -------------------------------------------------


// Declaración de señales ------------------------------------------------------------


wire signed [DATAPATH_WIDTH-1:0]  data_mux;
wire signed [DATAPATH_WIDTH-1:0]  data_sum;


assign data_mux = (data_P_in[1:0] == 2'd0 || data_P_in[1:0] == 2'd3) ? {DATAPATH_WIDTH{1'd0}} 
																						   : (data_P_in[1:0] == 2'd1) ? data_M 
																							: data_Mn;

assign data_sum = data_mux + data_P_in;

assign data_P_out = data_sum >>> 1;


endmodule
