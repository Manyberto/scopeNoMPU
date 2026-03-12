
module average #(
parameter		DATAPATH_WIDTH = 'd64

)
(
input 	wire								clk,
input		wire								rstn,
input		wire								start,
input		wire[DATAPATH_WIDTH-1:0]	data_in, 
input		wire[DATAPATH_WIDTH-1:0]	avg,
output	wire								valid_data,
output	wire								done,
output	wire[7:0]						data_out		
);

wire[DATAPATH_WIDTH-1:0] 	dataDiv;

wire		  						valid_mult;

assign data_out = dataDiv[7:0];

dividerSig_core #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH),
	.ELEMENTS				('d2)
)
DVD(
	.clk						(clk),
	.rstn                (rstn),
	.start               (start),
	.dividendo           (data_in), 
	.divisor             (avg),
	.valid_data          (valid_data),
	.done                (done),
	.cociente            (dataDiv),
	.residuo		         ()		
);

endmodule