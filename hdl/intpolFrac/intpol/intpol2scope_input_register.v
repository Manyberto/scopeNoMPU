
module intpol2scope_input_register #(
parameter	REG_WIDTH = 16,
parameter	INPUT_REG_ADDR_MAX = 3	
)
(
input		wire									clk,			
input		wire									reset,	
input		wire[REG_WIDTH-1:0]				data_in,	
input		wire									w_en_reg_in,
input		wire[INPUT_REG_ADDR_MAX-2:0]	w_addr_reg_in,
input		wire									clear_regin,
input		wire									shift_reg_in,
output	wire[REG_WIDTH-1:0]				M0,			
output	wire[REG_WIDTH-1:0]				M1,			
output	wire[REG_WIDTH-1:0]				M2	

			
);

reg[REG_WIDTH-1:0]	reg_bank[0:INPUT_REG_ADDR_MAX-1];

always@(posedge clk, negedge reset)begin

	if(reset == 1'd0)begin
		reg_bank[0] <= {REG_WIDTH{1'd0}};
		reg_bank[1] <= {REG_WIDTH{1'd0}};
		reg_bank[2] <= {REG_WIDTH{1'd0}};
	end
	
	else begin
	
		if(clear_regin == 1'd0)begin
			reg_bank[0] <= {REG_WIDTH{1'd0}};
			reg_bank[1] <= {REG_WIDTH{1'd0}};
			reg_bank[2] <= {REG_WIDTH{1'd0}};
		end
		
		else 
		
			if(w_en_reg_in == 1'd1)begin
				reg_bank[w_addr_reg_in] <= data_in;
			end
			
			if(shift_reg_in == 1'd1)begin
				reg_bank[0] <= reg_bank[1];
				reg_bank[1] <= reg_bank[2];
				reg_bank[2] <= {REG_WIDTH{1'd0}};
			end
	end
	
end


assign	M0 = reg_bank[0];
assign	M1 = reg_bank[1];
assign	M2 = reg_bank[2];


endmodule