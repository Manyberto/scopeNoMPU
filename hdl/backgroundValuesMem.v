
module backgroundValuesMem #(
parameter	ID	= 1,
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

reg[DATAPATH_WIDTH-1:0]		romBckGrnd[0:249];

always@(posedge clk)begin
	
	if(wr_en == 1'd1)begin
		romBckGrnd[wr_addr] <= data_in; 
	end
	data_out <= romBckGrnd[rd_addr];
	
end


initial begin
	
	$readmemh({"C:/Users/Manuel Hernandez/Documents/GitHub/ChannelEmulation/scopeNoMPU/driver/bckGrndMEM_", num2Ascii(ID), ".txt"}, romBckGrnd);
	
end

function automatic [8*4-1:0] num2Ascii;
 
 input [31:0] data;

	begin
		if(data == 0)begin
			num2Ascii = "4000";
		end
		else if(data == 1)begin
			num2Ascii = "2000";
		end
		else if(data == 2)begin
			num2Ascii = "1000";
		end
		else if(data == 3)begin
			num2Ascii = "0500";
		end
		else if(data == 4)begin
			num2Ascii = "0250";
		end
		else if(data == 5)begin
			num2Ascii = "0125";
		end
	end
	
endfunction

endmodule