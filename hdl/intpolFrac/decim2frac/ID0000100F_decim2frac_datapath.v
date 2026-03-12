
module ID0000100F_decim2frac_datapath #(
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire								clk,
input		wire								rstn,
input 	wire[DATAPATH_WIDTH-1:0]	data_from_mem,	
output	wire[DATAPATH_WIDTH-1:0]	data_out
);

assign data_out = data_from_mem ;


endmodule