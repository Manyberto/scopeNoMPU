
module ID00001011_scopeNoMPU_datapath #(
parameter	DATA_WIDTH_IFC		= 'd32,
parameter	AVG_WIDTH			= 'd16,
parameter	MEM_IFC_MAX_WIDTH	= 'd16,
parameter	ADDR_WIDTH			= 'd13,
parameter	CONFIG_REG_WIDTH	= 'd32,
parameter	STATUS_REG_WIDTH	= 'd8,
parameter	DATAPATH_WIDTH		= 'd16	
)
(
input		wire									clk,
input		wire									rstn,
input		wire									start,
input		wire									zoomButton,
input		wire									avgRound1Cmp,
input		wire									valid_data,
input		wire									startDecim,
input		wire									startFFT,
input		wire									startModCuad,
input		wire									startMultirate,
input		wire									startMapper,
input		wire									startScope,
input		wire[AVG_WIDTH-1:0]				avg,
input		wire[3:0]							config_upperDotWidth,
input		wire[3:0]							config_lowerDotWidth,
input		wire[2*CONFIG_REG_WIDTH-1:0]	config_regIntpolFrac,
input		wire[CONFIG_REG_WIDTH-1:0]		config_regDecimExt,
input		wire[CONFIG_REG_WIDTH-1:0]		config_regScope,
input		wire[DATA_WIDTH_IFC-1:0]		data_MemInReal,
input		wire[DATA_WIDTH_IFC-1:0]		data_MemInImag,
input		wire[DATAPATH_WIDTH-1:0]		dataStreamReal_in,
input		wire[DATAPATH_WIDTH-1:0]		dataStreamImag_in,
output	wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mem,
output	wire									doneDecim,
output	wire									doneFFT,
output	wire									doneModCuad,
output	wire									doneMultirate,
output	wire									doneScope,
output	wire									doneMapper,
output 	wire									nRST,					// Reset to display
output 	wire									SDA,					// Serial data to/from the display.
output 	wire									SCL,					// Clock to the display.
output 	wire									nCS					// Chip select for the display.
);

// Declaracion de parametros locales --------------------------------------------------------------------------------------------------------------------------------

localparam	FFT_LENGTH			 = 'd128;
localparam	LOG2_FFTL			 = 'd7;
localparam 	FFT_DATAPATH_WIDTH = 'd17;
localparam	QM						 = 'd1;
localparam	QN						 = 'd15;

localparam	DECIMFACTORINIT	 = 'd1;
localparam	SIZE2DECIMINIT	 	 = FFT_LENGTH;

localparam	NUMBCKGRND			 = 'd6;
localparam	NUMBCKGRND_WIDTH	 = 'd3;

localparam MAX_VIDEO_PAGES = 240; 		// Maximum number of video pages, each page contains 400 pixels. 
localparam VIDEO_ADDR_MAX 	= 3000;		//MAX_VIDEO_PAGES * 400 / 32 = 200*12.5; // Maximum number of address for the video memory. 
localparam VIDEO_MEM_WIDTH = 12; 		//11, 	// Address bus width for the video memory. 
localparam PARAM_MEM_WIDTH = 4;			// Address bus width for the parameter memory.
localparam ONE_mS 			= 50000;		// One milisecond parameter the value is the global clock frequency/1000.
localparam CNT_1mS_WIDTH 	= 16;			// Bus width for the miliseconds counter. 
// ------------------------------------------------------------------------------------------------------------------------------------------------------------------
													
reg[DATAPATH_WIDTH-1:0]					data2Mapper;
wire[DATA_WIDTH_IFC-1:0]				dataMapped;
wire											dataBitMapped;
wire[DATA_WIDTH_IFC-1:0]				data2ScopeBckGrnd;
reg[DATA_WIDTH_IFC-1:0]					data2Scope;

wire[DATA_WIDTH_IFC-1:0]				scopeBckGrndGrid;
wire[DATA_WIDTH_IFC*NUMBCKGRND-1:0]	scopeBckGrnd;
wire[DATA_WIDTH_IFC-1:0]				scopeBckGrnd_mux;
wire[DATA_WIDTH_IFC-1:0]				scopeBckGrndValues_mux;
wire[DATA_WIDTH_IFC-1:0]				scopeBckGrndPacked[0:NUMBCKGRND-1];

wire[NUMBCKGRND_WIDTH-1:0]				selBckGrnd;
wire[NUMBCKGRND_WIDTH-1:0]				stepOrigin;
wire[NUMBCKGRND_WIDTH:0]				addBckGrnd;
wire[NUMBCKGRND_WIDTH:0]				adjBckGrnd;
wire[NUMBCKGRND_WIDTH-1:0]				addressBckGrnd;

wire signed[DATAPATH_WIDTH-1:0]		dataDecimRealNorm;
wire signed[DATAPATH_WIDTH-1:0]		dataDecimReal_out;
wire signed[DATAPATH_WIDTH-1:0]		dataDecimImagNorm;
wire signed[DATAPATH_WIDTH-1:0]		dataDecimImag_out;
wire[2*DATAPATH_WIDTH-1:0]				dataFFTOut;
wire[DATA_WIDTH_IFC-1:0]				dataFFTOutReal;
wire[DATA_WIDTH_IFC-1:0]				dataFFTOutImag;
wire[DATAPATH_WIDTH+QM-1:0]			dataCuadOut;
wire[DATAPATH_WIDTH+QM-1:0]			dataMultirateOut;
wire[DATAPATH_WIDTH-1:0]				dataMultirateSavedMux;

reg[2*DATAPATH_WIDTH-1:0]		dataDecim[0:127];
reg[2*DATAPATH_WIDTH-1:0]		dataFFTSaved[0:127];
reg[DATAPATH_WIDTH+QM-1:0]		dataCuadSaved[0:127];
reg[DATAPATH_WIDTH-1:0]			dataMultirateSaved[0:371];
reg[DATA_WIDTH_IFC-1:0]			dataMapped_localMem[0:2999];

reg[2*DATAPATH_WIDTH-1:0]		data2FFT;
reg[2*DATAPATH_WIDTH-1:0]		data2ModCuad;
reg[DATAPATH_WIDTH+QM-1:0]		data2Multirate;

wire[4:0]							local_bit;

wire[STATUS_REG_WIDTH-1:0]		status_regDecim;
wire[2*STATUS_REG_WIDTH-1:0]	status_regFFT;
wire[STATUS_REG_WIDTH-1:0]		status_regModCuad;
wire[STATUS_REG_WIDTH-1:0]		status_regMultirate;
wire[STATUS_REG_WIDTH-1:0]		status_regMapper;
wire[STATUS_REG_WIDTH-1:0]		status_regScope;

wire[CONFIG_REG_WIDTH*4-1:0]	config_regMapper;
wire[CONFIG_REG_WIDTH*4-1:0]	config_regDecim;
wire[CONFIG_REG_WIDTH-1:0]		config_regDecimExtZoom;

wire[CONFIG_REG_WIDTH*4-1:0]	config_regModCuad;
wire[CONFIG_REG_WIDTH*4-1:0]	config_regMultirate;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_mapperMem;

wire[VIDEO_MEM_WIDTH-1:0]		rd_addr_mapped_localMem;
wire[VIDEO_MEM_WIDTH-1:0]		rd_addr_mappedGrid_localMem;

wire[MEM_IFC_MAX_WIDTH-1:0]	wr_addr_mapped_localMem;
reg[MEM_IFC_MAX_WIDTH-1:0]		wr_addr_mapped_localMem_reg;
wire									wr_en_mapped_localMem;
wire									wr_en_local_bit;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_FFTMem;
wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_FFTMem;
wire									write_en_FFTMem;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_modCuadMem;
wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_fftShift;
wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_modCuadMem;
wire									write_en_modCuadMem;

wire[MEM_IFC_MAX_WIDTH-1:0]	read_addr_multirateMem;
wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_multirateMem;
wire									write_en_multirateMem;

wire[MEM_IFC_MAX_WIDTH-1:0]	write_addr_DecimMem;
wire									write_en_DecimMem;

wire[12:0]							inputDecimFactor;
wire[12:0]							inputDecimFactorZoom;
wire[12:0]							sizeInputDecim;
wire[12:0]							sizeInputDecimZoom;
wire[NUMBCKGRND_WIDTH-1:0]		selBckGrndOrigin;

// Intentar reducir la cantidad de memoria

assign inputDecimFactor 	= DECIMFACTORINIT[12:0];
assign sizeInputDecim 		= SIZE2DECIMINIT[12:0];
assign selBckGrndOrigin		= config_regDecimExt[NUMBCKGRND_WIDTH-1 -:NUMBCKGRND_WIDTH];
assign stepOrigin				= config_regDecimExt[2*NUMBCKGRND_WIDTH-1 -:NUMBCKGRND_WIDTH];

assign inputDecimFactorZoom = inputDecimFactor << selBckGrnd;
assign sizeInputDecimZoom = sizeInputDecim << selBckGrnd;

assign config_regDecimExtZoom = {config_regDecimExt[CONFIG_REG_WIDTH-1], 5'd0, sizeInputDecimZoom, inputDecimFactorZoom};

assign config_regMapper 	= { {2*CONFIG_REG_WIDTH{1'd0}}, { {CONFIG_REG_WIDTH-4{1'd0}}, config_upperDotWidth }, { {CONFIG_REG_WIDTH-4{1'd0}}, config_lowerDotWidth}};
assign config_regDecim 	 	= { {3*CONFIG_REG_WIDTH{1'd0}}, config_regDecimExtZoom};

assign config_regModCuad   = { {3*CONFIG_REG_WIDTH{1'd0}}, FFT_LENGTH};

assign config_regMultirate = { {2*CONFIG_REG_WIDTH{1'd0}}, config_regIntpolFrac};

assign doneMapper 	= status_regMapper[0];
assign doneDecim 		= status_regDecim[0];
assign doneFFT 		= status_regFFT[0];
assign doneModCuad 	= status_regModCuad[0];
assign doneMultirate = status_regMultirate[0];

assign addBckGrnd = selBckGrnd + stepOrigin;
assign adjBckGrnd = addBckGrnd-NUMBCKGRND[NUMBCKGRND_WIDTH-1:0];

assign addressBckGrnd = (addBckGrnd >= NUMBCKGRND[NUMBCKGRND_WIDTH-1:0]) ? adjBckGrnd[NUMBCKGRND_WIDTH-1:0] : addBckGrnd[NUMBCKGRND_WIDTH-1:0];

assign data2ScopeBckGrnd = data2Scope | scopeBckGrnd_mux;

// Zoom scope ---------------------------------------------------
		
toogleButtonControl #(
	.ADDR_WIDTH			(NUMBCKGRND_WIDTH),
	.SEL_LIMIT			(NUMBCKGRND)
)
ZMBUTTON(
	.clk					(clk),
	.rstn					(rstn),
	.start				(start),
	.button				(zoomButton),
	.load					(selBckGrndOrigin),
	.selOut				(selBckGrnd)
);

// DECIMADOR de ENTRADA -----------------------------------------

ID00001009_decim2scope_core	#(
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
	.ADDR_WIDTH					(ADDR_WIDTH),
	.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
ID00001009_DECIM_CORE (		
	.clk							(clk),
	.rstn                	(rstn),
	.start               	(startDecim),	
	.valid_data            	(valid_data),	
	.data_from_mem				(data_MemInReal[DATAPATH_WIDTH-1:0]),		
	.data_from_mem1			(data_MemInImag[DATAPATH_WIDTH-1:0]),		
	.data_in						(dataStreamReal_in),	
	.data_in1					(dataStreamImag_in),	
	.read_addr_mem       	(read_addr_mem),
	.write_addr_mem      	(write_addr_DecimMem),
	.write_enable_mem       (write_en_DecimMem),
	.data_out  		         (dataDecimReal_out),
	.data_out1 		         (dataDecimImag_out),
	.config_reg			      (config_regDecim),			
	.status_reg				   (status_regDecim)			
);

// Memoria intermedia entre Decimador de entrada y la FFT -------

//assign dataDecimRealNorm = dataDecimReal_out >>> QM_SHIFT;
//assign dataDecimImagNorm = dataDecimImag_out >>> QM_SHIFT;

always@(posedge clk)begin
	
	if(write_en_DecimMem == 1'd1)begin
		dataDecim[write_addr_DecimMem] <= {dataDecimReal_out, dataDecimImag_out};
	end
	
	data2FFT <= dataDecim[read_addr_FFTMem];
	
end

// FFT ----------------------------------------------------------

wire[LOG2_FFTL-1:0] 					aux_addr_pa_to_sm;
wire[2*FFT_DATAPATH_WIDTH-1:0] 	aux_data_a_to_sm;
wire[LOG2_FFTL-1:0] 					aux_addr_pb_to_sm;
wire[2*FFT_DATAPATH_WIDTH-1:0] 	aux_data_b_to_sm;
wire[2*FFT_DATAPATH_WIDTH-1:0] 	sec_sal;
wire[2*FFT_DATAPATH_WIDTH-1:0] 	aux_sal_b_mb;

wire aux_wr_a_to_sm;
wire aux_wr_b_to_sm;

assign read_addr_FFTMem[MEM_IFC_MAX_WIDTH-1 : LOG2_FFTL] = {MEM_IFC_MAX_WIDTH-LOG2_FFTL{1'd0}};
assign write_addr_FFTMem[MEM_IFC_MAX_WIDTH-1 : LOG2_FFTL] = {MEM_IFC_MAX_WIDTH-LOG2_FFTL{1'd0}};

ID0000204D_FFT_core FFT_Inst(	
   .rst_a						(rstn),		
	.clk							(clk),			
	.en_s							(1'd1),		 
	
	.if_in_real					({ {DATA_WIDTH_IFC-FFT_DATAPATH_WIDTH{1'd0}}, data2FFT[31:16], 1'd0}), 						// real data bus 
	.if_in_imag					({ {DATA_WIDTH_IFC-FFT_DATAPATH_WIDTH{1'd0}}, data2FFT[15:0], 1'd0}), 						// imag data bus
	.rd_addr_MemIn				(read_addr_FFTMem[LOG2_FFTL-1:0]),
	.if_out_real				(dataFFTOutReal),
	.if_out_imag				(dataFFTOutImag),
	.wr_en_MemOut				(write_en_FFTMem),										// write for Mem. Out
	.wr_addr_MemOut			(write_addr_FFTMem[LOG2_FFTL-1:0]),
	.rd_addr_ConfigReg		(),
	.data_ConfigReg			(32'd0),     //data readed for configuration register
	
	.aux_data_a_to_sm			(aux_data_a_to_sm),
	.aux_data_b_to_sm			(aux_data_b_to_sm),
	.aux_addr_pa_to_sm		(aux_addr_pa_to_sm),
	.aux_addr_pb_to_sm		(aux_addr_pb_to_sm),
	.aux_wr_a_to_sm			(aux_wr_a_to_sm),
	.aux_wr_b_to_sm			(aux_wr_b_to_sm),
	.sec_sal						(sec_sal),
	.aux_sal_b_mb				(aux_sal_b_mb),
	
	.status_IPcore				(status_regFFT),
	.start_IP					(startFFT) 					 // start transformation

);

assign dataFFTOut = {dataFFTOutReal[16:1], dataFFTOutImag[16:1]};

true_dual_port_ram_single_clock#( 2*FFT_DATAPATH_WIDTH, LOG2_FFTL )
RAM1
(
	.data_a(aux_data_a_to_sm),
	.data_b(aux_data_b_to_sm),
	.addr_a(aux_addr_pa_to_sm),
	.addr_b(aux_addr_pb_to_sm),
	.we_a(aux_wr_a_to_sm),
	.we_b(aux_wr_b_to_sm),
	.clk(clk),
	.q_a(sec_sal),
	.q_b(aux_sal_b_mb)
);

// Memoria intermedia entre la FFT y el Modulo al cuadrado

always@(posedge clk)begin
	
	if(write_en_FFTMem == 1'd1)begin
		dataFFTSaved[write_addr_FFTMem] <= dataFFTOut;
	end
	
	data2ModCuad <= dataFFTSaved[read_addr_fftShift];
	
end


// FFTSHIFT -----------------------------------------------------

fftshift #(
	.ADDR_WIDTH		(MEM_IFC_MAX_WIDTH)
)
FFTSHIFT(
	.addr_in			(read_addr_modCuadMem),
	.addr_out		(read_addr_fftShift)
);

// MODOULO AL CUADRADO ------------------------------------------

ID0000100C_modCuad_core	#(
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
	.QM							(QM),
	.QN							(QN),
	.DATAPATH_WIDTH			(DATAPATH_WIDTH)
)
MODCUAD_CORE (		
	.clk							(clk),
	.rstn                	(rstn),
	.start               	(startModCuad),	
	.data_MemInReal			({ {16{1'd0}}, data2ModCuad[31:16]}),	
	.data_MemInImag			({ {16{1'd0}}, data2ModCuad[15:0]}),	
	.read_addr_mem       	(read_addr_modCuadMem),
	.write_addr_mem      	(write_addr_modCuadMem),
	.write_enable_mem       (write_en_modCuadMem),
	.data_out	         	(dataCuadOut),
	.config_reg			      (config_regModCuad),			
	.status_reg				   (status_regModCuad)				
);

// Memoria intermedia entre el ModCuad y el Multirate

always@(posedge clk)begin
	
	if(write_en_modCuadMem == 1'd1)begin
		dataCuadSaved[write_addr_modCuadMem] <= dataCuadOut;
	end
	
	data2Multirate <= dataCuadSaved[read_addr_multirateMem];
	
end

// MULTIRATE ----------------------------------------------------

intpolFrac_core	#(
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH),
	.ADDR_WIDTH					(ADDR_WIDTH),
	.QM							(2*QM),
	.QN							(QN),
	.DATAPATH_WIDTH			(DATAPATH_WIDTH+QM)
)
INTPOLFRAC_CORE (		
	.clk							(clk),
	.rstn                	(rstn),
	.start               	(startMultirate),	
	.data_from_mem				(data2Multirate),	
	.read_addr_mem       	(read_addr_multirateMem),
	.write_addr_mem      	(write_addr_multirateMem),
	.write_enable_mem       (write_en_multirateMem),
	.data_out  		         (dataMultirateOut),
	.config_reg			      (config_regMultirate),			
	.status_reg				   (status_regMultirate)				
);

// Memoria intermedia entre el Multirate y el Mapeador

assign dataMultirateSavedMux = (dataMultirateOut[DATAPATH_WIDTH+QM-1] == 1'd1) ? {DATAPATH_WIDTH{1'd0}}
																										 : dataMultirateOut[DATAPATH_WIDTH+QM-1 -:DATAPATH_WIDTH];
always@(posedge clk)begin
	
	if(write_en_multirateMem == 1'd1)begin
		dataMultirateSaved[write_addr_multirateMem] <= dataMultirateSavedMux;
	end
	
	data2Mapper <= dataMultirateSaved[read_addr_mapperMem];
	
end

// MAPEADOR -----------------------------------------------------

ID00001012_scopeSignalMapper_core #(
	.DATAPATH_WIDTH			(DATAPATH_WIDTH),
	.AVG_WIDTH					(AVG_WIDTH),
	.MEM_IFC_MAX_WIDTH		(MEM_IFC_MAX_WIDTH),
	.DATA_WIDTH_IFC			(DATA_WIDTH_IFC),
	.CONFIG_REG_WIDTH			(CONFIG_REG_WIDTH),
	.STATUS_REG_WIDTH			(STATUS_REG_WIDTH)
)
MAPPERCORE(
	.clk							(clk),				
	.rstn			            (rstn),			
	.avgRound1Cmp           (avgRound1Cmp),
	.start                  (startMapper),
	.avg			            (avg),
	.data_in		            (data2Mapper),
	.read_addr_mem				(read_addr_mapperMem),
	.write_addr_mem			(wr_addr_mapped_localMem),
	.write_enable_mem			(wr_en_mapped_localMem),
	.data_out               (dataBitMapped),	
	.wr_en_local_bit			(wr_en_local_bit),	
	.local_bit					(local_bit),
	.config_reg	            (config_regMapper),	
	.status_reg	            (status_regMapper)	
);

always@(posedge clk, negedge rstn)begin
	
	if(rstn == 1'd0)begin
		wr_addr_mapped_localMem_reg <= {MEM_IFC_MAX_WIDTH{1'd0}};
	end
	
	else begin
		wr_addr_mapped_localMem_reg <= wr_addr_mapped_localMem;
	end
	
end													
	
// MEMORIA INTERMEDIA DEL MAPEADOR Y SCREEN ---------------------	
	
always@(posedge clk)begin
	
	if(wr_en_mapped_localMem == 1'd1)begin
		dataMapped_localMem[wr_addr_mapped_localMem_reg] <= dataMapped;
	end
	
	data2Scope <= dataMapped_localMem[rd_addr_mapped_localMem];
	
end

regBitMem #(
	.DATAPATH_WIDTH	(DATA_WIDTH_IFC)
)
RBM(
	.clk					(clk),
	.rstn					(rstn),
	.wr_en				(wr_en_local_bit),
	.data_in				(dataBitMapped),
	.addr_in				(local_bit),
	.data_out			(dataMapped)
);
	

// Memoria con inicialización (background) del screen -------------

assign rd_addr_mappedGrid_localMem = rd_addr_mapped_localMem - 8'd250;

backgroundMem #(
	.DATAPATH_WIDTH	(DATA_WIDTH_IFC),
	.ADDR_WIDTH			(VIDEO_MEM_WIDTH)
)
BCKGRND(
	.clk					(clk),
	.wr_en				(1'd0),
	.wr_addr				({VIDEO_MEM_WIDTH{1'd0}}),
	.rd_addr				(rd_addr_mappedGrid_localMem),
	.data_in				({DATA_WIDTH_IFC{1'd0}}),
	.data_out			(scopeBckGrndGrid)
);

genvar idx;

generate
	
	for(idx = 0; idx < NUMBCKGRND; idx = idx + 1)begin : BCKBANK
		backgroundValuesMem #(
			.ID					(idx),
			.DATAPATH_WIDTH	(DATA_WIDTH_IFC),
			.ADDR_WIDTH			(8)
		)
		BCKGRND(
			.clk					(clk),
			.wr_en				(1'd0),
			.wr_addr				(8'd0),
			.rd_addr				(rd_addr_mapped_localMem[7:0]),
			.data_in				({DATA_WIDTH_IFC{1'd0}}),
			.data_out			(scopeBckGrnd[(DATA_WIDTH_IFC*(idx+1))-1 -: DATA_WIDTH_IFC])
		);
		
		assign scopeBckGrndPacked[idx] = scopeBckGrnd[(DATA_WIDTH_IFC*(idx+1))-1 -: DATA_WIDTH_IFC];
		
	end
	
endgenerate	

assign scopeBckGrndValues_mux = scopeBckGrndPacked[addressBckGrnd];

assign scopeBckGrnd_mux = (rd_addr_mapped_localMem < 8'd250) ? scopeBckGrndValues_mux : scopeBckGrndGrid;

// SCREEN ---------------------------------------------------------

ID00001008_ILI9327Core #(
	.MAX_VIDEO_PAGES			(MAX_VIDEO_PAGES), 
	.VIDEO_ADDR_MAX			(VIDEO_ADDR_MAX),  
	.VIDEO_MEM_WIDTH			(VIDEO_MEM_WIDTH), 
	.PARAM_MEM_WIDTH			(PARAM_MEM_WIDTH),
	.ONE_mS						(ONE_mS),
	.CNT_1mS_WIDTH				(CNT_1mS_WIDTH) 
)
	SCOPECORE(
	.clk							(clk),
	.reset						(rstn),				
	.startIP						(startScope),					
	.ctrlReg						(config_regScope),			
	.videoMemIn					(data2ScopeBckGrnd),		
	.paramMemIn					(),		
	.done							(doneScope),					
	.busy							(),					
	.addrVideoMem				(rd_addr_mapped_localMem),	// Video Memory address.
	.addrParamMem				(),											// Parameter Memory address.
	.nRST							(nRST),
	.SDA							(SDA),					
	.SCL							(SCL),					
	.nCS							(nCS)					
);	



endmodule