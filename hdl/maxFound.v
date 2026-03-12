
module maxFound #(
parameter	DATAPATH_WIDTH = 16
)
(
input		wire										clk,
input		wire										rstn,
input		wire										enable,
input		wire										clear,
input		wire signed[DATAPATH_WIDTH-1:0]	data_in,
output	reg  signed[DATAPATH_WIDTH-1:0]	data_out
);


always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		data_out <= {DATAPATH_WIDTH{1'd0}};
	end
	
	else begin
		
		data_out <= data_out;
		
		if(clear == 1'd1)begin
			data_out <= {DATAPATH_WIDTH{1'd0}};
		end
		
		else if(enable == 1'd1)begin
			if(data_in > data_out)begin
				data_out <= data_in;
			end
		end	
	end
	
end



endmodule