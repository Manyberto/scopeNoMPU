
module ipmScopeNoMPU (
// MCU --> Driver
input 	[3:0]						addressMCU,
input 								rstMCU,
input 								rdMCU,
input 								wrMCU,
inout 	[7:0]						dataMCU,
output 								intMCU,	
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
localparam						DATA_WIDTH_IFC	= 32;	
localparam 						CONFIG_WIDTH 	= 5;
																		 
// --------------------------------------------------------------------------------------------------------------------------------------------------------------

wire 								wireReset;			// Señales para conexión con el bloque ipm.
wire [DATA_WIDTH_IFC-1:0] 	wireDataIPtoMCU;  // Señales para conexión con el bloque ipm.
wire [DATA_WIDTH_IFC-1:0] 	wireDataMCUtoIP;  // Señales para conexión con el bloque ipm.
wire [CONFIG_WIDTH-1:0]		wireConf;         // Señales para conexión con el bloque ipm.
wire 								wireReadIP;       // Señales para conexión con el bloque ipm.
wire 								wireWriteIP;      // Señales para conexión con el bloque ipm.
wire 								wireStartIP;      // Señales para conexión con el bloque ipm.
wire 								wireINT;

assign wireReset = rstn & rstMCU;


//wire	clkPLL;
//
//pll2FFT PLL0(
//	.inclk0	(clk),
//	.c0		(clkPLL)
//);


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
ipm IPM (
		.clk_n_Hz				(clk),
		.ipm_RstIn				(wireReset),
		
		// MCU --> Drive	
		.ipmMCUDataInout		(dataMCU),
		.ipmMCUAddrsIn			(addressMCU),
		.ipmMCURdIn				(rdMCU),
		.ipmMCUWrIn				(wrMCU),
		.ipmMCUINTOut			(intMCU),
		
		// I	
		.ipmPIPDataIn			(wireDataIPtoMCU),
		.ipmPIPConfOut			(wireConf),
		.ipmPIPReadOut			(wireReadIP),
		.ipmPIPWriteOut		(wireWriteIP),
		.ipmPIPStartOut		(wireStartIP),
		.ipmPIPDataOut			(wireDataMCUtoIP),
		.ipmPIPINTIn			(wireINT)
);


// ------------------------------------------------------------------------------------------------------------------------------------------------------------------


ID00001011_aipScopeNoMPU ID00001011(
		.clk						(clk),			 // Señal de reloj	
		.rstn						(rstn),            // Reset en bajo	
		.valid_data				(1'd1),
		.dataStream				(dataStream),
		.zoomButton				(~zoomButton),
		.scopeFreeze			(scopeFreeze),
		.nRST						(nRST),		
		.SDA	               (SDA),	
		.SCL	               (SCL),	
		.nCS	               (nCS),
		.BL						(BL),
// ---------------------------------------------------------------------
		.start					(wireStartIP),
		.int_req					(wireINT),
		.read						(wireReadIP),
		.write					(wireWriteIP),
		.datain					(wireDataMCUtoIP),				
		.config_dbus			(wireConf),
		.dataout					(wireDataIPtoMCU)															
);


endmodule