
module intpol2scope_datapath #(
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire								clk,
input		wire								rstn,
input		wire								op_mode,
input 	wire[DATAPATH_WIDTH-1:0]	data_from_mem,	
input 	wire[DATAPATH_WIDTH-1:0]	data_in,	
input		wire[ADDR_WIDTH-1:0]			wr_addr_local_mem,
input		wire[ADDR_WIDTH-1:0]			rd_addr_local_mem,
input		wire								wr_en_local_mem,
output	wire[DATAPATH_WIDTH-1:0]	data_out
);


reg[DATAPATH_WIDTH-1:0]		ram[2**ADDR_WIDTH-1:0]; 
reg[DATAPATH_WIDTH-1:0]		data_local_out;

always@(posedge clk)begin

	if(wr_en_local_mem == 1'd1)begin
		ram[wr_addr_local_mem] <= data_in;
	end
	
	data_local_out <= ram[rd_addr_local_mem];
	
end

assign data_out = (op_mode == 1'd0) ? data_from_mem : data_local_out;


endmodule