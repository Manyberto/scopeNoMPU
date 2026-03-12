
module DFTinMxVNoAIP #(
parameter	COMPLEX_CP_MTRX		=  1'd1,
parameter	COMPLEX_CP_VCTR		=  1'd1,
parameter	MEMORY_MODE				=  2'd0,		// Modo de operación de la memoria respecto a ubicación de datos real e imaginario -> SHARED = 1, SEPARATED = 1, INTERCALATED = 2.
parameter	QM_MTRX					= 	16'd3,	// Parte entera en PFx del datapath
parameter	QN_MTRX					=	16'd13,	// Parte fraccionaria en PFx del datapath
parameter	QM_VCTR					= 	16'd3,	// Parte entera en PFx del datapath
parameter	QN_VCTR					=	16'd13,	// Parte fraccionaria en PFx del datapath
parameter	QM_OUT					= 	16'd3,	// Parte entera en PFx del datapath
parameter	QN_OUT					=	16'd13,	// Parte fraccionaria en PFx del datapath
parameter	NUM_PES					= 	16'd4,		// Cantidad de PEs del arreglo sistolico a instanciar
parameter	ROWS_A					= 	16'd256,	// Filas de la matriz A
parameter	COLUMNS_A				= 	16'd256   // Columnas en la matriz A
)
(
input		wire					clk,
input		wire					rstn,
input		wire					start,
input		wire[127:0]			config_reg,
input		wire[31:0]			data_vectorIn,
output	wire[15:0]			read_addr_out,
output	wire[15:0]			write_addr_mem,
output	wire					write_en_mem,
output	wire[31:0]			data_core_out,
output	wire[7:0]			status_reg
);


// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
localparam	EXTENDED_QN_BITS 		= (QN_MTRX < QN_VCTR) ? QN_MTRX : QN_VCTR;		// Extensión de la parte fraccionaria para reducir el error.
localparam	DATA_WIDTH_IFC			= 16'd32;													// Tamaño de palabra de la interfaz ipm
localparam	DATAPATH_WIDTH_VCTR 	= QM_VCTR + QN_VCTR;

localparam	NUM_PES_WIDTH			= $clog2(NUM_PES+1);
localparam	QUOTIENT		 			= COLUMNS_A/NUM_PES;
localparam	RESIDUE					= COLUMNS_A%NUM_PES;
localparam	COLUMNS_A_WIDTH		= $clog2(COLUMNS_A+1);
localparam	ROWS_A_WIDTH			= $clog2(ROWS_A+1);

localparam	EXT_MEM_IN				= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd2) ? 16'd1 : 16'd2;
localparam	NUM_MEMS_IN				= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd2) ? NUM_PES+EXT_MEM_IN : (NUM_PES*2)+EXT_MEM_IN;
localparam	NUM_MEMS_OUT			= (MEMORY_MODE == 'd1 || MEMORY_MODE == 'd2) ? 16'd2 : 16'd1;
localparam	NUM_PES_MAX 			= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd2) ? 16'd11 : 16'd5;
localparam	MEM_IN_SIZE 			= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd1) ? $clog2((RESIDUE == 'd0) ? (ROWS_A * QUOTIENT) : 1+(ROWS_A * (QUOTIENT+1)))
											: $clog2((RESIDUE == 'd0) ? 1+2*(ROWS_A * QUOTIENT) : 1+2*(ROWS_A * (QUOTIENT+1))); 	
localparam	MEM_IN0_LIMIT			= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd1) ? COLUMNS_A : 2*COLUMNS_A;
localparam	MEM_OUT_LIMIT			= (MEMORY_MODE == 'd0 || MEMORY_MODE == 'd1) ? ROWS_A : 2*ROWS_A;

localparam	MEM_IN0_SIZE			= $clog2(MEM_IN0_LIMIT);
localparam	MEM_OUT_SIZE			= $clog2(MEM_OUT_LIMIT);

localparam	OP_MODE_WIDTH			= 16'd2;
localparam	RESIDUE_WIDTH			= 16'd4;
localparam	NUM_PES_MAX_WIDTH		= 16'd4;

localparam	MEM_IFC_MAX_WIDTH		= MEM_IN_SIZE;
localparam 	CONFIG_REG_WIDTH		= 16'd32;													// Ancho de palabra del config reg			-> NO CAMBIAR 
localparam 	STATUS_REG_WIDTH		= 16'd8; 

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------																						 
// Declaración de señales --------------------------------------------------------------------------------------------------------------------------------------------
wire[11:0]												write_addr_memCore;	
							
wire[(MEM_IFC_MAX_WIDTH*NUM_MEMS_IN)-1:0]		read_addr_mem;
		
wire[(DATA_WIDTH_IFC*NUM_MEMS_IN)-1:0]			data_from_mem;

assign write_addr_mem = { {16-MEM_IFC_MAX_WIDTH{1'd0}}, write_addr_memCore};

assign data_from_mem[31:0] = data_vectorIn;
assign read_addr_out = { {16-MEM_IFC_MAX_WIDTH{1'd0}}, read_addr_mem[MEM_IFC_MAX_WIDTH-1:0] };
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------																						 

ID0000100F_FFTinMxV_core #(
	.DATA_WIDTH_IFC						(DATA_WIDTH_IFC),
	.COMPLEX_CP_MTRX						(COMPLEX_CP_MTRX),
	.COMPLEX_CP_VCTR						(COMPLEX_CP_VCTR),
	.MEMORY_MODE							(MEMORY_MODE),
	.MEM_IFC_MAX_WIDTH					(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH						(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH						(STATUS_REG_WIDTH),
	.OP_MODE_WIDTH							(OP_MODE_WIDTH),
	.RESIDUE_WIDTH							(RESIDUE_WIDTH),
	.QM_MTRX									(QM_MTRX),
	.QN_MTRX									(QN_MTRX),
	.QM_VCTR									(QM_VCTR),
	.QN_VCTR									(QN_VCTR),
	.QM_OUT									(QM_OUT),
	.QN_OUT									(QN_OUT),
	.DATAPATH_WIDTH_VCTR					(DATAPATH_WIDTH_VCTR),
	.EXTENDED_QN_BITS						(EXTENDED_QN_BITS),
	.NUM_PES									(NUM_PES),
	.NUM_PES_WIDTH							(NUM_PES_WIDTH),
	.EXT_MEM_IN								(EXT_MEM_IN),
	.NUM_MEMS_IN							(NUM_MEMS_IN),
	.NUM_MEMS_OUT							(NUM_MEMS_OUT),
	.NUM_PES_MAX							(NUM_PES_MAX),
	.ROWS_A									(ROWS_A),
	.COLUMNS_A								(COLUMNS_A),
	.ROWS_A_WIDTH							(ROWS_A_WIDTH),
	.COLUMNS_A_WIDTH						(COLUMNS_A_WIDTH),
	.QUOTIENT								(QUOTIENT),
	.RESIDUE									(RESIDUE)
)
MxV_core(
	.clk										(clk),
	.rstn                            (rstn),
	.enable                          (1'd1),
	.start                           (start),
	.data_from_mem							(data_from_mem),	
	.read_addr_mem                	(read_addr_mem),
	.write_addr_mem               	(write_addr_memCore),
	.write_en_mem		               (write_en_mem),
	.data_out	                     (data_core_out),
	.config_reg			               (config_reg),			
	.status_reg				            (status_reg)				
);


genvar idx;

generate
	
	for(idx = 1; idx < 5; idx = idx + 1)begin : MEMSIN
	
		simple_dual_port_ram_single_clk_mine #(	
			 .ID			 			(idx),
			 .DATA_WIDTH 			(32),
			 .ADDR_WIDTH 			(12)
		)
		MEMIN (
			 .Write_clock__i 		(clk),

			 .Write_enable_i 		(),
			 .Write_addres_i 		(),
			 .data_input___i 		(),
				
			 .Read_address_i 		(read_addr_mem[(MEM_IFC_MAX_WIDTH*(idx+1))-1 -: MEM_IFC_MAX_WIDTH]),
			 .data_output__o 		(data_from_mem[32*(idx+1)-1 -: 32])
		);
		
	end	

endgenerate

endmodule