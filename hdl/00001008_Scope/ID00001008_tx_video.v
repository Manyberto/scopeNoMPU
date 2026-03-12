/*************************************************************************************************************
* \brief 
* Mario Munoz
* 15/06/2021
* Block used to get the video data from the video memory in order the "TxControl" reads the video data and
* send it to the ILI9327 chip driver.
* 
***************************************************************************************************************/
	
module ID00001008_TxVideo
#(
	parameter MAX_VIDEO_PAGES = 10,		// Indicates the maximum video pages stored in the video memory.
	parameter VIDEO_ADDR_MAX = 2000,	// Max video memory adddress
	parameter VIDEO_MEM_WIDTH = 11 		// Video memory width 
)
(	/*Global signals*/
	input reset,					// Global reset 
	input clk,						// Global clock 
	
	/*IPDI interface signals*/
	input startIP,					// Asserted to start IP Core.
	input busy,						// Asserted when the IP core is busy executing a task.
	input [7:0] command,			// Contains the command to execute.
	input	[2:0] backColor,
	input	[2:0] frontColor,
	input [31:0] videoMemIn,		// Video memory data input .
	
	output done,					// Asserted when video data transmission is done.
	output [VIDEO_MEM_WIDTH-1:0] addrVideoMem,	// Address for the video memory.

	/*Control signals*/
	input  ready,					// Indicates video data byte transmission is done.
	output videoTxStart,			// Asserted when video data transmission to the display is in progress.
	output reg [8:0] dataToTx		// Bit[8] command/parameter bit. Bit[7:0] contains the video data to be trasmitted to the display.	
);
	
	/*The "LI9327_command_ID.v" file contains the ILI9327 command IDs*/
	//`include "ILI9327_command_ID.v"
	localparam ILI9327_ENTER_SLEEP               = 8'h10;
    localparam ILI9327_EXIT_SLEEP               = 8'h11;
    localparam ILI9327_DISPLAY_OFF              = 8'h28;
    localparam ILI9327_DISPLAY_ON               = 8'h29;
    localparam ILI9327_SET_COL_ADDR             = 8'h2A;
    localparam ILI9327_SET_PAGE_ADDR            = 8'h2B;
    localparam ILI9327_WR_MEMORY_START        	= 8'h2C;
    localparam ILI9327_SET_ADDR_MODE            = 8'h36;
    localparam ILI9327_SET_PIXEL_FORMAT         = 8'h3A;
    localparam ILI9327_WR_MEMORY_CONTINUE			= 8'h3C;
    localparam ILI9327_PANEL_DRIVE_SETTING      = 8'hC0;
    localparam ILI9327_DISPLAY_TIMING           = 8'hC1;
    localparam ILI9327_DISPLAY_TIMING_IDLE      = 8'hC3;
    localparam ILI9327_FRAME_RATE_CONTROL       = 8'hC5;
    localparam ILI9327_GAMMA_SETTING            = 8'hC8;
    localparam ILI9327_POWER_SETTING            = 8'hD0;
    localparam ILI9327_VCOM_CONTROL             = 8'hD1;
    localparam ILI9327_POWER_SETTING_NORMAL     = 8'hD2;
    localparam ILI9327_3_GAMMA_FUNCTION_CONTROL = 8'hEA;
    localparam ILI9327_CONFIG_DISPLAY				= 8'hFF;

	
	/*************************************************************************************************************
	* \brief 
	* States used in FSM used to transmit video data to the display.
	* 
	***************************************************************************************************************/
	localparam WAIT_FOR_VIDEO 	= 0;
	localparam TX_WR_MEM_CMD 	= 1;
	
	localparam TX_SEND_BYTE_1 	= 2;
	localparam TX_SEND_BYTE_2  = 3;
	localparam TX_SEND_BYTE_3 	= 4;
	localparam TX_SEND_BYTE_4 	= 5;
	
	localparam TX_SEND_BYTE_5  = 6;
	localparam TX_SEND_BYTE_6 	= 7;
	localparam TX_SEND_BYTE_7 	= 8;
	localparam TX_SEND_BYTE_8 	= 9;
	
	localparam TX_SEND_BYTE_9 	= 10;
	localparam TX_SEND_BYTE_10 = 11;
	localparam TX_SEND_BYTE_11 = 12;
	localparam TX_SEND_BYTE_12 = 13;
	
	localparam TX_SEND_BYTE_13 = 14;
	localparam TX_SEND_BYTE_14 = 15;
	localparam TX_SEND_BYTE_15 = 16;
	localparam TX_SEND_BYTE_16 = 17;

	localparam READ_MEM 			= 18;
	
	/*************************************************************************************************
	* \brief 
	* Parameters for miscellaneous purposes. 
	* 
	*************************************************************************************************/
	localparam CMD = 1'b0;						// It is the Bit-8 of data and indicates a command is transmitted to the display.
	localparam DAT = 1'b1;						// It is the Bit-8 of data and indicates video or parameter is transmitted to the display.
	localparam [VIDEO_MEM_WIDTH-1:0] RESET = 0;						// Used when a signal is reset.
	localparam [7:0] FIX_TO_ZERO = 0;			// Used when a signal is set to zero.
	localparam [8:0] FIX_TO_FF = 9'h1ff;			// Used when a signal is set to 0xFF.	
	localparam DATA_WIDTH = 32;
	/*************************************************************************************************
	* \brief 
	* Signal used to indicate the last video data is transmitted. 
	* 
	*************************************************************************************************/
	wire lastData;								
	
	/*************************************************************************************************
	* \brief 
	* Registers used to store the current and next state of FSMs. 
	* 
	*************************************************************************************************/
	reg [4:0] currStFrame;	
	reg [4:0] nextStFrame;
	
	reg [VIDEO_MEM_WIDTH-1:0]addrMemCnt;
	
	/*************************************************************************************************************
	* \brief 
	* Signal used to get the RGB value from the video memory.
	* 
	***************************************************************************************************************/
	wire[DATA_WIDTH-1:0]  redColor;
	wire[DATA_WIDTH-1:0]  greenColor;
	wire[DATA_WIDTH-1:0]  blueColor;
		
	/*************************************************************************************************************
	* \brief 
	* Signal used to get the RGB value from the video memory.
	* 
	***************************************************************************************************************/
	genvar idx;
	
	generate
	
		for(idx = 0; idx < DATA_WIDTH; idx = idx + 1)begin: wAs
			
			assign blueColor[idx] = (videoMemIn[idx] == 1'd1) ? frontColor[2] : backColor[2];
			assign greenColor[idx] = (videoMemIn[idx] == 1'd1) ? frontColor[1] : backColor[1];
			assign redColor[idx] = (videoMemIn[idx] == 1'd1) ? frontColor[0] : backColor[0];
			
		end
	
	endgenerate
	 
	/*************************************************************************************************************************
	* \brief 
	* Combinational logic.
	* The "lastData" is set to one indicating the last video data transmission.
	* The "done" signal is asserted when video transmission to the display is done.
	* The "addrVideoMem" signal is used for addressing the video memory. 
	**************************************************************************************************************************/		 											
	assign lastData = (addrMemCnt == VIDEO_ADDR_MAX-1) ;
	assign done = lastData && currStFrame == READ_MEM;
	assign addrVideoMem = addrMemCnt;
	
	/*************************************************************************************************************
	* \brief 
	* The "videoTxStart" signal is asserted when video data transmission to the display is in progress.
	* 
	***************************************************************************************************************/
	assign videoTxStart = (startIP & (command == ILI9327_WR_MEMORY_START || command == ILI9327_WR_MEMORY_CONTINUE) & ~busy);
	
	/*************************************************************************************************************
	* \brief 
	* FSM code used to transmit video data to the display.
	* 
	***************************************************************************************************************/
	always @(posedge clk, negedge reset) begin
		if(~reset) 
			currStFrame <= WAIT_FOR_VIDEO;     //FSM Current state.
		else
			currStFrame <= nextStFrame;    //FSM Next state.
	end
	
	always @* begin
		nextStFrame = currStFrame;
		case (currStFrame)
			WAIT_FOR_VIDEO:								//Wait for command to transmit video data to the display.
				if (videoTxStart) 
					nextStFrame = TX_WR_MEM_CMD;
			TX_WR_MEM_CMD:									//Transmit command to the display indicating video data transmission start.
				if (ready) 
					nextStFrame = TX_SEND_BYTE_1;
			TX_SEND_BYTE_1:								//Transmit blue color data got from bit[7:0] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_2;
			TX_SEND_BYTE_2:								//Transmit green color data got from bit[10:5] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_3;
			TX_SEND_BYTE_3:								//Transmit red color data got from bit[15:11] of video memory. 
				if (ready)
					nextStFrame = TX_SEND_BYTE_4;
			TX_SEND_BYTE_4:								//Transmit blue color data got from bit[20:16] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_5;	
			TX_SEND_BYTE_5:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_6;
			TX_SEND_BYTE_6:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_7;
			TX_SEND_BYTE_7:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_8;		
			TX_SEND_BYTE_8:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_9;
			TX_SEND_BYTE_9:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_10;
			TX_SEND_BYTE_10:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_11;
			TX_SEND_BYTE_11:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_12;
			TX_SEND_BYTE_12:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_13;
			TX_SEND_BYTE_13:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_14;
			TX_SEND_BYTE_14:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_15;
			TX_SEND_BYTE_15:								//Transmit green color data got from bit[26:21] of video memory.
				if (ready)
					nextStFrame = TX_SEND_BYTE_16;		
			TX_SEND_BYTE_16:								//Transmit blue color data got from bit[20:16] of video memory.
				if (ready)
					nextStFrame = READ_MEM;
			READ_MEM:										//Read next video data from video memory, if any.
				if (done)
					nextStFrame = WAIT_FOR_VIDEO;	
				else nextStFrame = TX_SEND_BYTE_1;
			default:
					nextStFrame = WAIT_FOR_VIDEO;
		endcase
	end
	

	/*************************************************************************************************************
	* \brief 
	* The "addrMemCnt" counter contains the address to read from the video memory.
	* 
	***************************************************************************************************************/
	always @(posedge clk) begin		
		if (nextStFrame == WAIT_FOR_VIDEO) 
			addrMemCnt <= RESET;
		else if (currStFrame == READ_MEM) 
			addrMemCnt <= addrMemCnt + 1'b1;
	end
	
	/***************************************************************************************************************************************
	* \brief 
	* The "dataToTx" register contains the video data to be trasmitted to the display.
	****************************************************************************************************************************************/
	always @* begin												
		if (currStFrame == TX_WR_MEM_CMD)						//Data to be transmitted to the display is video.
			//dataToTx = {CMD,ILI9327_WR_MEMORY_START };
			dataToTx = {CMD,command };
		else if (currStFrame == TX_SEND_BYTE_1)			
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[0], greenColor[0], blueColor[0], 
														  redColor[1], greenColor[1], blueColor[1] };
		else if (currStFrame == TX_SEND_BYTE_2)						
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[2], greenColor[2], blueColor[2], 
														  redColor[3], greenColor[3], blueColor[3] };
		else if (currStFrame == TX_SEND_BYTE_3)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[4], greenColor[4], blueColor[4], 
														  redColor[5], greenColor[5], blueColor[5] };
		else if (currStFrame == TX_SEND_BYTE_4)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[6], greenColor[6], blueColor[6], 
														  redColor[7], greenColor[7], blueColor[7] };
		else if (currStFrame == TX_SEND_BYTE_5)						
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[8], greenColor[8], blueColor[8], 
														  redColor[9], greenColor[9], blueColor[9] };
		else if (currStFrame == TX_SEND_BYTE_6)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[10], greenColor[10], blueColor[10], 
														  redColor[11], greenColor[11], blueColor[11] };
		else if (currStFrame == TX_SEND_BYTE_7)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[12], greenColor[12], blueColor[12], 
														  redColor[13], greenColor[13], blueColor[13] };
		else if (currStFrame == TX_SEND_BYTE_8)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[14], greenColor[14], blueColor[14], 
														  redColor[15], greenColor[15], blueColor[15] };
		else if (currStFrame == TX_SEND_BYTE_9)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[16], greenColor[16], blueColor[16], 
														  redColor[17], greenColor[17], blueColor[17] };
		else if (currStFrame == TX_SEND_BYTE_10)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[18], greenColor[18], blueColor[18], 
														  redColor[19], greenColor[19], blueColor[19] };
		else if (currStFrame == TX_SEND_BYTE_11)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[20], greenColor[20], blueColor[20], 
														  redColor[21], greenColor[21], blueColor[21] };
		else if (currStFrame == TX_SEND_BYTE_12)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[22], greenColor[22], blueColor[22], 
														  redColor[23], greenColor[23], blueColor[23] };
		else if (currStFrame == TX_SEND_BYTE_13)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[24], greenColor[24], blueColor[24], 
														  redColor[25], greenColor[25], blueColor[25] };
		else if (currStFrame == TX_SEND_BYTE_14)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[26], greenColor[26], blueColor[26], 
														  redColor[27], greenColor[27], blueColor[27] };
		else if (currStFrame == TX_SEND_BYTE_15)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[28], greenColor[28], blueColor[28], 
														  redColor[29], greenColor[29], blueColor[29] };
		else if (currStFrame == TX_SEND_BYTE_16)							
			dataToTx = {DAT, FIX_TO_ZERO[1:0], redColor[30], greenColor[30], blueColor[30], 
														  redColor[31], greenColor[31], blueColor[31] };												  
		else dataToTx = FIX_TO_FF;
	end
	
endmodule