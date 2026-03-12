
module dividerSig_controlpath #(
parameter		DATAPATH_WIDTH = 16,
parameter		ELEMENTS			= 2		
)
(
input		wire						clk,
input		wire						rstn,
input		wire						start,
output	wire						sel_muxPi,
output	wire						valid_data,
output	reg						done
);

// Declaración de parámetros ---------------------------------------
 
localparam ITERATIONS = DATAPATH_WIDTH/ELEMENTS; 
localparam ITERATIONS_MINUS = ITERATIONS - 1;
localparam COUNT_WIDTH = ($clog2(ITERATIONS) > 0) ? $clog2(ITERATIONS) : 1;

localparam IDLE 	= 2'd0;
localparam COUNT 	= 2'd1;
localparam DONE 	= 2'd2;


// Declaración de señales ------------------------------------------

reg[1:0]					state_next;
reg[1:0] 				state_reg;

reg						restart;

reg						cnt_on;
reg						cnt_rst;
reg[COUNT_WIDTH-1:0]	cnt;


assign valid_data = cnt_rst;
assign sel_muxPi = (cnt > {COUNT_WIDTH{1'd0}}) ? 1'd1 : 1'd0;

always @(posedge clk, negedge rstn)begin

	if(rstn == 1'd0)begin
		state_reg <= 2'd0;
		restart <= 1'd0;
		cnt <= {COUNT_WIDTH{1'd0}};
	end
	
	else begin
		state_reg <= state_next;
		restart <= start;
		
		if(cnt_rst == 1'd1)begin
			cnt <= {COUNT_WIDTH{1'd0}};
		end
		
		else if(cnt_on == 1'd1)begin
			cnt <= cnt + 1'd1;
		end
	end

end


always @(*)begin

	state_next 	<= state_reg;
	
	cnt_on 		<= 1'd0;
	cnt_rst		<= 1'd0;
	
	done			<= 1'd0;
	
	case(state_reg)
	
	
		IDLE 	:		begin
		
							if(start == 1'd1 || restart == 1'd1)begin
								state_next <= COUNT;
							end
		
						end
						
		COUNT : 		begin
							
							if(start == 1'd1)begin
								state_next <= IDLE;
							end
							
							else begin
								
								if(cnt < ITERATIONS_MINUS)begin
									cnt_on <= 1'd1;
								end
								
								else begin
									cnt_rst <= 1'd1;
									state_next <= DONE;
								end
								
							end
							
						end
						
		DONE	:		begin
							
							state_next <= IDLE;
							done <= 1'd1;
							
						end
						
		default :	begin
							state_next <= IDLE;
						end
	
	
	endcase

end

endmodule