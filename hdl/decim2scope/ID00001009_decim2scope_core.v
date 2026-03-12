
module ID00001009_decim2scope_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32,	
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16
)
(
input		wire									clk,						// Señal de reloj	
input		wire									rstn,						// Reset en bajo
input		wire									start,
input		wire									valid_data,
input		wire[DATAPATH_WIDTH-1:0]		data_from_mem,			// Datos de la memoria de entrada de la interfaz
input		wire[DATAPATH_WIDTH-1:0]		data_from_mem1,			// Datos de la memoria de entrada de la interfaz
input		wire[DATAPATH_WIDTH-1:0]		data_in,					// Datos para almacenar en la memoria de datos de entrada
input		wire[DATAPATH_WIDTH-1:0]		data_in1,					// Datos para almacenar en la memoria de datos de entrada
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,       // Dirección de lectura para la memoria de la interfaz aip.
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,      // Dirección de escritura para la memoria de la interfaz aip.
output	wire									write_enable_mem,    // Señal de habilitación de escritura para la memoria de la interfaz aip.
output 	wire[DATAPATH_WIDTH-1:0]		data_out,          	// Datos de salida (decimados).
output 	wire[DATAPATH_WIDTH-1:0]		data_out1,          	// Datos de salida (decimados).
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg,			   // Registro de configuración entrante desde la interfaz aip.
output	wire[STATUS_REG_WIDTH-1:0]		status_reg				// Registro de status a escribir en la interfaz aip.
);

// -------------------------------------------------------

//wire[DATAPATH_WIDTH-1:0]	data_out_local_mem;
wire[ADDR_WIDTH-1:0]			rd_addr_local_mem;
wire[ADDR_WIDTH-1:0]			wr_addr_local_mem;
wire								wr_en_local_mem;

wire								done_flag;
wire								busy_flag;
wire[ADDR_WIDTH-1:0]			size2decim;
wire[ADDR_WIDTH-1:0]			decim_factor;
wire								op_mode;

assign status_reg = {6'd0, busy_flag, done_flag};

assign decim_factor 	= config_reg[ADDR_WIDTH-1 -: ADDR_WIDTH];
assign size2decim 	= config_reg[ADDR_WIDTH*2-1 -: ADDR_WIDTH];
assign op_mode			= config_reg[CONFIG_REG_WIDTH-1];
// -------------------------------------------------------


ID00001009_decim2scope_controlpath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.ADDR_WIDTH					(ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)		
ID00001009_DCM_CP(
		.clk							(clk),
		.rstn                   (rstn),
		.start						(start),
		.valid_data					(valid_data),
		.op_mode						(op_mode),
		.size2decim					(size2decim),
		.decim_factor				(decim_factor),
		.read_addr_mem				(read_addr_mem),
		.rd_addr_local_mem      (rd_addr_local_mem),
		.wr_addr_local_mem      (wr_addr_local_mem),
		.wr_en_local_mem		   (wr_en_local_mem),
		.wr_addr_mem_out			(write_addr_mem),
		.wr_en_mem_out				(write_enable_mem),
		.busy_flag					(busy_flag),
		.done_flag					(done_flag)
);

ID00001009_decim2scope_datapath #(
		.ADDR_WIDTH					(ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
ID00001009_DCM_DP(
		.clk							(clk),
		.rstn                   (rstn),
		.op_mode						(op_mode),
		.data_from_mem				(data_from_mem),
		.data_in					   (data_in),
		.rd_addr_local_mem      (rd_addr_local_mem),
		.wr_addr_local_mem      (wr_addr_local_mem),
		.wr_en_local_mem		   (wr_en_local_mem),
		.data_out					(data_out)
);

ID00001009_decim2scope_datapath #(
		.ADDR_WIDTH					(ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
ID00001009_DCM_DP1(
		.clk							(clk),
		.rstn                   (rstn),
		.op_mode						(op_mode),
		.data_from_mem				(data_from_mem1),
		.data_in					   (data_in1),
		.rd_addr_local_mem      (rd_addr_local_mem),
		.wr_addr_local_mem      (wr_addr_local_mem),
		.wr_en_local_mem		   (wr_en_local_mem),
		.data_out					(data_out1)
);



endmodule