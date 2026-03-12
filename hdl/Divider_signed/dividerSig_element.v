
module dividerSig_element #(
parameter	DATAPATH_WIDTH = 16
)
(
input		wire												valid,
input		wire signed [DATAPATH_WIDTH-1:0]			data_m,
input		wire signed [2*DATAPATH_WIDTH-1:0]		data_P_in,
output	wire signed [2*DATAPATH_WIDTH-1:0]		data_P_out
);

// Declaración de parámetros locales -------------------------------------------------
localparam DIVIDER_WIDTH = 2*DATAPATH_WIDTH;

// Declaración de señales ------------------------------------------------------------

wire											sel3;
wire signed [DIVIDER_WIDTH-1:0]		data_shifted;
wire signed [DATAPATH_WIDTH-1:0]  	data_mux;
wire signed [DATAPATH_WIDTH-1:0]  	data_acc;
wire signed [DATAPATH_WIDTH-1:0]  	data_sum;

assign sel3 = ((data_sum == {DATAPATH_WIDTH{1'd0}} && valid == 1'd1) || data_sum[DATAPATH_WIDTH-1] == data_shifted[DIVIDER_WIDTH-1]) ? 1'd0 : 1'd1;

assign data_shifted = data_P_in << 1;

assign data_sum = data_shifted[DIVIDER_WIDTH-1 -: DATAPATH_WIDTH] + data_m;

assign data_acc = (sel3 == 1'd1) ? data_shifted[DIVIDER_WIDTH-1 -: DATAPATH_WIDTH] : data_sum;

assign data_P_out[DIVIDER_WIDTH-1:1] = {data_acc, data_shifted[DATAPATH_WIDTH-1:1]};

assign data_P_out[0] = (sel3 == 1'd1) ? 1'd0 : 1'd1;

endmodule
