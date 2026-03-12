
module ID0000100C_modCuad_datapath #(
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32,
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	QM						= 2,									
parameter	QN						= 11,	
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire											clk,
input		wire											rstn,
input		wire											startBoot,
input		wire signed[DATAPATH_WIDTH-1:0]		data_MemInReal,
input		wire signed[DATAPATH_WIDTH-1:0]		data_MemInImag,
output	wire											bootDone,
output	wire[DATAPATH_WIDTH+QM-1:0]			data_out
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
													


// Declaracion de señales --------------------------------------------------------------------
wire									bootDoneReal;
wire									bootDoneImag;
wire[2*DATAPATH_WIDTH-1:0]		data_PW2Real;
wire[2*DATAPATH_WIDTH-1:0]		data_PW2Imag;
wire[2*DATAPATH_WIDTH:0]		data_sum;

assign bootDone = bootDoneReal | bootDoneImag;

ID0000100C_modCuad_power2 #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH),
	.QM						(QM),
	.QN						(QN)
)
PW2_REAL (
	.clk						(clk),
	.rstn						(rstn),
	.startBoot				(startBoot),
	.data_in					(data_MemInReal),
	.data_out				(data_PW2Real),
	.bootDone				(bootDoneReal)
);

ID0000100C_modCuad_power2 #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH),
	.QM						(QM),
	.QN						(QN)
)
PW2_IMAG (
	.clk						(clk),
	.rstn						(rstn),
	.startBoot				(startBoot),
	.data_in					(data_MemInImag),
	.data_out				(data_PW2Imag),
	.bootDone				(bootDoneImag)
);

assign data_sum = data_PW2Real + data_PW2Imag; 

assign data_out = data_sum[2*DATAPATH_WIDTH-1 -: DATAPATH_WIDTH+QM];

endmodule