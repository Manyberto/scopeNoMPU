
module ID0000100C_modCuad_controlpath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	CONFIG_REG_WIDTH	= 'd32		
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start,
input		wire									bootDone,
input		wire[MEM_IFC_MAX_WIDTH-1:0]	data2pow,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_mem,
output	wire									write_enable_mem,
output	reg									startBoot,
output	wire									busy_flag,
output	reg									done_flag		
);

localparam 		IDLE 				= 2'd0;
localparam		WAIT_POW	 		= 2'd1;
localparam		NEW_DATA		 	= 2'd2;
localparam		DONE				= 2'd3; 

reg[1:0]			state_reg;
reg[1:0]			state_next;
reg				restart;

reg[MEM_IFC_MAX_WIDTH:0]		cnt_powered;
reg									cnt_pwr_on;
reg									cnt_pwr_rst;

reg[MEM_IFC_MAX_WIDTH-1:0]		cnt_rd;
reg									cnt_rd_on;
reg									cnt_rd_rst;

wire[MEM_IFC_MAX_WIDTH-1:0]	data2powLimit;

assign write_enable_mem = cnt_pwr_on;
assign write_addr_mem = cnt_powered[MEM_IFC_MAX_WIDTH-1:0];
assign read_addr_mem = cnt_rd;

assign busy_flag = (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1; 

assign data2powLimit = data2pow - 1'd1;

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg		<= 3'd0;
		restart			<=	1'd0;
		cnt_powered		<= {MEM_IFC_MAX_WIDTH+1{1'd0}};
		cnt_rd			<= {MEM_IFC_MAX_WIDTH{1'd0}};
	end
	
	else begin
		
		state_reg 				<= state_next;
		restart					<= start;
		
		if(cnt_pwr_rst == 1'd1)begin
			cnt_powered		<= {MEM_IFC_MAX_WIDTH+1{1'd0}};
		end
		
		else if(cnt_pwr_on == 1'd1)begin
			cnt_powered		<= cnt_powered + 1'd1;
		end
		
		if(cnt_rd_rst == 1'd1)begin
			cnt_rd		<= {MEM_IFC_MAX_WIDTH{1'd0}};
		end
		
		else if(cnt_rd_on == 1'd1)begin
			cnt_rd		<= cnt_rd + 1'd1;
		end
		
	end

end

always@(*)begin

	state_next 			= state_reg;
	
	startBoot 			= 1'd0;
	
	done_flag			= 1'd0;

	cnt_pwr_on 			= 1'd0;
	cnt_pwr_rst			= 1'd0;
	
	cnt_rd_on 			= 1'd0;
	cnt_rd_rst			= 1'd0;
	
	case(state_reg)
		
		IDLE			:	begin
								if(start == 1'd1 || restart == 1'd1)begin
									state_next = WAIT_POW;
									startBoot = 1'd1;
									cnt_pwr_rst = 1'd1;	
									cnt_rd_rst = 1'd1;	
								end
							end
							
		WAIT_POW 	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
								
									if(bootDone == 1'd1)begin
										cnt_pwr_on = 1'd1;
										if(cnt_powered < data2powLimit)begin
											state_next = NEW_DATA;
											cnt_rd_on = 1'd1;
											startBoot = 1'd1;
										end
										else begin
											done_flag = 1'd1;
											state_next = DONE;											
										end	
									end
								end

							end
		
		NEW_DATA :	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									state_next = WAIT_POW;
								end

							end
		
		DONE			:	begin
								state_next = IDLE;	
								cnt_pwr_rst = 1'd1;
								cnt_rd_rst = 1'd1;
							end	
		
		default		:	begin
								state_next = IDLE;
							end
		
	endcase

end

endmodule