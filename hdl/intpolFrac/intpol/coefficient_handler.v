
module coefficient_handler #(
parameter	REG_WIDTH	= 16,
parameter	V_INTERP_MAX_WIDTH	= 6
)
(
input		wire									clk,
input		wire									reset,
input		wire[V_INTERP_MAX_WIDTH-1:0]	index,
input		wire[REG_WIDTH-1:0]				PI,
input		wire[REG_WIDTH-1:0]				PJ,
input		wire[REG_WIDTH-1:0]				PK,
output	wire[REG_WIDTH-1:0]				PI_REG,
output	wire[REG_WIDTH-1:0]				PJ_REG,
output	wire[REG_WIDTH-1:0]				PK_REG
);

reg[REG_WIDTH-1:0]		PI_INT;
reg[REG_WIDTH-1:0]		PJ_INT;
reg[REG_WIDTH-1:0]		PK_INT;


assign PI_REG = (index > 'd0) ? PI_INT : PI;
assign PJ_REG = (index > 'd0) ? PJ_INT : PJ;
assign PK_REG = (index > 'd0) ? PK_INT : PK;

always@(posedge clk, negedge reset)begin

	if(reset == 1'd0)begin
		PI_INT <= {REG_WIDTH{1'd0}};
		PJ_INT <= {REG_WIDTH{1'd0}};
		PK_INT <= {REG_WIDTH{1'd0}};
	end
	
	else begin
		
		if(index == {V_INTERP_MAX_WIDTH{1'd0}})begin
			PI_INT <= PI;
			PJ_INT <= PJ;
			PK_INT <= PK;
		end
		
	end

end



endmodule
