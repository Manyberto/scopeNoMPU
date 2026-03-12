
module ID00001012_scopeSignalMapper_controlpath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	RD_ADDR_WIDTH		= 'd9,
parameter	AVG_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH  	= 'd16	
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start,
input		wire									avgRound1Cmp,
input		wire									doneAvg,
input		wire									doneScaler,
input		wire[AVG_WIDTH-1:0]				avg,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	reg[MEM_IFC_MAX_WIDTH-1:0]		write_addr_mem,
output	reg									write_enable_mem,
output	reg									wr_en_local_bit,
output	reg[RD_ADDR_WIDTH-1:0]			wr_addr_local,
output	reg[RD_ADDR_WIDTH-1:0]			rd_addr_local,
output	reg									acc_on,
output	reg									startAvg,
output	reg									startScaler,
output	reg									clearMax,
output	reg									enableMax,
output	reg									map_on,
output	wire[8:0]							row,
output	wire[8:0]							col,
output	reg[4:0]								local_bit,
output	wire									busy_flag,
output	reg									done_flag		
);

localparam 		IDLE 				= 4'd0;
localparam		MAX_SEARCH 		= 4'd1;
localparam		NORMALIZING 	= 4'd2;
localparam		RESTART_SCA		= 4'd3;
localparam		AVERAGE		 	= 4'd4;
localparam		RESTART_AVG		= 4'd5;
localparam		COLS_ROVE	 	= 4'd6;
localparam		ROW_CHANGE		= 4'd7;
localparam		DONE				= 4'd8; 

localparam		SCREEN_ROWS			= 'd240;
localparam		SCREEN_ROWS_LIM	= 'd239;
localparam		SCREEN_COLS			= 'd400;
localparam		SCREEN_COLS_LIM	= 'd399;
localparam		SCREEN_AREA			= 'd372;
localparam		SCREEN_AREA_LIM	= 'd371;
localparam		CNT_WIDTH			= 'd9;
localparam		BIT_LIMIT			= 'd31;
localparam		WORD_LIMIT			= 'd2999;

wire[AVG_WIDTH-1:0] 		avg_min;

reg[RD_ADDR_WIDTH-1:0]	rd_addr;
reg							rd_addr_on;
reg							rd_addr_rst;

reg							wr_addr_local_on;
reg							wr_addr_local_rst;

reg							rd_addr_local_on;
reg							rd_addr_local_rst;

reg[CNT_WIDTH-1:0]		cnt_rows;
reg							cnt_rows_on;
reg							cnt_rows_rst;

reg[CNT_WIDTH-1:0]		cnt_cols;
reg							cnt_cols_on;
reg							cnt_cols_rst;
	
reg[5:0]						cnt_bit;
reg							cnt_bit_on;
reg							cnt_bit_rst;

reg[11:0]					cnt_words;
reg							cnt_words_on;
reg							cnt_words_rst;	

reg[15:0]					cnt_avg;
reg							cnt_avg_on;
reg							cnt_avg_rst;	
	
reg[3:0]						state_reg;
reg[3:0]						state_next;
reg							restart;

wire							wr_en_strobe;
 
assign wr_en_strobe = (local_bit == 5'd31) ? 1'd1 : 1'd0;						 
 
assign read_addr_mem = { {MEM_IFC_MAX_WIDTH-RD_ADDR_WIDTH{1'd0}}, rd_addr};

assign busy_flag = (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1; 

assign row = cnt_rows;
assign col = cnt_cols;

//assign write_enable_mem = wr_en_strobe;
//assign write_addr_mem =  { {MEM_IFC_MAX_WIDTH-12{1'd0}}, cnt_words};

assign avg_min = (avgRound1Cmp == 1'd1) ? avg - 2'd2 : avg - 1'd1;

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg		<= 4'd0;
		restart			<=	1'd0;
		cnt_bit			<= 5'd0;
		local_bit		<= 5'd0;
		cnt_words		<= 12'd0;
		wr_en_local_bit <= 1'd0;
		write_enable_mem <= 1'd0;
		write_addr_mem <= {MEM_IFC_MAX_WIDTH{1'd0}};
		rd_addr			<= {RD_ADDR_WIDTH{1'd0}};
		wr_addr_local	<= {RD_ADDR_WIDTH{1'd0}};
		rd_addr_local	<= {RD_ADDR_WIDTH{1'd0}};
		cnt_rows			<= {CNT_WIDTH{1'd0}};
		cnt_cols			<= {CNT_WIDTH{1'd0}};
		cnt_avg			<= {AVG_WIDTH{1'd0}};
		acc_on			<= 1'd0;
	end
	
	else begin
		
		state_reg 				<= state_next;
		restart					<= start;
		cnt_rows					<= cnt_rows;
		cnt_cols					<= cnt_cols;
		cnt_avg					<= cnt_avg;
		local_bit 				<= cnt_bit[4:0];
		wr_en_local_bit 		<= cnt_bit_on | cnt_bit_rst;
		acc_on					<= acc_on;
		write_enable_mem		<= wr_en_strobe;
		write_addr_mem 		<=  { {MEM_IFC_MAX_WIDTH-12{1'd0}}, cnt_words};

		if(cnt_avg[0] == 1'd1)begin
			acc_on <= 1'd1;
		end
		
		if(rd_addr_rst == 1'd1)begin
			rd_addr <= {RD_ADDR_WIDTH{1'd0}};
		end
		
		else begin
			if(rd_addr_on == 1'd1)begin
				rd_addr <= rd_addr + 1'd1;
			end
		end
		
		if(wr_addr_local_rst == 1'd1)begin
			wr_addr_local <= {RD_ADDR_WIDTH{1'd0}};
		end
		
		else begin
			if(wr_addr_local_on == 1'd1)begin
				wr_addr_local <= wr_addr_local + 1'd1;
			end
		end
		
		if(rd_addr_local_rst == 1'd1)begin
			rd_addr_local <= {RD_ADDR_WIDTH{1'd0}};
		end
		
		else begin
			if(rd_addr_local_on == 1'd1)begin
				if(rd_addr_local < SCREEN_AREA_LIM)begin
					rd_addr_local <= rd_addr_local + 1'd1;
				end
			end
		end
		
		if(cnt_rows_rst == 1'd1)begin
			cnt_rows <= {CNT_WIDTH{1'd0}};
		end
		
		else begin
			if(cnt_rows_on == 1'd1)begin
				cnt_rows <= cnt_rows + 1'd1;
			end
		end
		
		if(cnt_cols_rst == 1'd1)begin
			cnt_cols <= {CNT_WIDTH{1'd0}};
		end
		
		else begin
			if(cnt_cols_on == 1'd1)begin
				cnt_cols <= cnt_cols + 1'd1;
			end
		end
		
		if(cnt_avg_rst == 1'd1)begin
			cnt_avg <= {AVG_WIDTH{1'd0}};
		end
		
		else begin
			if(cnt_avg_on == 1'd1)begin
				cnt_avg <= cnt_avg + 1'd1;
			end
		end
		
		if(cnt_bit_rst == 1'd1)begin
			cnt_bit <= 5'd0;
		end
		
		else begin
			if(cnt_bit_on == 1'd1)begin
				cnt_bit <= cnt_bit + 1'd1;
			end
		end
		
		if(cnt_words_rst == 1'd1)begin
			cnt_words <= 12'd0;
		end
		
		else begin
			if(cnt_words_on == 1'd1)begin
				cnt_words <= cnt_words + 1'd1;
			end
		end
		
	end

end

always@(*)begin

	state_next 			= state_reg;

	rd_addr_on			= 1'd0;
	cnt_rows_on			= 1'd0;
	cnt_cols_on			= 1'd0;	
	cnt_bit_on			= 1'd0;	
	cnt_words_on		= 1'd0;	
	cnt_avg_on			= 1'd0;	
	
	rd_addr_rst			= 1'd0;
	cnt_rows_rst		= 1'd0;
	cnt_cols_rst		= 1'd0;
	cnt_bit_rst			= 1'd0;
	cnt_words_rst		= 1'd0;
	cnt_avg_rst			= 1'd0;
	
	rd_addr_local_on 	= 1'd0;
	wr_addr_local_on 	= 1'd0;
	
	wr_addr_local_rst	= 1'd0;
	rd_addr_local_rst	= 1'd0;
	
	startScaler			= 1'd0;
	startAvg				= 1'd0;
	
	wr_addr_local_on	= 1'd0;
	
	enableMax			= 1'd0;
	clearMax				= 1'd0;
	
	map_on				= 1'd0;
	
	done_flag			= 1'd0;

	
	case(state_reg)
		
		IDLE			:	begin
								if(start == 1'd1 || restart == 1'd1)begin
									state_next = MAX_SEARCH;
									clearMax = 1'd1;
								end
							end
							
		MAX_SEARCH 	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									
									if(rd_addr < SCREEN_AREA_LIM)begin
										rd_addr_on = 1'd1;
										enableMax = 1'd1;
									end
									
									else begin
										rd_addr_rst = 1'd1;
										if(acc_on == 1'd1)begin
											rd_addr_local_on = 1'd1;
										end
										state_next = NORMALIZING;
										startScaler = 1'd1;
									end
								end

							end
		
		NORMALIZING :	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
								
									if(doneScaler == 1'd1)begin
										if(rd_addr < SCREEN_AREA_LIM)begin
											rd_addr_on = 1'd1;
											wr_addr_local_on = 1'd1;
											if(acc_on == 1'd1)begin
												rd_addr_local_on = 1'd1;
											end
											state_next = RESTART_SCA;
										end
										
										else begin
											rd_addr_rst = 1'd1;
											wr_addr_local_rst = 1'd1;
											rd_addr_local_rst = 1'd1;
											if(cnt_avg < avg_min)begin
												cnt_avg_on = 1'd1;
												done_flag = 1'd1;
												state_next = DONE;
											end
											else begin
												startAvg = 1'd1;
												cnt_avg_rst = 1'd1;
												state_next = AVERAGE;												
											end
										end
										
									end
									
								end

							end
							
		RESTART_SCA	:	begin
									
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin		
									startScaler = 1'd1;
									state_next = NORMALIZING;
								end
							end	
		
		AVERAGE	 :		begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
								
									if(doneAvg == 1'd1)begin
										if(rd_addr_local < SCREEN_AREA_LIM)begin
											rd_addr_local_on = 1'd1;
											wr_addr_local_on = 1'd1;
											state_next = RESTART_AVG;
										end
										
										else begin
											rd_addr_local_rst = 1'd1;
											wr_addr_local_rst = 1'd1;
											state_next = COLS_ROVE;
										end
										
									end
									
								end

							end
							
		RESTART_AVG	:	begin
									
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin		
									startAvg = 1'd1;
									state_next = AVERAGE;
								end
							end	
							
		COLS_ROVE 	:	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									
									if(cnt_bit < BIT_LIMIT)begin
										cnt_bit_on = 1'd1;
									end
									
									else begin
										cnt_bit_rst = 1'd1;
										if(cnt_words <= WORD_LIMIT)begin
											cnt_words_on = 1'd1;
										end
									end
								
//									if(local_bit == BIT_LIMIT)begin
//										
//									end	
									
									if(cnt_cols >= 20 && rd_addr_local < SCREEN_AREA_LIM)begin
										rd_addr_local_on = 1'd1;
									end
									
									if(cnt_cols < SCREEN_COLS_LIM)begin
										cnt_cols_on = 1'd1;
										map_on = 1'd1;
									end
									
									else begin
										rd_addr_local_rst = 1'd1;
										cnt_cols_rst = 1'd1;
										state_next = ROW_CHANGE;
									end	
								end

							end	
			
		ROW_CHANGE	:	begin
									
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin		
								
									if(cnt_rows < SCREEN_ROWS_LIM)begin
										cnt_rows_on = 1'd1;
										state_next = COLS_ROVE;
									end
									else begin
										cnt_rows_rst = 1'd1;
										state_next = DONE;
										done_flag = 1'd1;
									end
								end
							end	
		
		DONE			:	begin
								cnt_words_rst = 1'd1;
								state_next = IDLE;	
							end	
		
		default		:	begin
								state_next = IDLE;
							end
		
	endcase

end

endmodule