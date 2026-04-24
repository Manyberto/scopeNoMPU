
module ID00001011_scopeNoMPU_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	CONFIG_REG_WIDTH	= 'd32,	
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	DATAPATH_WIDTH		= 'd17
)
(
input		wire									clk,						// Señal de reloj	
input		wire									rstn,						// Reset en bajo
input		wire									start,
input		wire									zoomButton,
input		wire									valid_data,
input		wire									scopeFreeze,
input		wire[DATA_WIDTH_IFC-1:0]		data_MemInReal,			// Datos de la memoria de entrada de la interfaz
input		wire[DATA_WIDTH_IFC-1:0]		data_MemInImag,			// Datos de la memoria de entrada de la interfaz
input		wire[DATAPATH_WIDTH-1:0]		dataStreamReal_in,
input		wire[DATAPATH_WIDTH-1:0]		dataStreamImag_in,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,       // Dirección de lectura para la memoria de la interfaz aip.
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg,			   // Registro de configuración entrante desde la interfaz aip.
output 	wire									nRST,					// Reset to display
output 	wire									SDA,					// Serial data to/from the display.
output 	wire									SCL,					// Clock to the display.
output 	wire									nCS,					// Chip select for the display.
output	wire[STATUS_REG_WIDTH-1:0]		status_reg				// Registro de status a escribir en la interfaz aip.
);

// -----------------------------------------------------

localparam	ADDR_WIDTH			= 'd13;
localparam	AVG_WIDTH			= 'd16;

// -------------------------------------------------------

wire									avgRound1Cmp;

wire									startDecim;
wire									startFFT;
wire									startModCuad;
wire									startMultirate;
wire									startMapper;
wire									startScope;

wire									doneDecim;
wire									doneFFT;
wire									doneModCuad;
wire									doneMultirate;
wire									doneMapper;
wire									doneScope;


wire[AVG_WIDTH-1:0]				avg;
wire[CONFIG_REG_WIDTH-1:0]		config_regScope;
wire[3:0]							config_upperDotWidth;							
wire[3:0]							config_lowerDotWidth;
wire[2*CONFIG_REG_WIDTH-1:0]	config_regIntpolFrac;
wire[CONFIG_REG_WIDTH-1:0]		config_regDecim;
							

wire									done_flag;
wire									busy_flag;
assign status_reg = {6'd0, busy_flag, done_flag};

assign config_lowerDotWidth = config_reg[19:16];  
assign config_upperDotWidth = config_reg[23:20];  
assign avg						= config_reg[AVG_WIDTH-1:0];

assign config_regDecim = config_reg[2*CONFIG_REG_WIDTH-1 -:CONFIG_REG_WIDTH];
assign config_regIntpolFrac = config_reg[4*CONFIG_REG_WIDTH-1 -: 2*CONFIG_REG_WIDTH];

// ---------------------------------------------------------------

ID00001011_scopeNoMPU_controlpath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
		.AVG_WIDTH					(AVG_WIDTH)
)		
SCOPENOMPU_CP(
		.clk							(clk),
		.rstn                   (rstn),
		.mode							(config_regDecim[CONFIG_REG_WIDTH-1]),
		.start						(start),
		.scopeFreeze				(scopeFreeze),
		.avg							(avg),
		.doneDecim					(doneDecim),
		.doneFFT						(doneFFT),
		.doneModCuad				(doneModCuad),
		.doneMultirate				(doneMultirate),
		.doneMapper					(doneMapper),
		.doneScope					(doneScope),
		.config_regScope			(config_regScope),
		.startDecim					(startDecim),
		.startFFT					(startFFT),
		.startModCuad				(startModCuad),
		.startMultirate			(startMultirate),
		.startMapper				(startMapper),
		.startScope					(startScope),
		.avgRound1Cmp				(avgRound1Cmp),
		.busy_flag					(busy_flag),
		.done_flag					(done_flag)
);

ID00001011_scopeNoMPU_datapath #(
		.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
		.AVG_WIDTH					(AVG_WIDTH),
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
		.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
		.ADDR_WIDTH					(ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
SCOPENOMPU_DP(
		.clk							(clk),
		.rstn                   (rstn),
		.start                  (start),
		.zoomButton             (zoomButton),
		.avgRound1Cmp           (avgRound1Cmp),
		.config_upperDotWidth	(config_upperDotWidth),
		.config_lowerDotWidth	(config_lowerDotWidth),
		.valid_data					(valid_data),
		.startDecim					(startDecim),
		.startFFT					(startFFT),
		.startModCuad				(startModCuad),
		.startMultirate			(startMultirate),
		.startMapper				(startMapper),
		.startScope					(startScope),
		.avg							(avg),
		.config_regDecimExt		(config_regDecim),
		.config_regIntpolFrac	(config_regIntpolFrac),
		.config_regScope			(config_regScope),
		.data_MemInReal			(data_MemInReal),
		.data_MemInImag			(data_MemInImag),
		.dataStreamReal_in		(dataStreamReal_in),
		.dataStreamImag_in		(dataStreamImag_in),
		.read_addr_mem				(read_addr_mem),
		.doneDecim					(doneDecim),
		.doneFFT						(doneFFT),
		.doneModCuad				(doneModCuad),
		.doneMultirate				(doneMultirate),
		.doneMapper					(doneMapper),
		.doneScope					(doneScope),
		.nRST							(nRST),		
		.SDA	               	(SDA),	
		.SCL	               	(SCL),	
		.nCS	               	(nCS)
);



endmodule