
module aipIntpol2scope #(
parameter	DATA_WIDTH 	= 16,		// Tamaño en bits de los datos de entrada
parameter	QM				= 2,									
parameter	QN				= 11							
)
(
input		wire						start,				// Señales para conexión con el bloque ipm.
output	wire						int_req,				// Señales para conexión con el bloque ipm.
input		wire						read,					// Señales para conexión con el bloque ipm.
input		wire						write,				// Señales para conexión con el bloque ipm.
input		wire[32-1:0]			datain,				// Señales para conexión con el bloque ipm.
input		wire[4:0]				config_dbus,		// Señales para conexión con el bloque ipm.	
output 	wire[32-1:0]			dataout,				// Señales para conexión con el bloque ipm.
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
input		wire						clk,					// Señal de reloj	
input		wire						rstn					// Reset en bajo														
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

localparam						DATA_WIDTH_IFC		= 32;												// Tamaño de palabra para la interfaz ipm
localparam						DATAPATH_WIDTH 	= DATA_WIDTH;

localparam 						CONFIG_REG_WIDTH	= 32;													// Ancho de palabra del config reg			-> NO CAMBIAR 
localparam 						STATUS_REG_WIDTH	= 8;                          				// Ancho de palabra del status reg  		-> NO CAMBIAR
											
localparam						MEM_IFC_MAX_WIDTH	= 16;													// Profundidad de memorias en la interfaz aip.
localparam						DATA_WIDTH_DIFF	= ((DATA_WIDTH_IFC-DATAPATH_WIDTH) > 0) ? 
																DATA_WIDTH_IFC-DATAPATH_WIDTH : 0;		// Ajuste de tamaños para el incremento interno del datapath 																

// Declaracion de señales -------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------	

wire									startIPcore;

wire[STATUS_REG_WIDTH-1:0]		status_reg;
wire[CONFIG_REG_WIDTH*4-1:0]	config_reg;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem;
wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem;
wire									write_enable_mem;


wire[DATA_WIDTH_IFC-1:0]		data_from_mem;
wire[DATAPATH_WIDTH-1:0]		data_from_mem_adj;
					
assign data_from_mem_adj = data_from_mem[DATAPATH_WIDTH-1:0];

wire[DATAPATH_WIDTH-1:0]	data_out;


// Instancia del interpolador ----------------------------------------------------------------

intpol2scope_core	#(
	.MEM_IFC_MAX_WIDTH				(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH					(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH					(STATUS_REG_WIDTH),
	.DATAPATH_WIDTH					(DATA_WIDTH),
	.QM									(QM),
	.QN									(QN)				
)
INTPOL_CORE(
	.clk									(clk),														
	.rstn                   		(rstn),
	.enable                 		(1'd1),
	.start                  		(startIPcore),
	.data_from_mem          		(data_from_mem_adj),    
	.read_addr_mem          		(read_addr_mem),
	.write_addr_mem         		(write_addr_mem),
	.write_enable_mem       		(write_enable_mem),
	.data_out			      		(data_out),
	.config_reg		         		(config_reg),		
	.status_reg				   		(status_reg)
);

// -------------------------------------------------------------------------------------------

ID00001006_intpol2scope_aip INTERFACE(
		.clk							(clk),
		.rst							(rstn),
		.en							(1'd1),
		
		//--- AIP ---//
		.dataInAIP					(datain),					
		.dataOutAIP             (dataout),
		.configAIP              (config_dbus),
		.readAIP                (read),
		.writeAIP               (write),
		.startAIP               (start),
		.intAIP		            (int_req),
		
		//--- IP-core ---//
		.rdDataMemIn_0				(data_from_mem),					
		.rdAddrMemIn_0          (read_addr_mem[MEM_IFC_MAX_WIDTH-1:0]),
		.wrDataMemOut_0         ({{DATA_WIDTH_DIFF{1'd0}},data_out[DATAPATH_WIDTH-1:0]}),
		.wrAddrMemOut_0         (write_addr_mem[MEM_IFC_MAX_WIDTH-1:0]),
		.wrEnMemOut_0           (write_enable_mem),
		.rdDataConfigReg        (config_reg),
		.statusIPcore      		(status_reg),
		.startIPcore		      (startIPcore)
			
);


endmodule