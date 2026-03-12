
module intpol2scope_core #(	
parameter	MEM_IFC_MAX_WIDTH	= 16,                // Profundidad de memorias en la interfaz aip
parameter	CONFIG_REG_WIDTH	= 32,                // Ancho de palabra del config reg
parameter	STATUS_REG_WIDTH	= 8,                 // Ancho de palabra del status reg
parameter	DATAPATH_WIDTH		= 11,						
parameter	QM						= 2,									
parameter	QN						= 11						
)
(
input		wire										clk,						// Señal de reloj.
input		wire										rstn,                // Reset en bajo.
input		wire										enable,              // Habilitación para el datapath del core.
input		wire										start,               // Señal de arranque.
input		wire[DATAPATH_WIDTH-1:0]			data_from_mem,       // Datos de entrada procedentes de la memoria de la interfaz aip (para modo coprocesador).
output	wire[MEM_IFC_MAX_WIDTH-1:0]		read_addr_mem,       // Dirección de lectura para la memoria de la interfaz aip (para modo coprocesador).
output	wire[MEM_IFC_MAX_WIDTH-1:0]		write_addr_mem,      // Dirección de escritura para la memoria de la interfaz aip (para modo coprocesador).
output	wire										write_enable_mem,    // Señal de habilitación de escritura para la memoria de la interfaz aip (modo coprocesador).
output 	wire[DATAPATH_WIDTH-1:0]			data_out,          	// Datos de salida (interpolados) para el canal Q.
input		wire[(CONFIG_REG_WIDTH*4)-1:0]	config_reg,			   // Registro de configuración entrante desde la interfaz aip.
output	wire[STATUS_REG_WIDTH-1:0]			status_reg				// Registro de status a escribir en la interfaz aip.														
);

// Declaración de parámetros locales------------------------------------------

localparam	ERROR_TOLERANCE_D3			= 0;		// Min 0, Max 7. Al incrementar la tolerancia de error, el error permitido es mayor, pero el gasto de recursos es menor. Por lo tanto, a menor tolerancia, menor error, pero mayor consumo de hardware.
localparam	MAX_INERPOLATION_FACTOR_D3	= 1024;	// Valor de interpolación máximo. Se requiere para ajuste de ensanchamiento del datapath y reducir el error en el diseño 3, así como optimizar el gasto de hardware extra.


localparam	INCREASE_DATAPATH 	= (MAX_INERPOLATION_FACTOR_D3 == 1024) ? 32-ERROR_TOLERANCE_D3 : 
											  (MAX_INERPOLATION_FACTOR_D3 == 512)  ? 30-ERROR_TOLERANCE_D3 : 28-ERROR_TOLERANCE_D3;

localparam	QN_BASE					= QN;
localparam 	QM_COEF					= QM + 3;							// Parte entera en PFx del datapath 		-> NO CAMBIAR	

localparam	V_INTERP_MAX			= MAX_INERPOLATION_FACTOR_D3;	// Valor máximo de interpolación permitido
localparam	SEL_INTERP_MAX 		= 10;									// valor máximo del selector de interpolación.

localparam	REG_WIDTH_EXT			= DATAPATH_WIDTH;
localparam	OP_MODE_WIDTH 			= 2;
localparam	SEL_INTERP_WIDTH 		= 4;
localparam	INPUT_REG_ADDR_MAX	= 3;
localparam  SIZE2INTPOL_WIDTH		= 8;

localparam	V_INTERP_MAX_WIDTH	= (REG_WIDTH_EXT >= ($clog2(V_INTERP_MAX) + 1)) ? $clog2(V_INTERP_MAX) + 1 : REG_WIDTH_EXT;

localparam	REG_WIDTH				= (REG_WIDTH_EXT < INCREASE_DATAPATH) ? INCREASE_DATAPATH : REG_WIDTH_EXT;//12;


localparam	COEF_WIDTH				= (REG_WIDTH-REG_WIDTH_EXT) + QN + QM_COEF;//12;
localparam	EXTEND_BITS				= COEF_WIDTH - REG_WIDTH;//0;
localparam 	QN_WIDTH 				= $clog2(QN);

// Declaración de señales ----------------------------------------------------		
// ---------------------------------------------------------------------------
wire										reset;
	
wire[MEM_IFC_MAX_WIDTH-1:0]		r_addr_mem_in_0;
wire[MEM_IFC_MAX_WIDTH-1:0]		w_addr_mem_out;
wire										w_en_mem_out;
	
reg[CONFIG_REG_WIDTH-1:0]			config_reg_0;

wire[SIZE2INTPOL_WIDTH-1:0]		size2intpol;		
wire										save_config;

wire[OP_MODE_WIDTH-1:0]				OP_MODE;
	
wire[SEL_INTERP_WIDTH-1:0]			SEL_INTERP;
wire[V_INTERP_MAX_WIDTH-1:0]		V_INTERP;						
	
wire										w_en_reg_in;
wire[INPUT_REG_ADDR_MAX-2:0]		w_addr_reg_in;
	
wire[V_INTERP_MAX_WIDTH-1:0]		index;
	
wire										clear_regin;
wire										clear_datapath;
wire										shift_reg_in;
	
wire										w_en_mem_out_sel;
	
wire										done_flag;
wire										busy_flag;
wire										stop_by_error_cfg_flag;

wire[REG_WIDTH_EXT-1:0]				M0_1;
wire[REG_WIDTH_EXT-1:0]				M1_1;
wire[REG_WIDTH_EXT-1:0]				M2_1;
				
wire[COEF_WIDTH-1:0]					M0_EXT_1;
wire[COEF_WIDTH-1:0]					M1_EXT_1;
wire[COEF_WIDTH-1:0]					M2_EXT_1;
			
wire[COEF_WIDTH-1:0]					P0_1;
wire[COEF_WIDTH-1:0]					P1_1;
wire[COEF_WIDTH-1:0]					P2_1;
			
wire[COEF_WIDTH-1:0]					P0_1_INT;
wire[COEF_WIDTH-1:0]					P1_1_INT;
wire[COEF_WIDTH-1:0]					P2_1_INT;		
			
wire[COEF_WIDTH-1:0]					p1_xi_base_1;
wire[COEF_WIDTH-1:0]					p2_xi2_base_1;						
							
wire										acc_en;
wire										acc_rst;
wire										bypass_flag;
				
wire										acc_mult_en;
wire										clear_acc_mult;
wire										selector_mult;

wire										copy_flag;

wire[REG_WIDTH_EXT-1:0]				data_out_1_wire;
wire[REG_WIDTH_EXT-1:0]				data_out_1_wire_mux;
reg[REG_WIDTH_EXT-1:0]				data_out_1_reg;

wire[V_INTERP_MAX_WIDTH-1:0]		shift_D_X;
wire[V_INTERP_MAX_WIDTH-1:0]		shift_D_2X;

// ----------------------------------------------------------------------------
assign read_addr_mem 		= r_addr_mem_in_0;
assign write_addr_mem 		= w_addr_mem_out;
assign write_enable_mem 	= w_en_mem_out;		

assign reset 					= rstn;
// ---------------------------------------------------------------------------------

assign status_reg[0] = done_flag;
assign status_reg[1]	= busy_flag;
assign status_reg[2] = 1'd0;
assign status_reg[3] = 1'd0;
assign status_reg[4] = stop_by_error_cfg_flag;	

assign status_reg[OP_MODE_WIDTH-1+5 -: OP_MODE_WIDTH] = OP_MODE;

assign status_reg[7] = ~enable;

assign M0_EXT_1[COEF_WIDTH-1 -: COEF_WIDTH] = { {EXTEND_BITS{M0_1[REG_WIDTH_EXT-1]}} , M0_1[REG_WIDTH_EXT-1:0], {(REG_WIDTH-REG_WIDTH_EXT){1'd0}} };
assign M1_EXT_1[COEF_WIDTH-1 -: COEF_WIDTH] = { {EXTEND_BITS{M1_1[REG_WIDTH_EXT-1]}} , M1_1[REG_WIDTH_EXT-1:0], {(REG_WIDTH-REG_WIDTH_EXT){1'd0}} };
assign M2_EXT_1[COEF_WIDTH-1 -: COEF_WIDTH] = { {EXTEND_BITS{M2_1[REG_WIDTH_EXT-1]}} , M2_1[REG_WIDTH_EXT-1:0], {(REG_WIDTH-REG_WIDTH_EXT){1'd0}} };

// ----------------------------------------------------------------------------

assign	SEL_INTERP 		= config_reg_0[SEL_INTERP_WIDTH-1:0];
assign	OP_MODE 			= config_reg_0[OP_MODE_WIDTH + SEL_INTERP_WIDTH -1 -: OP_MODE_WIDTH];
assign 	size2intpol		= config_reg_0[SIZE2INTPOL_WIDTH + OP_MODE_WIDTH + SEL_INTERP_WIDTH -1 -: SIZE2INTPOL_WIDTH];

// ----------------------------------------------------------------------------

assign stop_by_error_cfg_flag = ((V_INTERP >= V_INTERP_MAX) || (SEL_INTERP > SEL_INTERP_MAX));
								
assign w_en_mem_out = (enable == 1'd1) ? w_en_mem_out_sel : 1'd0;

// ----------------------------------------------------------------------------

always@(posedge clk, negedge reset)begin

	if(reset == 1'd0)begin
		data_out_1_reg <= {REG_WIDTH_EXT{1'd0}};
		config_reg_0	<= {CONFIG_REG_WIDTH{1'd0}};	
	end
	
	else begin
		
		config_reg_0 <= config_reg_0;
		
		if(save_config == 1'd1)begin
			config_reg_0 <= config_reg[(CONFIG_REG_WIDTH*1)-1 -: CONFIG_REG_WIDTH];
		end
		
		if(w_en_mem_out == 1'd1)begin
			data_out_1_reg <= data_out_1_wire;
		end
	end

end

assign data_out_1_wire_mux = (copy_flag == 1'd1) ? M0_1 : data_out_1_wire;

assign data_out = (w_en_mem_out == 1'd1) ? data_out_1_wire_mux : data_out_1_reg;

// Registro de entrada y shifter :: Instancia
intpol2scope_input_register #(
					.REG_WIDTH				(REG_WIDTH_EXT),
					.INPUT_REG_ADDR_MAX	(INPUT_REG_ADDR_MAX)
)
REG_IN 			(
					.clk						(clk),
					.reset					(reset),
					.shift_reg_in			(shift_reg_in),
					.data_in					(data_from_mem),
					.clear_regin			(clear_regin),
					.w_en_reg_in			(w_en_reg_in),
					.w_addr_reg_in			(w_addr_reg_in),
					.M0						(M0_1[REG_WIDTH_EXT-1:0]),
					.M1						(M1_1[REG_WIDTH_EXT-1:0]),
					.M2						(M2_1[REG_WIDTH_EXT-1:0])
);

// Fin instancia
// ---------------------------------------------------------------------------


// Calculador de coeficientes :: Instancia

coeficient_math #(
					.REG_WIDTH			(COEF_WIDTH)
)
COEF_MATH(
					.M0					(M0_EXT_1[COEF_WIDTH-1:0]),
					.M1					(M1_EXT_1[COEF_WIDTH-1:0]),
					.M2					(M2_EXT_1[COEF_WIDTH-1:0]),
					.PI					(P0_1_INT[COEF_WIDTH-1:0]),
					.PJ					(P1_1_INT[COEF_WIDTH-1:0]),
					.PK					(P2_1_INT[COEF_WIDTH-1:0])
);

// Fin instancia 
// ---------------------------------------------------------------------------------

// Entrada Streamming de datos ------------------------------------------------------

coefficient_handler #(
				.REG_WIDTH				(COEF_WIDTH),
				.V_INTERP_MAX_WIDTH	(V_INTERP_MAX_WIDTH)
)
COEF_HANDLER(
				.clk					(clk),
				.reset				(reset),
				.index				(index),
				.PI					(P0_1_INT[COEF_WIDTH-1:0]),
				.PJ					(P1_1_INT[COEF_WIDTH-1:0]),
				.PK					(P2_1_INT[COEF_WIDTH-1:0]),
				.PI_REG				(P0_1[COEF_WIDTH-1:0]),
				.PJ_REG				(P1_1[COEF_WIDTH-1:0]),
				.PK_REG				(P2_1[COEF_WIDTH-1:0])
);

// Fin de instancia ----------------------------------------------------------------

// Bloque selector de ajuste xis :: Instancia
half_multiplier_D3 	#(
			.REG_WIDTH					(COEF_WIDTH),
			.REG_WIDTH_EXT				(REG_WIDTH_EXT),
			.V_INTERP_MAX_WIDTH		(V_INTERP_MAX_WIDTH),
			.QN_BASE						(QN_BASE),
			.QM_COEF						(QM_COEF)
)
MEDIO_MULTI	(
			.clk						(clk),
			.reset					(reset),
			.enable					(enable),
			.clear_datapath		(clear_datapath),
			.acc_en					(acc_en),
			.acc_rst					(acc_rst),
			.bypass_flag			(bypass_flag),
			.P0						(P0_1[COEF_WIDTH-1:0]),
			.xi_base					(p1_xi_base_1[COEF_WIDTH-1:0]),
			.xi2_base				(p2_xi2_base_1[COEF_WIDTH-1:0]),
			.index					(index),	
			.yi						(data_out_1_wire[REG_WIDTH_EXT-1:0])
);

// Fin instancia 
// ------------------------------------------------------------------------------------

// Decoder -> SEL_INTERP to V_INTERP :: Instancia
mux_p_xi_base_D3	#(
			.QN_WIDTH				(QN_WIDTH),
			.REG_WIDTH				(COEF_WIDTH),
			.V_INTERP_MAX_WIDTH	(V_INTERP_MAX_WIDTH),
			.SEL_INTERP_WIDTH		(SEL_INTERP_WIDTH)
)
MUX_P_XI_BASE(
			.clk						(clk),
			.reset					(reset),
			.P1						(P1_1[COEF_WIDTH-1:0]),
			.P2						(P2_1[COEF_WIDTH-1:0]),
			.SEL_INTERP				(SEL_INTERP),
			.shift_D_X				(shift_D_X),
			.shift_D_2X				(shift_D_2X),
			.p1_xi_base				(p1_xi_base_1[COEF_WIDTH-1:0]),
			.p2_xi2_base			(p2_xi2_base_1[COEF_WIDTH-1:0])
);
// Fin instancia 
// -----------------------------------------------------------------------------------
// Fin DATA PATH ----------------------------------------------------------

// CONTROL PATH -----------------------------------------------------------

// Máquina de control :: Instancia
intpol2scope_fsm	 #(
		.REG_WIDTH						(REG_WIDTH),
		.MEM_IF_MAX_WIDTH				(MEM_IFC_MAX_WIDTH),
		.V_INTERP_MAX_WIDTH			(V_INTERP_MAX_WIDTH),
		.INPUT_REG_ADDR_MAX			(INPUT_REG_ADDR_MAX),
		.SIZE2INTPOL_WIDTH			(SIZE2INTPOL_WIDTH),
		.OP_MODE_WIDTH					(OP_MODE_WIDTH)
)
FSM1	(
		.clk								(clk),													
		.reset               		(reset),
		.start               		(start),
		.enable							(enable),
		.V_INTERP            		(V_INTERP),
		.size2intpol					(size2intpol),
		.error_cfg_flag				(stop_by_error_cfg_flag),
		.index_out_reg             (index),
		.acc_en_out_reg				(acc_en),
		.acc_rst_out_reg				(acc_rst),
		.bypass_flag_out_reg			(bypass_flag),	
		.r_addr_mem_in_0_out_reg   (r_addr_mem_in_0),
		.w_addr_mem_out_out_reg    (w_addr_mem_out),
		.w_en_mem_out_out_reg      (w_en_mem_out_sel),
		.w_en_reg_in_out_reg       (w_en_reg_in),
		.w_addr_reg_in_out_reg     (w_addr_reg_in),
		.shift_reg_in_out_reg      (shift_reg_in),
		.copy_flag_reg					(copy_flag),
		.busy_flag_out_reg         (busy_flag),
		.clear_regin_out_reg       (clear_regin),
		.clear_datapath_out_reg		(clear_datapath),
		.save_config_out_reg			(save_config),
		.done_flag_out_reg			(done_flag)		
);

// Fin instancia 
// -----------------------------------------------------------------------------------



// Decoder -> SEL_INTERP to V_INTERP :: Instancia
decoder_D3	#(
			.SEL_INTERP_WIDTH		(SEL_INTERP_WIDTH),
			.V_INTERP_MAX_WIDTH	(V_INTERP_MAX_WIDTH)
)
DECODER(
			.SEL_INTERP				(SEL_INTERP),
			.V_INTERP				(V_INTERP),
			.shift_D_X				(shift_D_X),
			.shift_D_2X				(shift_D_2X)
);
// Fin instancia 
// -----------------------------------------------------------------------------------

// Fin CONTROL PATH ----------------------------------------------------------


endmodule