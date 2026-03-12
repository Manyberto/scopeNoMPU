
module ID0000100C_modCuad_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	CONFIG_REG_WIDTH	= 'd32,	
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	QM						= 'd1,
parameter	QN						= 'd16,
parameter	DATAPATH_WIDTH		= 'd17
)
(
input		wire											clk,						// Señal de reloj	
input		wire											rstn,						// Reset en bajo
input		wire											start,
input		wire[4*CONFIG_REG_WIDTH-1:0]			config_reg,
input		wire signed[DATA_WIDTH_IFC-1:0]		data_MemInReal,			// Datos de la memoria de entrada de la interfaz
input		wire signed[DATA_WIDTH_IFC-1:0]		data_MemInImag,			// Datos de la memoria de entrada de la interfaz
output	wire[MEM_IFC_MAX_WIDTH-1:0]			read_addr_mem,       // Dirección de lectura para la memoria de la interfaz aip.
output	wire[MEM_IFC_MAX_WIDTH-1:0]			write_addr_mem,      // Dirección de escritura para la memoria de la interfaz aip.
output	wire											write_enable_mem,    // Señal de habilitación de escritura para la memoria de la interfaz aip.
output	wire[STATUS_REG_WIDTH-1:0]				status_reg,		    // Señal de habilitación de escritura para la memoria de la interfaz aip.
output 	wire signed[DATAPATH_WIDTH+QM-1:0]	data_out	       	// Datos de salida (decimados).
);

// -----------------------------------------------------

wire[MEM_IFC_MAX_WIDTH-1:0]	data2pow;
wire									bootDone;
wire									startBoot;
wire									done_flag;
wire									busy_flag;

assign data2pow = config_reg[MEM_IFC_MAX_WIDTH-1:0];
assign status_reg = {6'd0, busy_flag, done_flag};  

// ---------------------------------------------------------------

ID0000100C_modCuad_controlpath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH)
)		
modCuad_CP(
		.clk							(clk),
		.rstn                   (rstn),
		.start						(start),
		.bootDone					(bootDone),	
		.data2pow					(data2pow),
		.read_addr_mem				(read_addr_mem),
		.write_addr_mem			(write_addr_mem),
		.write_enable_mem			(write_enable_mem),
		.startBoot					(startBoot),
		.busy_flag					(busy_flag),
		.done_flag					(done_flag)
);

ID0000100C_modCuad_datapath #(
		.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
		.QM							(QM),
		.QN							(QN),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
modCuad_DP(
		.clk							(clk),
		.rstn                   (rstn),
		.startBoot					(startBoot),
		.data_MemInReal			(data_MemInReal[DATAPATH_WIDTH-1:0]),
		.data_MemInImag			(data_MemInImag[DATAPATH_WIDTH-1:0]),
	   .bootDone					(bootDone),	
		.data_out					(data_out)
);



endmodule