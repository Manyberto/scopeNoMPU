
module ID00001011_scopeNoMPU_controlpath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	CONFIG_REG_WIDTH  = 'd32,	
parameter	AVG_WIDTH  = 'd16	
)
(
input		wire								clk,
input		wire								rstn,
input		wire								start,
input		wire								scopeFreeze,
input		wire[AVG_WIDTH-1:0]			avg,
input		wire								doneDecim,
input		wire								doneFFT,
input		wire								doneModCuad,
input		wire								doneMultirate,
input		wire								doneMapper,
input		wire								doneScope,
output	reg[CONFIG_REG_WIDTH-1:0]	config_regScope,
output	reg								startDecim,
output	reg								startFFT,
output	reg								startModCuad,
output	reg								startMultirate,
output	reg								startScope,
output	reg								startMapper,
output	reg								avgRound1Cmp,
output	wire								busy_flag,
output	reg								done_flag		
);

localparam		CLK_REF			= 15000000;

localparam 		IDLE 				= 4'd0;
localparam		RESET_SCOPE		= 4'd1;
localparam		WAITRST_DONE	= 4'd2;
localparam		INVMODE_SCOPE	= 4'd3;
localparam		WAITINV_DONE	= 4'd4;
localparam		DECIM_BUSY		= 4'd5;
localparam		FFT_BUSY			= 4'd6;
localparam		MODCUAD_BUSY	= 4'd7;
localparam		MULTIR_BUSY		= 4'd8;
localparam		MAPPER_BUSY		= 4'd9;
localparam		HOLD_ON			= 4'd10;
localparam		WRITE_SCOPE		= 4'd11;
localparam		WAITWR_DONE 	= 4'd12;
localparam		DONE				= 4'd13; 

localparam		BLACK				= 4'h0;
localparam		BLUE				= 4'h1;
localparam		GREEN				= 4'h2;
localparam		CYAN				= 4'h3;
localparam		RED				= 4'h4;
localparam		PINK				= 4'h5;
localparam		YELLOW			= 4'h6;
localparam		WHITE				= 4'h7;

reg[3:0]					state_reg;
reg[3:0]					state_next;
reg						restart;
		
reg						set_scopeConfig;
		
reg[23:0]				cntTime;
reg						cnt_on;
reg						cnt_rst;
		
reg[AVG_WIDTH-1:0]	cntAvg;
reg						cntAvg_on;
reg						cntAvg_rst;

wire[AVG_WIDTH-1:0]	avg_min;

reg[CONFIG_REG_WIDTH-1:0]	config_regScopeW;

assign busy_flag = (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1; 

assign avg_min = (avgRound1Cmp == 1'd1) ? avg - 2'd2 : avg - 1'd1;

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg			<= 4'd0;
		restart				<=	1'd0;
		cntTime				<= 24'd0;
		cntAvg				<= {AVG_WIDTH{1'd0}};
		config_regScope 	<= 32'd0;
		avgRound1Cmp      <= 1'd0;
	end
	
	else begin
		
		state_reg 			<= state_next;
		restart				<= start;
		config_regScope 	<= config_regScope;
		cntTime				<= cntTime;
		cntAvg				<= cntAvg;
		avgRound1Cmp		<= avgRound1Cmp;
		
		if(start == 1'd1)begin
			avgRound1Cmp <= 1'd0;
		end
		
		else begin
			if(done_flag == 1'd1)begin
				avgRound1Cmp <= 1'd1;
			end
		end	
		
		if(set_scopeConfig == 1'd1)begin
			config_regScope <= config_regScopeW;
		end
		
		if(cnt_rst == 1'd1)begin
			cntTime <= 24'd0;
		end
		
		else begin 
			if(cnt_on == 1'd1)begin
				cntTime <= cntTime + 1'd1;
			end
		end
	
		if(cntAvg_rst == 1'd1)begin
			cntAvg <= {AVG_WIDTH{1'd0}};
		end
		
		else begin 
			if(cntAvg_on == 1'd1)begin
				cntAvg <= cntAvg + 1'd1;
			end
		end
		
		
	end

end

always@(*)begin

	state_next 			= state_reg;
	
	startDecim			= 1'd0;
	startFFT				= 1'd0;
	startModCuad		= 1'd0;
	startMultirate		= 1'd0;
	startScope			= 1'd0;
	startMapper			= 1'd0;
	
	config_regScopeW	= 32'd0;
	set_scopeConfig	= 1'd0;	
	
	cnt_on				= 1'd0;
	cntAvg_on			= 1'd0;
	cntAvg_rst			= 1'd0;
	cnt_rst				= 1'd0;
		
	done_flag			= 1'd0;


	case(state_reg)
		
		IDLE			:	begin
								if(start == 1'd1 || restart == 1'd1)begin
									cnt_rst = 1'd1;
									cntAvg_rst = 1'd1;
//									startDecim = 1'd1;
//									state_next = DECIM_BUSY;
									state_next = RESET_SCOPE;
									set_scopeConfig = 1'd1;
									config_regScopeW = 32'h000000ff;
								end
								
							end
							
		RESET_SCOPE	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									cnt_on = 1'd1;
									startScope = 1'd1;
									state_next = WAITRST_DONE;
								end
								
							end
							
		WAITRST_DONE	: 	begin
		
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									
									else begin
										cnt_on = 1'd1;
										if(cntTime == CLK_REF)begin
											cnt_rst = 1'd1;
											set_scopeConfig = 1'd1;
											config_regScopeW = 32'h00000021;
											state_next = INVMODE_SCOPE;
										end
									end
									
								end
		
		INVMODE_SCOPE	: 	begin
		
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									
									else begin
										startScope = 1'd1;
										state_next = WAITINV_DONE;
									end
									
								end
								
		WAITINV_DONE	: 	begin
		
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									
									else begin
										if(doneScope == 1'd1)begin
											startDecim = 1'd1;
											state_next = DECIM_BUSY;
										end
									end
									
								end						
		
		DECIM_BUSY	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneDecim == 1'd1)begin
										startFFT = 1'd1;
										state_next = FFT_BUSY;
									end	
								end

							end
		
		FFT_BUSY	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneFFT == 1'd1)begin
										startModCuad= 1'd1;
										state_next = MODCUAD_BUSY;
									end	
								end

							end
							
		MODCUAD_BUSY	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneModCuad == 1'd1)begin
										startMultirate = 1'd1;
										state_next = MULTIR_BUSY;
									end	
								end

							end	
			
		MULTIR_BUSY	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneMultirate == 1'd1)begin
										startMapper = 1'd1;
										state_next = MAPPER_BUSY;
									end	
								end

							end
	
		MAPPER_BUSY	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneMapper == 1'd1)begin
										if(cntAvg < avg_min)begin
											cntAvg_on = 1'd1;
											startDecim = 1'd1;
											state_next = DECIM_BUSY;
										end
										else begin
											cntAvg_rst = 1'd1;
											config_regScopeW = {8'h00, WHITE, BLACK, 16'h002c};//32'h0017002c;
											set_scopeConfig = 1'd1;
											state_next = WRITE_SCOPE;
										end
									end	
								end

							end					
							
		WRITE_SCOPE	: 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									startScope = 1'd1;
									state_next = WAITWR_DONE;	
								end

							end					
		
		WAITWR_DONE :	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else begin
									if(doneScope == 1'd1)begin
										if(scopeFreeze == 1'd1)begin
											state_next = HOLD_ON;
										end
										else begin
											state_next = DONE;
										end
									end
								end

							end
		
		HOLD_ON		:	begin
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								else begin
									if(scopeFreeze == 1'd0)begin
										state_next = DONE;
									end
								end	
							end						
		
		DONE			:	begin
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								else begin
									done_flag = 1'd1;
									startDecim = 1'd1;
									state_next = DECIM_BUSY;
								end	
							end	
		
		default		:	begin
								cnt_rst = 1'd1;
								state_next = RESET_SCOPE;
								set_scopeConfig = 1'd1;
								config_regScopeW = 32'h000000ff;
							end
		
	endcase

end

endmodule