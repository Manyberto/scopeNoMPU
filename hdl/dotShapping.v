
module dotShapping #(
parameter	DATAPATH_WIDTH = 'd7,
parameter	DATA_WIDTH_IFC = 'd32
)
(
input		wire								clk,
input		wire								rstn,
input		wire[8:0]						row,
input		wire[8:0]						col,
input		wire								map_on,
input		wire[DATAPATH_WIDTH-1:0]	data_in,
output	reg								data_out
);


localparam[DATAPATH_WIDTH-1:0]	SCOPE_ORIGEN_Y = 'd20;

wire[DATAPATH_WIDTH-1:0] 	data2compare;
wire								valid_region;

assign data2compare = data_in + SCOPE_ORIGEN_Y;

assign valid_region = (col >= 9'd20) & (col <= 9'd390);

always@(posedge clk, negedge rstn)begin

	if(rstn == 1'd0)begin
		data_out <= 1'd0;
	end

	else begin
	
		data_out <= data_out;
	
		if(map_on == 1'd1)begin	
			
			if(valid_region == 1'd1 & row == data2compare)begin
				data_out <= 1'd1;
			end
			else begin
				data_out <= 1'd0;
			end
			
		end
	
	end
	
end


endmodule