
module ID0000100C_modCuad_power2 #(
parameter	DATAPATH_WIDTH = 'd16,
parameter	QM					= 'd1,
parameter	QN					= 'd16
)
(
input		wire										clk,
input		wire										rstn,
input		wire										startBoot,
input		wire signed[DATAPATH_WIDTH-1:0]	data_in,
output	wire[2*DATAPATH_WIDTH-1:0]			data_out,
output	wire										bootDone
);

wire signed[2*DATAPATH_WIDTH-1:0]		data_mult;

booth_core #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH),
	.ELEMENTS				('d4)
)
DUT(
	.clk						(clk),
	.rstn                (rstn),
	.start               (startBoot),
	.data_1              (data_in), 
	.data_2              (data_in),
	.valid_data          (),
	.done                (bootDone),
	.data_out			   (data_mult)	
);


//assign data_mult = data_in * data_in;
//assign bootDone = 1'd1;

assign data_out = data_mult;

endmodule