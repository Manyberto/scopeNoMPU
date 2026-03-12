
module intpolFrac_controlpath #(
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd16,
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start,
input		wire									done_intpol,
input		wire									done_decim,
output	reg									start_intpol,
output	reg									start_decim,
output	wire									busy_flag,
output	reg									done_flag		
);

localparam 		IDLE 			= 2'd0;
localparam		INTPOL_BUSY = 2'd1;
localparam		DECIM_START = 2'd2;
localparam		DONE			= 2'd3; 

reg[1:0]			state_reg;
reg[1:0]			state_next;

reg				restart;


assign busy_flag = (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1; 

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		state_reg				<= 3'd0;
		restart					<=	1'd0;	
	end
	
	else begin
		
		state_reg 				<= state_next;
		restart					<= start;
		
	end

end

always@(*)begin

	state_next 		= state_reg;

	done_flag		= 1'd0;
	
	start_intpol	= 1'd0;
	start_decim		= 1'd0;


	case(state_reg)
		
		IDLE			:	begin
								if(start == 1'd1 || restart == 1'd1)begin
									start_intpol = 1'd1;
									state_next = INTPOL_BUSY;
								end
							end
							
		INTPOL_BUSY : 	begin
		
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else if(done_intpol == 1'd1)begin
									state_next = DECIM_START;
									start_decim = 1'd1;
								end

							end
							
		DECIM_START :	begin
								
								if(start == 1'd1)begin
									state_next = IDLE;
								end
								
								else if(done_decim == 1'd1)begin
									state_next = DONE;
									done_flag = 1'd1;
								end
								
							end
		
		DONE			:	begin
								state_next = IDLE;	
							end	
		
		default		:	begin
								state_next = IDLE;
							end
		
	endcase

end

endmodule