
module regBitMem #(
parameter	DATAPATH_WIDTH = 32
)
(
input		wire								clk,
input		wire								rstn,
input		wire								wr_en,
input		wire								data_in,
input		wire[4:0]						addr_in,
output	reg[DATAPATH_WIDTH-1:0] 	data_out
);


always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		data_out <= 32'd0;
	end
	
	else begin
		
		data_out <= data_out;
	
		if(wr_en == 1'd1)begin
			data_out[addr_in] <= data_in;
		end
	end
	
end




endmodule