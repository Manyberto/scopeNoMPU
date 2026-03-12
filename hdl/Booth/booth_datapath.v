
module booth_datapath #(
parameter	DATAPATH_WIDTH = 16,
parameter	ELEMENTS			= 2
)
(
input		wire											clk,
input		wire											rstn,
input		wire											valid,
input		wire											sel_muxPi,
input		wire signed[DATAPATH_WIDTH-1:0]		data_1,
input		wire signed[DATAPATH_WIDTH-1:0]		data_2,
output	reg signed[2*DATAPATH_WIDTH-1:0]		data_out
);

// Declaracón de parámteros locales --------------------------------

localparam BOOTH_WIDTH = 2*DATAPATH_WIDTH+1;

// Declaración de señales ------------------------------------------
wire signed [DATAPATH_WIDTH-1:0]	data_1_sign;
wire signed [BOOTH_WIDTH-1:0]	data_M;
wire signed [BOOTH_WIDTH-1:0]	data_Mn;
wire signed [BOOTH_WIDTH-1:0]	data_P;
wire signed [BOOTH_WIDTH-1:0]	data_P_mux;
reg  signed [BOOTH_WIDTH-1:0]	data_out_reg;

wire signed [(ELEMENTS+1)*(BOOTH_WIDTH)-1:0] data_Pi;


assign data_1_sign = {DATAPATH_WIDTH{1'd0}} - data_1;

			  // dato, 	   	extensor, 			extra	
assign data_M = { data_1, {DATAPATH_WIDTH{1'd0}}, 1'd0 };
assign data_Mn = { data_1_sign, {DATAPATH_WIDTH{1'd0}}, 1'd0 };

			  //  	  extensor, 	    dato,   extra	
assign data_P	= { {DATAPATH_WIDTH{1'd0}}, data_2, 1'd0 };


assign data_P_mux = (sel_muxPi == 1'd0) ? data_P : data_out_reg;
assign data_Pi[BOOTH_WIDTH-1:0] = data_P_mux;

genvar i;

generate
	
	for(i = 0; i < ELEMENTS; i = i + 1)begin: ELEM 
		
		booth_element #(
			.DATAPATH_WIDTH		(BOOTH_WIDTH)		
		)
		BEL(
			.data_M					(data_M),
			.data_Mn					(data_Mn),
			.data_P_in				(data_Pi[(i+1)*BOOTH_WIDTH-1 -: BOOTH_WIDTH]),
			.data_P_out				(data_Pi[(i+2)*BOOTH_WIDTH-1 -: BOOTH_WIDTH])
		);
		
	end
endgenerate

always @(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		data_out		 <= {2*DATAPATH_WIDTH{1'd0}};		
		data_out_reg <= {BOOTH_WIDTH{1'd0}};
	end
	
	else begin
	
		data_out_reg 	<= data_Pi[(ELEMENTS+1)*BOOTH_WIDTH-1 -: BOOTH_WIDTH];
		data_out 		<= data_out;
		
		if(valid == 1'd1)begin
			data_out		<= data_Pi[(ELEMENTS+1)*BOOTH_WIDTH-1 -: BOOTH_WIDTH-1];
		end
	end
end

endmodule
