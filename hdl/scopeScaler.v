
module scopeScaler #(
parameter		DATAPATH_WIDTH = 16
)
(
input 	wire											clk,
input		wire											rstn,
input		wire											start,
input		wire signed[DATAPATH_WIDTH-1:0]		data_in, 
input		wire signed[DATAPATH_WIDTH-1:0]		divisor,
output	wire											valid_data,
output	wire											done,
output	wire[7:0]									data_out		
);

localparam [DATAPATH_WIDTH-1:0]	DATASCALER = 'd205;

wire[2*DATAPATH_WIDTH-1:0]	dataMult;
wire[2*DATAPATH_WIDTH-1:0] data2Div;
wire[2*DATAPATH_WIDTH-1:0] dataDiv;

reg[7:0]							dataAcum;

wire							valid_mult;

assign data2Div = dataMult;
assign data_out = dataDiv[7:0];

booth_core #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH),
	.ELEMENTS				('d4)
)
B1(
	.clk						(clk),
	.rstn                (rstn),
	.start               (start),
	.data_1              (data_in), 
	.data_2              (DATASCALER),
	.valid_data          (valid_mult),
	.done                (),
	.data_out			   (dataMult)	
);


dividerSig_core #(
	.DATAPATH_WIDTH		(2*DATAPATH_WIDTH),
	.ELEMENTS				('d2)
)
DVD(
	.clk						(clk),
	.rstn                (rstn),
	.start               (valid_mult),
	.dividendo           (data2Div), 
	.divisor             ({ {DATAPATH_WIDTH{1'd0}}, divisor}),
	.valid_data          (valid_data),
	.done                (done),
	.cociente            (dataDiv),
	.residuo		         ()		
);

endmodule