
module mapper #(
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
input		wire[3:0]						config_upperDotWidth,
input		wire[3:0]						config_lowerDotWidth,
output	reg								data_out
);


localparam[DATAPATH_WIDTH-1:0]	SCOPE_ORIGEN_Y = 'd20;

localparam		IDLE = 2'd0;
localparam		CNT_ON = 2'd1;
	
wire[DATAPATH_WIDTH-1:0] 	data2compare;
wire								validVRegion;
wire								validHRegion;
wire[8:0]						data2compareRegionSup;
wire[8:0]						data2compareRegionInf;

reg[1:0]							state_next;
reg[1:0]							state_reg;

//reg[3:0]							cnt_line;
//wire[3:0]						cnt_line_limit;
//wire								cnt_on;
//reg								cnt_on_reg;
//reg								cnt_rst;
//reg								cnt_en;

assign data2compare = data_in + SCOPE_ORIGEN_Y;

assign validHRegion = (col >= 9'd20) & (col <= 9'd390);
assign validVRegion = (row >= 9'd20) & (row <= 9'd226);

assign data2compareRegionSup = (row > 100) ? data2compare + config_upperDotWidth : data2compare + config_lowerDotWidth;
assign data2compareRegionInf = (row > 100) ? data2compare - config_upperDotWidth : data2compare - config_lowerDotWidth;

//assign cnt_line_limit = (row > 100) ? config_upperDotWidth : config_lowerDotWidth;

always@(posedge clk, negedge rstn)begin

	if(rstn == 1'd0)begin
		data_out <= 1'd0;
	end

	else begin
		
		if(map_on == 1'd1)begin	
			if( (validVRegion == 1'd1 && validHRegion && ( row >= data2compareRegionInf & row <= data2compareRegionSup) ) )begin // cnt_en == 1'd1 || 
				data_out <= 1'd1;
			end

			else begin
				data_out <= 1'd0;
			end	
		end
		
//		// DIGIT 1
//		centro_x = 270;
//		centro_y = centro_linea_eje_x;
//		// Tronco
//		if( (jj >= centro_y-4 && jj <= centro_y+6) && (ii >= centro_x-1 && ii <= centro_x+1) )begin
//			binVectData2scope[pnt] = 1;
//		end
//		// Base
//		else if( (jj >= centro_y-6 && jj <= centro_y-5) && (ii >= centro_x-3 && ii <= centro_x+3))begin
//			binVectData2scope[pnt] = 1;
//		end
//		// Cachucha
//		else if( jj == centro_y+6 && (ii >= centro_x-3 && ii <= centro_x-2))begin
//			binVectData2scope[pnt] = 1;
//		end
//		else if(jj == centro_y+5 && ii == centro_x-2)begin
//			binVectData2scope[pnt] = 1;
//		end
		
		else begin
			data_out <= 1'd0;
		end
	
	end
	
end

//assign cnt_on = (validHRegion == 1'd1) && (data2compare == row);
//
//always@(posedge clk, negedge rstn)begin
//	
//	if(rstn == 1'd0)begin
//		cnt_line <= 4'd0;
//		state_reg <= 2'd0;
//		cnt_on_reg <= 1'd0;
//	end
//	
//	else begin
//	
//		state_reg <= state_next;
//		cnt_line <= cnt_line;
//		cnt_on_reg <= cnt_on;
//		
//		if(cnt_rst == 1'd1)begin
//			cnt_line <= 4'd0;
//		end
//		
//		if(cnt_en == 1'd1)begin
//			cnt_line <= cnt_line + 1'd1;
//		end
//
//	end
//	
//end
//
//always@(*)begin
//
//	state_next 	= state_reg;
//	
//	cnt_en		= 1'd0;
//	cnt_rst		= 1'd0;
//	
//	case(state_reg)
//	
//		IDLE		:	begin
//							
//							if(cnt_on == 1'd1 || cnt_on_reg == 1'd1)begin
//								cnt_en = 1'd1;
//								state_next = CNT_ON;
//							end
//							
//						end
//					
//		CNT_ON	:	begin
//							
//							if(cnt_on == 1'd1)begin
//								state_next = IDLE;
//								cnt_rst = 1'd1;
//							end
//							
//							else begin
//								
//								if(cnt_line <= cnt_line_limit)begin
//									cnt_en = 1'd1;
//								end
//								else begin
//									cnt_rst = 1'd1;
//									state_next = IDLE;
//								end
//							end
//							
//						end
//						
//		default	: 	begin
//							
//							state_next = IDLE;
//							
//						end
//	
//	endcase
//
//end


endmodule