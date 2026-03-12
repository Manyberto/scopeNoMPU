
module ID00001012_scopeSignalMapper_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	AVG_WIDTH			= 'd16,
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	CONFIG_REG_WIDTH	= 'd32,	
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	DATAPATH_WIDTH		= 'd17
)
(
input		wire									clk,						// Señal de reloj	
input		wire									rstn,						// Reset en bajo
input		wire									start,
input		wire									avgRound1Cmp,
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg,			   // Registro de configuración entrante desde la interfaz aip.
input		wire[AVG_WIDTH-1:0]				avg,					// Datos de la memoria de entrada de la interfaz
input		wire[DATAPATH_WIDTH-1:0]		data_in,					// Datos de la memoria de entrada de la interfaz
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,
output	wire									write_enable_mem,
output 	wire									data_out,       		// Datos de salida (decimados).
output	wire									wr_en_local_bit,
output	wire[4:0]							local_bit,
output	wire[STATUS_REG_WIDTH-1:0]		status_reg				// Registro de status a escribir en la interfaz aip.
);

// -----------------------------------------------------

localparam	RD_ADDR_WIDTH		= 'd9;

// -------------------------------------------------------

wire									acc_on;
wire									clearMax;
wire									enableMax;

wire									map_on;
wire[8:0]							row;
wire[8:0]							col;

wire									startScaler;
wire									startAvg;
wire									doneAvg;
wire									doneScaler;

wire[RD_ADDR_WIDTH-1:0]			wr_addr_local;
wire[RD_ADDR_WIDTH-1:0]			rd_addr_local;


wire									done_flag;
wire									busy_flag;
assign status_reg = {6'd0, busy_flag, done_flag};  

// ---------------------------------------------------------------

ID00001012_scopeSignalMapper_controlpath #(
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.RD_ADDR_WIDTH				(RD_ADDR_WIDTH),
		.AVG_WIDTH					(AVG_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)		
SCOPEMAPPER_CP(
		.clk							(clk),
		.rstn                   (rstn),
		.start						(start),
		.doneAvg						(doneAvg),
		.doneScaler					(doneScaler),
		.avg							(avg),
		.avgRound1Cmp				(avgRound1Cmp),
		.acc_on						(acc_on),
		.read_addr_mem				(read_addr_mem),
		.write_addr_mem			(write_addr_mem),
		.write_enable_mem			(write_enable_mem),
		.wr_en_local_bit			(wr_en_local_bit),
		.startAvg					(startAvg),
		.startScaler				(startScaler),
		.wr_addr_local				(wr_addr_local),
		.rd_addr_local				(rd_addr_local),
		.clearMax					(clearMax),
		.enableMax					(enableMax),
		.map_on						(map_on),
		.row							(row),
		.col							(col),
		.local_bit					(local_bit),
		.busy_flag					(busy_flag),
		.done_flag					(done_flag)
);

ID00001012_scopeSignalMapper_datapath #(
		.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
		.AVG_WIDTH					(AVG_WIDTH),
		.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
		.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
		.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
		.RD_ADDR_WIDTH				(RD_ADDR_WIDTH),
		.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
SCOPEMAPPER_DP(
		.clk							(clk),
		.rstn                   (rstn),
		.acc_on						(acc_on),
		.map_on						(map_on),
		.row							(row),
		.col							(col),
		.clearMax					(clearMax),
		.enableMax					(enableMax),
		.startAvg					(startAvg),
		.startScaler				(startScaler),
		.config_reg					(config_reg),
		.wr_addr_local				(wr_addr_local),
		.rd_addr_local				(rd_addr_local),
		.avg							(avg),	
		.data_in						(data_in),	
		.doneAvg						(doneAvg),
		.doneScaler					(doneScaler),
		.data_out					(data_out)
);

endmodule