
module decoder_D3 #(
parameter	SEL_INTERP_WIDTH = 3,
parameter	V_INTERP_MAX_WIDTH = 7
)
(
input		wire[SEL_INTERP_WIDTH-1:0]					SEL_INTERP,
output	reg[V_INTERP_MAX_WIDTH-1:0]				V_INTERP,
output	reg[V_INTERP_MAX_WIDTH-1:0]				shift_D_X,
output	reg[V_INTERP_MAX_WIDTH-1:0]				shift_D_2X					
);


always@(*)begin

	case(SEL_INTERP)
		
		0 :	V_INTERP <= 'd1;
		1 :	V_INTERP <= 'd3;
		2 :	V_INTERP <= 'd7;
		3 :	V_INTERP <= 'd15;
		4 :	V_INTERP <= 'd31;
		5 :	V_INTERP <= 'd63;
		6 :	V_INTERP <= 'd127;
		7 :	V_INTERP <= 'd255;
		8 :	V_INTERP <= 'd511;
		9 :	V_INTERP <= 'd1023;
		
		default : V_INTERP <= 'd7;
		
	endcase
end


always@(*)begin
	
		case(SEL_INTERP)
		
			'd0	:	begin
							shift_D_X <= 'd1;
							shift_D_2X <= 'd2;
						end
			'd1	:	begin
							shift_D_X <= 'd2;
							shift_D_2X <= 'd4;
						end		
			'd2	:	begin
							shift_D_X <= 'd3;
							shift_D_2X <= 'd6;
						end
			'd3	:	begin
							shift_D_X <= 'd4;
							shift_D_2X <= 'd8;
						end
			'd4	:	begin
							shift_D_X <= 'd5;
							shift_D_2X <= 'd10;
						end
			'd5	:	begin
							shift_D_X <= 'd6;
							shift_D_2X <= 'd12;
						end		
			'd6	:	begin
							shift_D_X <= 'd7;
							shift_D_2X <= 'd14;
						end
						
			'd7	:	begin
							shift_D_X <= 'd8;
							shift_D_2X <= 'd16;
						end
			
			'd8	:	begin
							shift_D_X <= 'd9;
							shift_D_2X <= 'd18;
						end
					
			'd9	:	begin
							shift_D_X <= 'd10;
							shift_D_2X <= 'd20;
						end		
						
			default : 	begin
			
								shift_D_X <= 'd3;
								shift_D_2X <= 'd6;
						
							end
		endcase
	
end

endmodule
