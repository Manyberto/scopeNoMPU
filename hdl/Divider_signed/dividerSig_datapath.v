
module dividerSig_datapath #(
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
localparam ELEMENTS_MINUS = ELEMENTS - 1;	
localparam DIVIDER_WIDTH = 2*DATAPATH_WIDTH;

// Declaración de señales ------------------------------------------
wire signed [DATAPATH_WIDTH-1:0]	data_2_sign;

wire signed [DATAPATH_WIDTH-1:0]	data_A;
wire signed [DATAPATH_WIDTH-1:0]	data_S;
wire signed [DATAPATH_WIDTH-1:0]	data_m;
wire signed [DIVIDER_WIDTH-1:0]	data_P;
wire signed [DIVIDER_WIDTH-1:0]	data_P_mux;
reg  signed [DIVIDER_WIDTH-1:0]	data_out_reg;

wire signed [(ELEMENTS+1)*(DIVIDER_WIDTH)-1:0] data_Pi;

assign data_2_sign = {DATAPATH_WIDTH{1'd0}} - data_2;

assign data_A = data_2;
assign data_S = data_2_sign;			  
assign data_P	= { {DATAPATH_WIDTH{data_1[DATAPATH_WIDTH-1]}}, data_1};

assign data_m = (data_1[DATAPATH_WIDTH-1] == data_2[DATAPATH_WIDTH-1]) ? data_S : data_A;
assign data_P_mux = (sel_muxPi == 1'd0) ? data_P : data_out_reg;
assign data_Pi[DIVIDER_WIDTH-1:0] = data_P_mux;
//assign data_out = (valid == 1'd1) ? data_out_reg[DIVIDER_WIDTH-1 : 1] : {2*DATAPATH_WIDTH{1'd0}}; 


genvar i;

generate
	
	for(i = 0; i < ELEMENTS; i = i + 1)begin: ELEM 
		
		dividerSig_element #(
			.DATAPATH_WIDTH		(DATAPATH_WIDTH)		
		)
		DEL(
			.valid					(valid && i == ELEMENTS_MINUS),
			.data_m					(data_m),
			.data_P_in				(data_Pi[(i+1)*DIVIDER_WIDTH-1 -: DIVIDER_WIDTH]),
			.data_P_out				(data_Pi[(i+2)*DIVIDER_WIDTH-1 -: DIVIDER_WIDTH])
		);
		
	end
endgenerate

always @(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		data_out		 <= {DIVIDER_WIDTH{1'd0}};		
		data_out_reg <= {DIVIDER_WIDTH{1'd0}};
	end
	
	else begin
	
		data_out_reg 	<= data_Pi[(ELEMENTS+1)*DIVIDER_WIDTH-1 -: DIVIDER_WIDTH];
		data_out 		<= data_out;
		
		if(valid == 1'd1)begin
			data_out	<= data_Pi[(ELEMENTS+1)*DIVIDER_WIDTH-1 -: DIVIDER_WIDTH];
		end
	end
end

endmodule
