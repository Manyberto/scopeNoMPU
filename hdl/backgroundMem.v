
module backgroundMem #(
parameter	DATAPATH_WIDTH	= 32,
parameter	ADDR_WIDTH = 12
)
(
input		wire								clk,
input		wire								wr_en,
input		wire[ADDR_WIDTH-1:0]			wr_addr,
input		wire[ADDR_WIDTH-1:0]			rd_addr,
input		wire[DATAPATH_WIDTH-1:0]	data_in,
output	reg[DATAPATH_WIDTH-1:0]		data_out
);

reg[DATAPATH_WIDTH-1:0]		romBckGrnd[0:2749];

always@(posedge clk)begin
	
	if(wr_en == 1'd1)begin
		romBckGrnd[wr_addr] <= data_in; 
	end
	
	data_out <= romBckGrnd[rd_addr];
	
end


initial begin
	
	$readmemh("C:/Users/Manuel Hernandez/Documents/GitHub/ChannelEmulation/scopeNoMPU/driver/bckGrndMEM.txt", romBckGrnd);
	
end


endmodule