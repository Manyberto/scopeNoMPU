
module ID00001012_scopeSignalMapper_datapath #(
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	AVG_WIDTH			= 'd16,
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32,
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	RD_ADDR_WIDTH		= 'd9,	
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire											clk,
input		wire											rstn,
input		wire											acc_on,
input		wire											map_on,
input		wire[8:0]									row,
input		wire[8:0]									col,
input		wire											clearMax,
input		wire											enableMax,
input		wire											startAvg,
input		wire											startScaler,
input		wire[CONFIG_REG_WIDTH*4-1:0]			config_reg,
input		wire[RD_ADDR_WIDTH-1:0]					rd_addr_local,
input		wire[RD_ADDR_WIDTH-1:0]					wr_addr_local,
input		wire signed [DATAPATH_WIDTH-1:0]		data_in,
input		wire[AVG_WIDTH-1:0]						avg,
output	wire											doneScaler,
output	wire											doneAvg,
output	wire											data_out
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------

localparam ACUM_WIDTH = 'd20;

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
											
wire signed[DATAPATH_WIDTH-1:0]		maxData;
reg[ACUM_WIDTH-1:0]						data2Avg;
reg[ACUM_WIDTH-1:0]						data2Avg_reg;
reg[7:0]										data2Map;
wire[7:0]									dataScaled;
wire											dataMapped;
wire[7:0]									dataAvgOut;

wire[3:0]									config_upperDotWidth;
wire[3:0]									config_lowerDotWidth;
	
wire[ACUM_WIDTH-1:0]						dataNorm2Save;

reg[ACUM_WIDTH-1:0]						dataNormalized[0:371];
reg[7:0]										dataAverage[0:371];

assign data_out = dataMapped;

assign config_upperDotWidth = config_reg[CONFIG_REG_WIDTH+4-1 -: 4];
assign config_lowerDotWidth = config_reg[3:0];

maxFound #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH)
)
MAXFD (
	.clk					(clk),
	.rstn					(rstn),
	.clear				(clearMax),
	.enable				(enableMax),
	.data_in				(data_in),
	.data_out			(maxData)
);

scopeScaler #(
	.DATAPATH_WIDTH		(DATAPATH_WIDTH)
)
SCALER(
	.clk						(clk),
	.rstn                (rstn),
	.start               (startScaler),
	.data_in		         (data_in), 
	.divisor             (maxData),
	.valid_data          (),
	.done                (doneScaler),
	.data_out            (dataScaled)
);	

assign dataNorm2Save = (doneAvg == 1'd1) ? dataAvgOut : (acc_on == 1'd1) ? dataScaled + data2Avg_reg : dataScaled;

always@(posedge clk)begin
	
	if(doneScaler | doneAvg)begin
		dataNormalized[wr_addr_local] <= dataNorm2Save;
	end
	
	data2Avg <= dataNormalized[rd_addr_local];
	
end

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		data2Avg_reg <= {ACUM_WIDTH{1'd0}};
	end
	
	else begin
	
		data2Avg_reg <= data2Avg_reg;
		
		if(doneScaler == 1'd1)begin
			data2Avg_reg <= data2Avg;
		end
		
	end
	
end

always@(posedge clk)begin
	
	if(doneAvg == 1'd1)begin
		dataAverage[wr_addr_local] <= dataAvgOut; 
	end
	
	data2Map <= dataAverage[rd_addr_local];
	
end	

average #(
	.DATAPATH_WIDTH		(ACUM_WIDTH)
)
AVGR(
	.clk						(clk),
	.rstn                (rstn),
	.start					(startAvg),
	.avg						({ {ACUM_WIDTH-AVG_WIDTH{1'd0}}, avg}),
	.data_in					(data2Avg),
	.valid_data				(),
	.data_out				(dataAvgOut),
	.done						(doneAvg)
);

mapper #(
	.DATAPATH_WIDTH	(8),
	.DATA_WIDTH_IFC	(DATA_WIDTH_IFC)
)
MAPPER(
	.clk							(clk),
	.rstn							(rstn),
	.row							(row),
	.col							(col),
	.map_on						(map_on),
	.data_in						(data2Map),
	.config_upperDotWidth	(config_upperDotWidth),
	.config_lowerDotWidth	(config_lowerDotWidth),
	.data_out					(dataMapped)
);		

														
													

endmodule