
module ID00001009_decim2scope_controlpath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start,
input		wire									valid_data,
input		wire									op_mode,
input		wire[ADDR_WIDTH-1:0]				size2decim,
input		wire[ADDR_WIDTH-1:0]				decim_factor,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	wire[ADDR_WIDTH-1:0]				rd_addr_local_mem,
output	wire[ADDR_WIDTH-1:0]				wr_addr_local_mem,
output	reg									wr_en_local_mem,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	wr_addr_mem_out,
output	wire									wr_en_mem_out,
output	wire									busy_flag,
output	reg									done_flag		
);

localparam 		IDLE 			= 2'd0;
localparam		SAVE_DATA 	= 2'd1;
localparam		DECIM_DATA	= 2'd2;
localparam		DONE			= 2'd3; 


reg[1:0]			state_reg;
reg[1:0]			state_next;

reg				restart;

reg[ADDR_WIDTH:0]	cnt_rd_addr;
reg						cnt_rd_on;
reg						cnt_rd_rst;	
wire						rd_done;

reg[ADDR_WIDTH-1:0]	cnt_wr_addr;
reg						cnt_wr_on;
reg						cnt_wr_rst;

reg[ADDR_WIDTH-1:0]	cnt_wr_mem_out_addr;
reg						cnt_wr_mem_out_on;
reg						cnt_wr_mem_out_on_reg;
reg						cnt_wr_mem_out_rst;



assign read_addr_mem 	 = (op_mode == 1'd0) ? { {MEM_IFC_MAX_WIDTH-ADDR_WIDTH{1'd0}}, cnt_rd_addr[ADDR_WIDTH-1:0] } : {MEM_IFC_MAX_WIDTH{1'd0}};
assign rd_addr_local_mem = (op_mode == 1'd1) ? cnt_rd_addr[ADDR_WIDTH-1:0] : {ADDR_WIDTH{1'd0}};
assign wr_addr_local_mem = (op_mode == 1'd1) ? cnt_wr_addr : {ADDR_WIDTH{1'd0}};

assign wr_addr_mem_out = { {MEM_IFC_MAX_WIDTH-ADDR_WIDTH{1'd0}}, cnt_wr_mem_out_addr};
assign wr_en_mem_out = cnt_wr_mem_out_on_reg;

assign rd_done = (cnt_rd_addr < size2decim-1'd1) ? 1'd0 : 1'd1;

assign busy_flag = (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1; 

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg				<= 3'd0;
		restart					<=	1'd0;	
		cnt_wr_mem_out_on_reg<= 1'd0;
		cnt_rd_addr				<= {ADDR_WIDTH+1{1'd0}};
		cnt_wr_addr				<= {ADDR_WIDTH{1'd0}};
		cnt_wr_mem_out_addr	<= {ADDR_WIDTH{1'd0}};
	end
	
	else begin
		
		state_reg 				<= state_next;
		restart					<= start;
		cnt_rd_addr				<= cnt_rd_addr;
		cnt_wr_addr				<= cnt_wr_addr;
		cnt_wr_mem_out_addr	<= cnt_wr_mem_out_addr;
		cnt_wr_mem_out_on_reg<= cnt_wr_mem_out_on;
		
		if(cnt_rd_rst == 1'd1)begin
			cnt_rd_addr	<= {ADDR_WIDTH+1{1'd0}};
		end
		
		else if(cnt_rd_on == 1'd1)begin
			if(cnt_rd_addr < size2decim-1'd1)begin
				cnt_rd_addr <= cnt_rd_addr + decim_factor;
			end
		end
		
		if(cnt_wr_rst == 1'd1)begin
			cnt_wr_addr	<= {ADDR_WIDTH{1'd0}}; 
		end
		
		else if(cnt_wr_on == 1'd1)begin
			cnt_wr_addr <= cnt_wr_addr + 1'd1;
		end
		
		if(cnt_wr_mem_out_rst == 1'd1)begin
			cnt_wr_mem_out_addr	<= {ADDR_WIDTH{1'd0}}; 
		end
		
		else if(cnt_wr_mem_out_on_reg == 1'd1)begin
			cnt_wr_mem_out_addr <= cnt_wr_mem_out_addr + 1'd1;
		end
		
	end

end

always@(*)begin

	state_next 					= state_reg;
	wr_en_local_mem			= 1'd0;
	done_flag					= 1'd0;
			
	cnt_rd_on					= 1'd0;
	cnt_rd_rst					= 1'd0;
					
	cnt_wr_on					= 1'd0;
	cnt_wr_rst					= 1'd0;
	
	cnt_wr_mem_out_on			= 1'd0;
	cnt_wr_mem_out_rst		= 1'd0;

	case(state_reg)
		
		IDLE			:	begin
								if(start == 1'd1 || restart == 1'd1)begin
									cnt_rd_rst = 1'd1;
									cnt_wr_rst = 1'd1;
									cnt_wr_mem_out_rst = 1'd1;
									if(op_mode == 1'd1)begin
										state_next = SAVE_DATA;
									end
									else begin
										state_next = DECIM_DATA;
									end
								end
							end
							
		SAVE_DATA	:	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									
									if(valid_data == 1'd1)begin
										if(cnt_wr_addr < size2decim)begin
											cnt_wr_on = 1'd1;
											wr_en_local_mem = 1'd1;
										end
										else begin
											cnt_wr_rst = 1'd1;
											state_next = DECIM_DATA;
										end
									end
								end
								
							end
							
		DECIM_DATA	:	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									
									if(rd_done == 1'd1)begin
										cnt_wr_mem_out_rst = 1'd1;
										cnt_rd_rst = 1'd1;
										state_next = DONE;
									end
									
									else begin
										cnt_wr_mem_out_on = 1'd1;
										cnt_rd_on = 1'd1;
									end
									
								end
		
							end
		
		DONE			:	begin
								state_next = IDLE;
								done_flag = 1'd1;	
							end	
		
		default		:	begin
								state_next = IDLE;
							end
		
	endcase

end

endmodule