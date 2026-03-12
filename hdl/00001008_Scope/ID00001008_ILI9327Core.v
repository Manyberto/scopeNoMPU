
module ID00001008_ILI9327Core

#(
	parameter MAX_VIDEO_PAGES = 1, //10,		// Maximum number of video pages, each page contains 400 pixels. 
	parameter VIDEO_ADDR_MAX = 200, //2000,	// Maximum number of address for the video memory. 
	parameter VIDEO_MEM_WIDTH = 8, //11, 	// Address bus width for the video memory. 
	parameter PARAM_MEM_WIDTH = 5,		// Address bus width for the parameter memory.
	parameter ONE_mS = 50000,			// One milisecond parameter the value is the global clock frequency/1000.
	parameter CNT_1mS_WIDTH = 16		// Bus width for the miliseconds counter. 
)
(
	/*Global signals*/
	input reset,					// Global Reset.
	input clk,						// Global Clock.
	 
	/*IPDI interface signals*/
	input startIP,					// Starting IP core signal.
	input [31:0] ctrlReg,			// Control Register input data.
	input [31:0] videoMemIn,		// Video Memory input
	input [31:0] paramMemIn,		// Parameter Memory input
	
	output done,					// Asserted when the IP core is ready to execute other task.
	output busy,					// Asserted when the IP core is busy executing a task.
	
	output [VIDEO_MEM_WIDTH-1:0] addrVideoMem,	// Video Memory address.
	output [PARAM_MEM_WIDTH-1:0] addrParamMem,	// Parameter Memory address.
			
	/*ILI9327 signals*/
	output nRST,
	output SDA,					// Serial data to/from the display.
	output SCL,					// Clock to the display.
	output nCS					// Chip select for the display.
);
	wire ready;					// Indicates the TxCntrl block is ready to transmit a 9-bit data.
	wire dataTxDisplay;
	wire txInProgressDisplay;
	wire cfgTxStart;			// Asserted when configuration of the display starts.
	wire cmdTxStart;			// Asserted when a command/parameter data transmission to the display starts.	
	wire videoTxStart;			// Asserted when video data transmission to the display starts.
	
	/*Data to transmit signals*/
	wire [8:0]videoToTx;			// Video data to transmit to the display.
	wire [8:0]cmdToTx;				// Command/parameter data to transmit to the display.
	wire [8:0]configToTx;			// Config data to transmit to the display.
	
	/*Control signals*/
	wire txInProg;			// // Asserted when data transmission to the display is in progress.
	wire videoTxDone;				// Asserted when video data transmission is done.
	wire cmdTxDone;				// Asserted when command/parameter data transmission is done.
	wire cfgTxDone;				// Asserted when config data transmission is done.
	
	ID00001008_TxCntrl #(
				.SCL_HIGH		(2), 
				.SCL_LOW			(1), 
				.SCL_CNT_BIT	(2), 
				.TX_DATA_WIDTH	(9), 
				.TX_CNT_BIT		(4)
	)
	TxCntrl(
				.reset			(reset), 
				.clk				(clk), 
				.videoToTx		(videoToTx), 
				.cmdToTx			(cmdToTx), 
				.configToTx		(configToTx), 
				.cfgTxStart		(cfgTxStart), 
				.cmdTxStart		(cmdTxStart), 
				.videoTxStart	(videoTxStart), 
				.txInProgress	(txInProg), 
				.ready			(ready), 
				.SCL				(SCL),
				.SDA				(SDA), 
				.nCS				(nCS), 
				.videoTxDone	(videoTxDone), 
				.cmdTxDone		(cmdTxDone), 
				.cfgTxDone		(cfgTxDone), 
				.done				(done), 
				.busy				(busy)
	);
				 
	ID00001008_TxVideo #(
			.MAX_VIDEO_PAGES	(MAX_VIDEO_PAGES), 
			.VIDEO_ADDR_MAX	(VIDEO_ADDR_MAX), 
			.VIDEO_MEM_WIDTH	(VIDEO_MEM_WIDTH)
	) 
	TxVideo(
			.reset				(reset), 
			.clk					(clk), 
			.startIP				(startIP), 
			.command				(ctrlReg[7:0]), 
			.backColor			(ctrlReg[18:16]),
			.frontColor			(ctrlReg[22:20]),
			.videoMemIn			(videoMemIn), 
			.done					(videoTxDone),
			.addrVideoMem		(addrVideoMem), 
			.ready				(ready), 
			.videoTxStart		(videoTxStart),
			.dataToTx			(videoToTx), 
			.busy					(busy)
	);
			   
	ID00001008_TxCmd #(
			.PARAM_MEM_WIDTH(PARAM_MEM_WIDTH)
	) 
	TxCmd(
			.reset				(reset), 
			.clk					(clk), 
			.ctrlReg				(ctrlReg[15:0]), 
			.paramMemIn			(paramMemIn), 
			.done					(cmdTxDone), 
			.ready				(ready), 
			.cmdTxStart			(cmdTxStart),
			.busy					(busy), 
			.dataToTx			(cmdToTx), 
			.startIP				(startIP), 
			.addrParamMem		(addrParamMem)
	);
					
	ID00001008_TxConfig #(
			.ONE_mS				(ONE_mS)				/*Clock Frequency/1000*/, 
			.CNT_1mS_WIDTH		(CNT_1mS_WIDTH) 	/*Bit*/
	) 
	TxConfig(
			.reset				(reset), 
			.clk					(clk), 
			.startIP				(startIP), 
			.ctrlReg				(ctrlReg[7:0]), 
			.done					(cfgTxDone),
			.ready				(ready), 
			.nRST					(nRST),
			.busy					(busy), 
			.cfgTxStart			(cfgTxStart), 
			.dataToTx			(configToTx), 
			.txInProg			(txInProg)
	);
	 
	endmodule

