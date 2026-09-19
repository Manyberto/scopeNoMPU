
module ID0000100D_collector2scope_controlpath (
input		wire			clk,						
input		wire			rstn,						
input		wire			start,					
input		wire			sync,					
input		wire			valid_data,				
input		wire			doneInterp,				
output	reg			startInterp,				
output	wire[4:0]	write_addr_local_mem,	
output	wire			write_en_local_mem,		
output	reg			done						
);

localparam	IDLE 		= 3'd0;
localparam	SYNC	 	= 3'd1;
localparam	COLLECT 	= 3'd2;
localparam	INTERP 	= 3'd3;
localparam	DONE 		= 3'd4;

localparam						CNT_WIDTH = 5;
localparam[CNT_WIDTH-1:0]	CNT_LIMIT = 31;
localparam						ADDR_WIDTH = 16;

reg[2:0] state_reg;
reg[2:0] state_next;

reg[CNT_WIDTH-1:0] 	cnt_collect;
reg						cnt_collect_rst;
reg						cnt_collect_on;

assign write_addr_local_mem = cnt_collect;
assign write_en_local_mem = cnt_collect_on;

always@(posedge clk, negedge rstn)begin

	if(rstn == 1'd0)begin
	
		state_reg <= 3'd0;
		cnt_collect <= {CNT_WIDTH{1'd0}};
		
	end
	
	else begin
		
		state_reg <= state_next;
		cnt_collect <= cnt_collect;
		
		if(cnt_collect_rst == 1'd1)begin
			cnt_collect <= {CNT_WIDTH{1'd0}};
		end
		
		else if(cnt_collect_on == 1'd1)begin
			if(cnt_collect < CNT_LIMIT)begin
				cnt_collect <= cnt_collect + 1'd1;
			end
		end
		
	end

end

always@(*)begin
	
	state_next = state_reg;
	
	startInterp = 1'd0;
	done = 1'd0;
	cnt_collect_on = 1'd0;
	cnt_collect_rst = 1'd0;
	
	case(state_reg)
	
		IDLE		: 	begin
							
							if(start == 1'd1)begin
								state_next = SYNC;
								cnt_collect_rst = 1'd0;
							end
		
						end
						
		SYNC	 : begin
							
							if(start == 1'd1)begin
								state_next = IDLE;
							end
							
							else begin
								if(sync == 1'd1)begin
									state_next = COLLECT;
								end
							end	
							
						end				
						
		COLLECT	:	begin
							
							if(start == 1'd1)begin
								state_next = IDLE;
							end	
							
							else begin
								
								if(valid_data == 1'd1)begin
									cnt_collect_on = 1'd1;
								end
								
								if(cnt_collect == CNT_LIMIT)begin
									state_next = INTERP;
									startInterp = 1'd1;
									cnt_collect_rst = 1'd1;
								end
								
							end
							
						end
						
		INTERP	:	begin
							
							if(start == 1'd1)begin
								state_next = IDLE;
							end
							
							else begin
								if(doneInterp == 1'd1)begin
									state_next = DONE;
								end
							end

						end
		
		DONE		:	begin
							state_next = IDLE;
							done = 1'd1;
						end
		
		default	:	begin
							state_next = IDLE;
						end
		
	endcase
	
end

endmodule