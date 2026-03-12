
module intpolFrac_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32,	
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	ADDR_WIDTH			= 'd16,
parameter	QM						= 'd3,
parameter	QN						= 'd13,
parameter	DATAPATH_WIDTH		= 'd16
)
(
input		wire									clk,						// Señal de reloj	
input		wire									rstn,						// Reset en bajo
input		wire									start,
input		wire[DATAPATH_WIDTH-1:0]		data_from_mem,			// Datos de la memoria de entrada de la interfaz
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,       // Dirección de lectura para la memoria de la interfaz aip.
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,      // Dirección de escritura para la memoria de la interfaz aip.
output	wire									write_enable_mem,    // Señal de habilitación de escritura para la memoria de la interfaz aip.
output 	wire[DATAPATH_WIDTH-1:0]		data_out,          	// Datos de salida (decimados).
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg,			   // Registro de configuración entrante desde la interfaz aip.
output	wire[STATUS_REG_WIDTH-1:0]		status_reg				// Registro de status a escribir en la interfaz aip.
);

// -------------------------------------------------------

wire									done_flag;
wire									busy_flag;
wire									done_decim;
wire									done_intpol;
wire									start_intpol;
wire									start_decim;
wire[CONFIG_REG_WIDTH*4-1:0]	config_reg_intpol;
wire[CONFIG_REG_WIDTH*4-1:0]	config_reg_decim;

assign config_reg_intpol = { {CONFIG_REG_WIDTH*3{1'd0}}, config_reg[CONFIG_REG_WIDTH-1 -: CONFIG_REG_WIDTH]};
assign config_reg_decim = { {CONFIG_REG_WIDTH*3{1'd0}}, config_reg[CONFIG_REG_WIDTH*2-1 -: CONFIG_REG_WIDTH]};

assign status_reg 	= {6'd0, busy_flag, done_flag};  

// ---------------------------------------------------------------

intpolFrac_controlpath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.ADDR_WIDTH					(ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)		
INTFRAC_CP(
		.clk							(clk),
		.rstn                   (rstn),
		.start						(start),
		.done_intpol				(done_intpol),
		.done_decim					(done_decim),
		.start_intpol				(start_intpol),
		.start_decim				(start_decim),
		.busy_flag					(busy_flag),
		.done_flag					(done_flag)
);

intpolFrac_datapath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
		.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
		.ADDR_WIDTH					(ADDR_WIDTH),
		.QM							(QM),
		.QN							(QN),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
INTFRAC_DP(
		.clk							(clk),
		.rstn                   (rstn),
		.start_intpol				(start_intpol),
		.start_decim				(start_decim),
		.config_reg_intpol		(config_reg_intpol),
		.config_reg_decim			(config_reg_decim),
		.data_from_mem				(data_from_mem),
		.read_addr_mem				(read_addr_mem),
		.write_addr_mem			(write_addr_mem),
		.write_enable_mem			(write_enable_mem),
		.done_intpol				(done_intpol),
		.done_decim					(done_decim),
		.data_out					(data_out)
);



endmodule