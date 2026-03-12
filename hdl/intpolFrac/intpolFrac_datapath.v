
module intpolFrac_datapath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32,
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	QM						= 2,									
parameter	QN						= 11,	
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start_intpol,
input		wire									start_decim,
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg_intpol,
input		wire[CONFIG_REG_WIDTH*4-1:0]	config_reg_decim,
input 	wire[DATAPATH_WIDTH-1:0]		data_from_mem,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,
output	wire									write_enable_mem,
output	wire									done_intpol,
output	wire									done_decim,
output	wire[DATAPATH_WIDTH-1:0]		data_out
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
													

// Declaracion de señales --------------------------------------------------------------------

wire										write_enable_local_mem;
wire[MEM_IFC_MAX_WIDTH-1:0]		write_addr_local_mem;
wire[MEM_IFC_MAX_WIDTH-1:0]		read_addr_local_mem;
wire[DATAPATH_WIDTH-1:0]			data_intpol_out;
wire[STATUS_REG_WIDTH-1:0]			status_reg_intpol;
wire[STATUS_REG_WIDTH-1:0]			status_reg_decim;
	
reg[DATAPATH_WIDTH-1:0]				local_mem[0:2**ADDR_WIDTH-1];
reg[DATAPATH_WIDTH-1:0]				data2decim;

assign done_intpol = status_reg_intpol[0];
assign done_decim = status_reg_decim[0];

// Instancia del interpolador ----------------------------------------------------------------

intpol2scope_core	#(
	.MEM_IFC_MAX_WIDTH				(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH					(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH					(STATUS_REG_WIDTH),
	.DATAPATH_WIDTH					(DATAPATH_WIDTH),
	.QM									(QM),
	.QN									(QN)				
)
INTPOL_CORE(
	.clk									(clk),														
	.rstn                   		(rstn),
	.enable                 		(1'd1),
	.start                  		(start_intpol),
	.data_from_mem          		(data_from_mem),    
	.read_addr_mem          		(read_addr_mem),
	.write_addr_mem         		(write_addr_local_mem),
	.write_enable_mem       		(write_enable_local_mem),
	.data_out			      		(data_intpol_out),
	.config_reg		         		(config_reg_intpol),		
	.status_reg				   		(status_reg_intpol)
);


always@(posedge clk)begin
	
	if(write_enable_local_mem == 1'd1)begin
		local_mem[write_addr_local_mem] <= data_intpol_out;
	end
	
	data2decim <= local_mem[read_addr_local_mem]; 
	
end


// Instancia del decimador ----------------------------------------------------------------

ID0000100F_decim2frac_core	#(
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
	.ADDR_WIDTH					(ADDR_WIDTH),
	.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
DECIM_CORE (		
	.clk							(clk),
	.rstn                	(rstn),
	.start               	(start_decim),	
	.data_from_mem				(data2decim),	
//	.data_in						({DATAPATH_WIDTH{1'd0}}),	
	.read_addr_mem       	(read_addr_local_mem),
	.write_addr_mem      	(write_addr_mem),
	.write_enable_mem       (write_enable_mem),
	.data_out  		         (data_out),
	.config_reg			      (config_reg_decim),			
	.status_reg				   (status_reg_decim)				
);


endmodule