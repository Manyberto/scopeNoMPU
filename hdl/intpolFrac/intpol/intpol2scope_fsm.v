
module intpol2scope_fsm #(
parameter	REG_WIDTH 				= 16,
parameter	MEM_IF_MAX_WIDTH		= 16,
parameter	V_INTERP_MAX_WIDTH	= 6,
parameter	INPUT_REG_ADDR_MAX	= 3,
parameter	SIZE2INTPOL_WIDTH		= 7,
parameter	OP_MODE_WIDTH			= 2
)
(
input		wire									clk,					
input		wire									reset,
input		wire									start,
input		wire									enable,
input		wire[V_INTERP_MAX_WIDTH-1:0]	V_INTERP,
input		wire[SIZE2INTPOL_WIDTH-1:0]	size2intpol,
input		wire									error_cfg_flag,
output	reg[V_INTERP_MAX_WIDTH-1:0]	index_out_reg,
output	reg									acc_en_out_reg,
output	reg									acc_rst_out_reg,
output	reg									bypass_flag_out_reg,
output	reg[MEM_IF_MAX_WIDTH-1:0]		r_addr_mem_in_0_out_reg,
output	reg[MEM_IF_MAX_WIDTH-1:0]		w_addr_mem_out_out_reg,
output	reg									w_en_mem_out_out_reg,
output	reg									w_en_reg_in_out_reg,
output	reg[INPUT_REG_ADDR_MAX-2:0]	w_addr_reg_in_out_reg,
output	reg									shift_reg_in_out_reg,
output	reg									copy_flag_reg,
output	reg									busy_flag_out_reg,
output	reg									clear_regin_out_reg,
output	reg									clear_datapath_out_reg,
output	reg									save_config_out_reg,
output	reg									done_flag_out_reg					
);		

localparam		IDLE 			= 4'd0;
localparam		CONFIG		= 4'd1;
localparam		READM0		= 4'd2;
localparam		READM1		= 4'd3;
localparam		READM2		= 4'd4;
localparam		WRITEM2		= 4'd5;
localparam		PROCESS		= 4'd6;
localparam		BYPASS		= 4'd7;
localparam		DONE			= 4'd8;
localparam		SHIFT			= 4'd9;
localparam		WAIT_CONFIG = 4'd10;
localparam		COPY_LAST	= 4'd11;


// -----------------------------------------------------------------------------------------------

reg[V_INTERP_MAX_WIDTH-1:0]	index;

reg[V_INTERP_MAX_WIDTH-1:0]	copy_cnt;
reg									copy_on;
reg									copy_rst;
	
reg									copy_flag;

reg[1:0]								copy_round;
reg									copy_round_on;
reg									copy_round_rst;

reg									acc_en;
wire									acc_rst;
reg									bypass_flag;

reg									r_addr_mem_in_rst;	
reg									r_addr_mem_in_add;
reg[MEM_IF_MAX_WIDTH-1:0]		r_addr_mem_in_0;

reg									w_addr_mem_out_rst;
reg									w_addr_mem_out_add;
reg[MEM_IF_MAX_WIDTH-1:0]		w_addr_mem_out;
reg									w_en_mem_out;

reg									w_en_reg_in;
reg[INPUT_REG_ADDR_MAX-2:0]	w_addr_reg_in;
reg									shift_reg_in;

reg[SIZE2INTPOL_WIDTH-1:0]		proc_num;
reg									proc_num_add;
reg									proc_num_rst;

wire									busy_flag;

wire									clear_regin;
wire									clear_datapath;
reg									save_config;
reg									done_flag;


reg[3:0]								state_next;
reg[3:0]								state_reg;
								
reg									index_add;
reg									index_reset;
					
wire									index_full;
reg									index_full_reg;
					
reg									restart;									
reg									bypass_done;
reg									bypass_mem_in;

assign acc_rst = index_full;
assign index_full = (index < V_INTERP) ? 1'd0 : 1'd1;
assign busy_flag	= (state_reg == IDLE || state_reg == DONE) ? 1'd0 : 1'd1;
assign clear_datapath = (index == V_INTERP) ? 1'd0 : 1'd1;
assign clear_regin	=	~(state_next == DONE || state_next == IDLE);

always@(posedge clk, negedge reset)begin
	
	if(reset == 1'd0)begin
		index_out_reg 				<= {V_INTERP_MAX_WIDTH{1'd0}};
		acc_en_out_reg				<= 1'd0;
		acc_rst_out_reg			<= 1'd0;
		bypass_flag_out_reg		<= 1'd0;
		r_addr_mem_in_0_out_reg <= {MEM_IF_MAX_WIDTH{1'd0}};
		w_addr_mem_out_out_reg	<= {MEM_IF_MAX_WIDTH{1'd0}};
		w_en_mem_out_out_reg		<= 1'd0;
		w_en_reg_in_out_reg		<= 1'd0;
		w_addr_reg_in_out_reg	<= {INPUT_REG_ADDR_MAX-1{1'd0}};
		shift_reg_in_out_reg		<= 1'd0;
		busy_flag_out_reg			<= 1'd0;
		clear_regin_out_reg		<= 1'd0;
		clear_datapath_out_reg	<= 1'd0;
		save_config_out_reg		<= 1'd0;
		done_flag_out_reg			<= 1'd0;
		copy_flag_reg				<= 1'd0;
	end
	
	else begin
		
		index_out_reg 				<= index;
		acc_en_out_reg				<= acc_en; 
		acc_rst_out_reg			<= acc_rst;	
		bypass_flag_out_reg		<= bypass_flag;
		r_addr_mem_in_0_out_reg <= r_addr_mem_in_0;
		w_addr_mem_out_out_reg	<= w_addr_mem_out;
		w_en_mem_out_out_reg		<= w_en_mem_out;
		w_en_reg_in_out_reg		<= w_en_reg_in;
		w_addr_reg_in_out_reg	<= w_addr_reg_in;
		shift_reg_in_out_reg		<= shift_reg_in;
		busy_flag_out_reg			<= busy_flag;
		clear_regin_out_reg		<= clear_regin;
		clear_datapath_out_reg	<= clear_datapath;
		save_config_out_reg		<= save_config;
		done_flag_out_reg			<= done_flag;
		copy_flag_reg				<= copy_flag;
		
	end

end

// -----------------------------------------------------------------------------------------------

always@(posedge clk, negedge reset)begin

	if(reset == 1'd0)begin
		state_reg 				<= IDLE;
		index						<= 'd0;
		index_full_reg			<= 1'd0;
		restart					<= 1'd0;
		bypass_done				<= 1'd0;
		r_addr_mem_in_0 		<= {MEM_IF_MAX_WIDTH{1'd0}};
		w_addr_mem_out			<= {MEM_IF_MAX_WIDTH{1'd0}};
		copy_round				<= 2'd0;
		copy_cnt					<= {V_INTERP_MAX_WIDTH{1'd0}};
		proc_num					<= {SIZE2INTPOL_WIDTH{1'd0}};
	end

	else begin
		
		state_reg 			<= state_next;
		index_full_reg		<= index_full;
		restart				<= start;
		copy_cnt				<= copy_cnt;
		copy_round			<= copy_round;
		
		proc_num				<= proc_num;
		r_addr_mem_in_0 	<= r_addr_mem_in_0;
		w_addr_mem_out 	<= w_addr_mem_out;
		index 				<= index;
		
		if(copy_round_rst == 1'd1)begin
			copy_round <= 2'd0;
		end
		
		else if(copy_round_on == 1'd1)begin
			copy_round <= copy_round + 1'd1;
		end
		
		if(copy_rst == 1'd1)begin
			copy_cnt	<= {V_INTERP_MAX_WIDTH{1'd0}};
		end
		
		else if(copy_on == 1'd1)begin
			copy_cnt <= copy_cnt + 1'd1;
		end
		
		if(w_addr_mem_out_rst == 1'd1)begin
			w_addr_mem_out	<= {MEM_IF_MAX_WIDTH{1'd0}};
		end
		
		else if(w_addr_mem_out_add == 1'd1)begin
			w_addr_mem_out <= w_addr_mem_out + 1'd1;
		end
		
		if(r_addr_mem_in_rst == 1'd1)begin
			r_addr_mem_in_0 		<= {MEM_IF_MAX_WIDTH{1'd0}};
		end
		
		else if(r_addr_mem_in_add == 1'd1)begin
			if(r_addr_mem_in_0 < size2intpol-1)begin
				r_addr_mem_in_0 <= r_addr_mem_in_0 + 1'd1;
			end
		end
		
		if(proc_num_rst == 1'd1)begin
			proc_num	<= {SIZE2INTPOL_WIDTH{1'd0}};
		end
		
		else if(proc_num_add == 1'd1)begin
			if(proc_num < size2intpol-1)begin
				proc_num <= proc_num + 1'd1;
			end	
		end

		if(index_full == 1'd1 || index_reset == 1'd1)begin
			index <= 0;
		end
		
		else if(index_add == 1'd1 || bypass_mem_in == 1'd1)begin
			if(index < V_INTERP)begin
				index 		<= index + 1'd1;
			end
		end
	
		if(index == 2)begin
			bypass_done <= 1'd1;
		end
		
		else begin
			bypass_done	<= 1'd0;
		end
		
	end
	
end


always@(*)begin

	state_next 				= 	state_reg;
	
	w_en_reg_in				=	1'd0;
	w_en_mem_out			=	1'd0;	
	w_addr_reg_in			= 	'd0;
	
	index_add				=	1'd0;
	
	done_flag				=	1'd0;
	
	shift_reg_in 			= 	1'd0;	
	
	acc_en					=	1'd0;
	
	bypass_flag				= 	1'd0;
	bypass_mem_in			= 	1'd0;
	
	index_reset				=	1'd0;
	
	proc_num_add			= 	1'd0;
	proc_num_rst			=	1'd0;
	
	save_config 			= 	1'd0;
	
	r_addr_mem_in_add		= 	1'd0;
	w_addr_mem_out_add	=	1'd0;
	
	w_addr_mem_out_rst	=	1'd0;
	r_addr_mem_in_rst		=	1'd0;
	
	copy_flag				= 	1'd0;
	copy_on					=	1'd0;
	copy_rst					= 	1'd0;
	
	copy_round_on			= 	1'd0;
	copy_round_rst			=	1'd0;
	
	case(state_reg)
	
		IDLE				:	begin
									
									if((start == 1'd1 || restart == 1'd1))begin
										index_reset 			= 1'd1;	
										w_addr_mem_out_rst	= 1'd1;
										r_addr_mem_in_rst		= 1'd1;
										proc_num_rst			= 1'd1;
										state_next 				= CONFIG;
										save_config 			= 1'd1;
									end	
									
								end
								
		CONFIG			:	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										state_next = WAIT_CONFIG;	
									end
								end
			
		WAIT_CONFIG		:	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										if(error_cfg_flag == 1'd0)begin
											state_next = READM0;
										end	
									end
								end		
								
		READM0			:	begin
			
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									
									else begin
										state_next 			= READM1;
										r_addr_mem_in_add	= 1'd1;
									end
									
								end
								
		READM1			:	begin
			
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										state_next 			= READM2;
										r_addr_mem_in_add	= 1'd1;
										w_en_reg_in			=	'd1;
										w_addr_reg_in		= 'd0;	
									end
								end
								
		READM2			:	begin
			
									if(start == 1'd1)begin
										state_next <= IDLE;
									end
									else begin
										state_next 			= WRITEM2;
										r_addr_mem_in_add	= 1'd1;
										w_en_reg_in			=	'd1;
										w_addr_reg_in		= 'd1;	
									end
									
								end
							
		WRITEM2			:	begin
									
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										w_en_reg_in			=	'd1;
										w_addr_reg_in		= 'd2;
										state_next 			= PROCESS;
									end
									
								end					
		
		PROCESS			:	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									
									else if(index_full_reg == 1'd0)begin
										
										if(index_full == 1'd0)begin
											index_add 				= 1'd1;
											w_addr_mem_out_add 	= 1'd1;	
										end
										
										w_en_mem_out	= 1'd1;
										acc_en			= 1'd1;
									end	
										
									else begin
										r_addr_mem_in_add	= 1'd1;
										shift_reg_in		= 1'd1;
										state_next 			= SHIFT;
									end	
									
								end
								
		BYPASS			:	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else if(bypass_done == 1'd0)begin
										bypass_flag		= 1'd1;
										bypass_mem_in	= 1'd1;
										w_en_mem_out	= 1'd1;
										shift_reg_in	=	1'd1;
									end	
									else begin
										state_next 		= IDLE;
									end
				
								end
		
		SHIFT				:	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										if(proc_num < size2intpol-2'd3)begin
											proc_num_add 	= 1'd1;
											w_en_reg_in		= 'd1;
											w_addr_reg_in	= 'd2;
											w_addr_mem_out_add 	= 1'd1;	
											state_next 		= PROCESS;
										end		
										else begin
											w_addr_mem_out_add 	= 1'd1;
											copy_round_on			= 1'd1;
											state_next 				= COPY_LAST;
										end
									end
								end
								
		COPY_LAST		: 	begin
									if(start == 1'd1)begin
										state_next = IDLE;
									end
									else begin
										
										if(copy_cnt < V_INTERP)begin
											w_addr_mem_out_add 	= 1'd1;
										end
										
										if(copy_cnt <= V_INTERP)begin
											copy_on		= 1'd1;
											copy_flag	= 1'd1;
											w_en_mem_out	= 1'd1;
										end
										else begin
											copy_rst		= 1'd1;
											if(copy_round < 2'd2)begin
												shift_reg_in	=	1'd1;
												state_next 		= SHIFT;
											end
											else begin
												copy_round_rst = 1'd1;
												state_next = DONE;
											end
										end
									end
										
										
								end
							
		DONE				:	begin
									done_flag 				= 1'd1;
									index_reset 			= 1'd1;	
									w_addr_mem_out_rst	= 1'd1;
									r_addr_mem_in_rst		= 1'd1;
									proc_num_rst			= 1'd1;
									state_next 				= IDLE;
								end
							
								
	endcase

end


endmodule