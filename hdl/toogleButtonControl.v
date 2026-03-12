
module toogleButtonControl#(
parameter	ADDR_WIDTH = 2, 
parameter	SEL_LIMIT  = 5	
)
(
input		wire						clk,
input		wire						rstn,
input		wire						start,
input		wire						button,
input		wire[ADDR_WIDTH-1:0]	load,
output	wire[ADDR_WIDTH-1:0]	selOut
);

localparam 	IDLE 			= 2'd0;
localparam 	WAIT_TOGGLE	= 2'd1;
localparam 	WAIT_DBC		= 2'd2;
localparam 	RST			= 2'd3;

localparam	[ADDR_WIDTH-1:0] CNT_LIMIT = SEL_LIMIT[ADDR_WIDTH-1:0]-1'd1;

reg[1:0]		state_reg;
reg[1:0]		state_next;

reg[ADDR_WIDTH-1:0]	cntToggle;
reg						cnt_on;
reg						cnt_rst;

reg[7:0]					cnt_dbc;
reg						cnt_dbcOn;
reg						cnt_dbcRst;

assign selOut = cntToggle;

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg <= 2'd0;
		cntToggle <= {ADDR_WIDTH{1'd0}};
		cnt_dbc <= {8{1'd0}};
	end
	
	else begin
		
		state_reg <= state_next;
		
		cntToggle <= cntToggle;
		cnt_dbc <= cnt_dbc;
		
		if(cnt_rst == 1'd1)begin
			cntToggle <= load;
		end
		
		else if(cnt_on == 1'd1)begin
			cntToggle <= cntToggle + 1'd1;
			if(cntToggle == CNT_LIMIT)begin
				cntToggle <= {ADDR_WIDTH{1'd0}};
			end
		end
		
		if(cnt_dbcRst == 1'd1)begin
			cnt_dbc <= {8{1'd0}};
		end
		
		else if(cnt_dbcOn == 1'd1)begin
			cnt_dbc <= cnt_dbc + 1'd1;
		end
		
		
	end
	
end

always@(*)begin
	
	state_next 	= state_reg;
	
	cnt_on 		= 1'd0;
	cnt_rst 		= 1'd0;
	
	cnt_dbcOn 		= 1'd0;
	cnt_dbcRst 		= 1'd0;
	
	case(state_reg)
		
		IDLE		: 		begin
		
								if(start == 1'd1)begin
									cnt_rst = 1'd1;
								end
								
								else begin
									if(button == 1'd1)begin
										state_next = WAIT_TOGGLE;
									end	
								end
								
							end
							
		WAIT_TOGGLE	:	begin
								
								if(start == 1'd1)begin
									state_next = RST;
								end
								
								else begin
									if(button == 1'd0)begin
										state_next = WAIT_DBC;
										cnt_dbcOn = 1'd1;
									end
								end
								
							end
							
		WAIT_DBC		:	begin
								
								if(start == 1'd1)begin
									state_next = RST;
								end
								
								else begin
									cnt_dbcOn = 1'd1;
									if(cnt_dbc == 8'd100)begin
										state_next = IDLE;
										cnt_dbcRst = 1'd1;
										cnt_on = 1'd1;
									end
								end
								
							end
							
		RST			:	begin
								cnt_dbcRst = 1'd1;
								cnt_rst = 1'd1;
								state_next = IDLE;
							end
							
		default		:	begin
								cnt_dbcRst = 1'd1;
								cnt_rst = 1'd1;
								state_next = IDLE;
							end
	
	endcase
	
end

endmodule