
module ID0000100D_collector2scope_core #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16
)
(
input		wire									clk,						// Señal de reloj	
input		wire									rstn,						// Reset en bajo
input		wire									start,
input		wire									sync,
input		wire									valid_data,
input		wire[DATAPATH_WIDTH-1:0]		data_in,					// Datos para almacenar en la memoria de datos de entrada
input		wire[DATAPATH_WIDTH-1:0]		data_in1,					// Datos para almacenar en la memoria de datos de entrada
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,      // Dirección de escritura para la memoria de la interfaz aip.
output	wire									write_enable_mem,    // Señal de habilitación de escritura para la memoria de la interfaz aip.
output 	wire[DATAPATH_WIDTH-1:0]		data_out,          	// Datos de salida
output 	wire[DATAPATH_WIDTH-1:0]		data_out1,          	// Datos de salida
output	wire									done
);

wire			startInterp;
wire			doneInterp;

wire			write_en_local_mem;
wire[4:0]	write_addr_local_mem;

wire[31:0]	dataInterpOut;


ID0000100D_collector2scope_controlpath ID0000100D_CP (
		.clk								(clk),
		.rstn								(rstn),
		.start							(start),
		.sync								(sync),
		.valid_data						(valid_data),
		.doneInterp						(doneInterp),
		.startInterp					(startInterp),
		.write_addr_local_mem		(write_addr_local_mem),
		.write_en_local_mem			(write_en_local_mem),
		.done								(done)
);

ID0000100D_collector2scope_datapath ID0000100D_DP (
		.clk								(clk),
		.rstn								(rstn),
		.startInterp					(startInterp),
		.dataIn							({data_in, data_in1}),
		.write_en_local_mem			(write_en_local_mem),
		.write_addr_local_mem		(write_addr_local_mem),
		.valid_data						(write_enable_mem),
		.write_addr_mem				(write_addr_mem),
		.dataInterpOut					(dataInterpOut),
		.doneInterp						(doneInterp)
);

assign data_out = dataInterpOut[31:16];
assign data_out1 = dataInterpOut[15:0];

endmodule