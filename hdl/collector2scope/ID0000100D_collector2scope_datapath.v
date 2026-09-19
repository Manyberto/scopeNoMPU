
module ID0000100D_collector2scope_datapath (
input		wire			clk,						
input		wire			rstn,						
input		wire			startInterp,		
input		wire[31:0]	dataIn,			
input		wire			write_en_local_mem,				
input		wire[4:0]	write_addr_local_mem,								
output	wire			valid_data,				
output	wire[15:0]	write_addr_mem,	
output	wire[31:0]	dataInterpOut,		
output	wire			doneInterp	
);

localparam	DATA_WIDTH = 16;
localparam	LOCAL_MEM_SIZE = 5;
localparam	SEL_INTERP_WIDTH = 4;
localparam	OP_MODE_WIDTH = 2;
localparam  SIZE2INTPOL_WIDTH	= 8;

reg[DATA_WIDTH*2-1:0]		data2Interp;

reg[DATA_WIDTH*2-1:0]		dataCollect[0:2**LOCAL_MEM_SIZE-1];

wire[15:0]						read_addr_local_mem;
wire[15:0]						read_addr_local_mem_imag;

wire[15:0]						write_addr_mem_imag;

wire[32*4-1:0]					config_reg_interp;
wire[7:0]						status_reg_real;
wire[7:0]						status_reg_imag;

wire								valid_real;
wire								valid_imag;

assign valid_data = valid_real | valid_imag;

assign doneInterp = status_reg_real[0];

assign config_reg_interp[SEL_INTERP_WIDTH-1:0] = { {SEL_INTERP_WIDTH-1{1'd0}}, 1'd1 };
assign config_reg_interp[OP_MODE_WIDTH + SEL_INTERP_WIDTH -1 -: OP_MODE_WIDTH] = 2'd0;
assign config_reg_interp[SIZE2INTPOL_WIDTH + OP_MODE_WIDTH + SEL_INTERP_WIDTH -1 -: SIZE2INTPOL_WIDTH] = 8'd32;
assign config_reg_interp[127:SIZE2INTPOL_WIDTH + OP_MODE_WIDTH + SEL_INTERP_WIDTH] = 'd0;

always@(posedge clk)begin

	if(write_en_local_mem == 1'd1)begin
		dataCollect[write_addr_local_mem] <= dataIn;
	end
	
	data2Interp <= dataCollect[read_addr_local_mem[LOCAL_MEM_SIZE-1:0]];

end


// Instancia del interpolador ----------------------------------------------------------------

intpol2scope_core	#(
	.MEM_IFC_MAX_WIDTH				(16),
	.CONFIG_REG_WIDTH					(32),
	.STATUS_REG_WIDTH					(8),
	.DATAPATH_WIDTH					(16),
	.QM									(3),
	.QN									(13)				
)
COLLECT_INTPOL_CORE0(
	.clk									(clk),														
	.rstn                   		(rstn),
	.enable                 		(1'd1),
	.start                  		(startInterp),
	.data_from_mem          		(data2Interp[31:16]),    
	.read_addr_mem          		(read_addr_local_mem),
	.write_addr_mem         		(write_addr_mem),
	.write_enable_mem       		(valid_real),
	.data_out			      		(dataInterpOut[31:16]),
	.config_reg		         		(config_reg_interp),		
	.status_reg				   		(status_reg_real)
);

// Instancia del interpolador ----------------------------------------------------------------

intpol2scope_core	#(
	.MEM_IFC_MAX_WIDTH				(16),
	.CONFIG_REG_WIDTH					(32),
	.STATUS_REG_WIDTH					(8),
	.DATAPATH_WIDTH					(16),
	.QM									(3),
	.QN									(13)				
)
COLLECT_INTPOL_CORE1(
	.clk									(clk),														
	.rstn                   		(rstn),
	.enable                 		(1'd1),
	.start                  		(startInterp),
	.data_from_mem          		(data2Interp[15:0]),    
	.read_addr_mem          		(read_addr_local_mem_imag),
	.write_addr_mem         		(write_addr_mem_imag),
	.write_enable_mem       		(valid_imag),
	.data_out			      		(dataInterpOut[15:0]),
	.config_reg		         		(config_reg_interp),		
	.status_reg				   		(status_reg_imag)
);

endmodule