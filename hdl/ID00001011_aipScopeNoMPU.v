
module ID00001011_aipScopeNoMPU (
input		wire						start,				// Señales para conexión con el bloque ipm.
output	wire						int_req,				// Señales para conexión con el bloque ipm.
input		wire						read,					// Señales para conexión con el bloque ipm.
input		wire						write,				// Señales para conexión con el bloque ipm.
input		wire[31:0]				datain,				// Señales para conexión con el bloque ipm.
input		wire[4:0]				config_dbus,		// Señales para conexión con el bloque ipm.	
output 	wire[31:0]				dataout,				// Señales para conexión con el bloque ipm.
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
input		wire						clk,					// Señal de reloj	
input		wire						rstn,					// Reset en bajo
input		wire						valid_data,			// Reset en bajo
input		wire[31:0]				dataStream,
input		wire						scopeFreeze,
input		wire						zoomButton,
output 	wire						nRST,					// Reset to display
output 	wire						SDA,					// Serial data to/from the display.
output 	wire						SCL,					// Clock to the display.
output 	wire						nCS,					// Chip select for the display.														
output 	wire						BL																			
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

localparam						DATA_WIDTH_IFC		= 32;												// Tamaño de palabra para la interfaz ipm
localparam						DATAPATH_WIDTH 	= 16;

localparam 						CONFIG_REG_WIDTH	= 32;													// Ancho de palabra del config reg			-> NO CAMBIAR 
localparam 						STATUS_REG_WIDTH	= 8;                          				// Ancho de palabra del status reg  		-> NO CAMBIAR
											
localparam						MEM_IFC_MAX_WIDTH	= 16;													// Profundidad de memorias en la interfaz aip.
localparam						DATA_WIDTH_DIFF	= DATA_WIDTH_IFC-DATAPATH_WIDTH;		// Ajuste de tamaños para el incremento interno del datapath 																

// Declaracion de señales -------------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------	

wire									startIPcore;

wire[STATUS_REG_WIDTH-1:0]		status_reg;
wire[CONFIG_REG_WIDTH*4-1:0]	config_reg;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem;

wire[DATA_WIDTH_IFC-1:0]		data_MemInReal;
wire[DATA_WIDTH_IFC-1:0]		data_MemInImag;

wire[DATAPATH_WIDTH-1:0]		dataStreamReal_in;
wire[DATAPATH_WIDTH-1:0]		dataStreamImag_in;

assign dataStreamReal_in = dataStream[31:16];
assign dataStreamImag_in = dataStream[15:0];

assign BL = 1'b1;



// Instancia del interpolador-decimador ----------------------------------------------------------------

ID00001011_scopeNoMPU_core	#(
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
	.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
SCOPENOMPU_CORE (		
	.clk							(clk),
	.rstn                	(rstn),
	.start               	(startIPcore),	
	.zoomButton            	(zoomButton),	
	.valid_data             (valid_data),	
	.scopeFreeze				(scopeFreeze),
	.data_MemInReal			(data_MemInReal),	
	.data_MemInImag			(data_MemInImag),	
	.dataStreamReal_in		(dataStreamReal_in),
	.dataStreamImag_in		(dataStreamImag_in),
	.read_addr_mem       	(read_addr_mem),
	.config_reg			      (config_reg),
	.nRST							(nRST),		
	.SDA	               	(SDA),	
	.SCL	               	(SCL),	
	.nCS	               	(nCS),	
	.status_reg				   (status_reg)				
);



// -------------------------------------------------------------------------------------------

ID00001011_scopeNoMPU_aip INTERFACE(
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
		.rdDataMemIn_0				(data_MemInReal),					
		.rdAddrMemIn_0          (read_addr_mem[MEM_IFC_MAX_WIDTH-1:0]),
		
		.rdDataMemIn_1				(data_MemInImag),					
		.rdAddrMemIn_1          (read_addr_mem[MEM_IFC_MAX_WIDTH-1:0]),
		
		.rdDataConfigReg        (config_reg),
		.statusIPcore      		(status_reg),
		.startIPcore		      (startIPcore)
			
);


endmodule