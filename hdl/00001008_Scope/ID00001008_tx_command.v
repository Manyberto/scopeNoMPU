/*************************************************************************************************************
* \brief 
* Mario Munoz
* 15/06/2021
* Block used to get the command to execute and the parameters of the command in order the "TxControl" reads 
* the data and send it to the ILI9327 chip driver.
* 
***************************************************************************************************************/

module ID00001008_TxCmd
#(parameter PARAM_MEM_WIDTH = 5)  	// Parameter memory width)
(	/*Global signals*/
	input reset,					// Global reset 
	input clk,						// Global clock 	
	
	/*IPDI interface signals*/
	input startIP,					// Asserted to start IP Core.
	input [15:0] ctrlReg,			// Control register.
	input [31:0] paramMemIn,		// Parameter memory data.
	
	output done,					// Asserted when command/parameter transmission is done.
	
	/*Control signals*/
	input ready,					// Indicates command or parameter data byte transmission is done.
	input busy, 					// Asserted when the IP core is busy executing a task.
	output reg [PARAM_MEM_WIDTH-1:0] addrParamMem,  // Address for the parameter memory.
	output cmdTxStart,				// Asserted when a command/parameter data transmission to the display is in progress.
	output reg [8:0] dataToTx		// Contains the command or parameter data to be trasmitted to the display.	
);
	
	/*The "LI9327_command_ID.v" file contains the ILI9327 command IDs*/
	//`include "ILI9327_command_ID.v"
	localparam ILI9327_ENTER_SLEEP               = 8'h10;
    localparam ILI9327_EXIT_SLEEP                = 8'h11;
    localparam ILI9327_DISPLAY_OFF               = 8'h28;
    localparam ILI9327_DISPLAY_ON                = 8'h29;
    localparam ILI9327_SET_COL_ADDR              = 8'h2A;
    localparam ILI9327_SET_PAGE_ADDR             = 8'h2B;
    localparam ILI9327_WR_MEMORY_START        	= 8'h2C;
    localparam ILI9327_SET_ADDR_MODE             = 8'h36;
    localparam ILI9327_SET_PIXEL_FORMAT          = 8'h3A;
    localparam ILI9327_WR_MEMORY_CONTINUE		= 8'h3C;
    localparam ILI9327_PANEL_DRIVE_SETTING       = 8'hC0;
    localparam ILI9327_DISPLAY_TIMING            = 8'hC1;
    localparam ILI9327_DISPLAY_TIMING_IDLE       = 8'hC3;
    localparam ILI9327_FRAME_RATE_CONTROL        = 8'hC5;
    localparam ILI9327_GAMMA_SETTING             = 8'hC8;
    localparam ILI9327_POWER_SETTING             = 8'hD0;
    localparam ILI9327_VCOM_CONTROL              = 8'hD1;
    localparam ILI9327_POWER_SETTING_NORMAL      = 8'hD2;
    localparam ILI9327_3_GAMMA_FUNCTION_CONTROL  = 8'hEA;
    localparam ILI9327_CONFIG_DISPLAY			= 8'hFF;

	
	/*************************************************************************************************************
	* \brief 
	* States used in FSM used to transmit command data to the display.
	* 
	***************************************************************************************************************/
	localparam WAIT_COMMAND			= 0;									
	localparam TX_COMMAND			= 1;
	localparam TX_PARAM_BYTE1		= 2;
	localparam TX_PARAM_BYTE2		= 3;
	localparam TX_PARAM_BYTE3		= 4;
	localparam TX_PARAM_BYTE4		= 5;
	localparam PARAM_ADDR_INC		= 6;	
	localparam END_TX_PARAMETER		= 7;	
	
	/*************************************************************************************************
	* \brief 
	* Parameters for miscellaneous purposes. 
	* 
	*************************************************************************************************/
	localparam CMD = 1'b0;						// It is the Bit-8 of data when command is transmitted to the display.
	localparam DAT = 1'b1;						// It is the Bit-8 of data when video or parameter is transmitted to the display.
	localparam [6:0] RESET = 0;						// Used when a signal is reset.
	localparam [8:0] FIX_TO_FF = 9'h1FF;			// Used when a signal is set to 0xFF.	
	
	/**************************************************************************************************************
	* \brief 
	* Signals used to get the parameter values (from the parameter memory) to transmit to the display according. 
	* the command previously transmitted.
	***************************************************************************************************************/
	wire [7:0] paramByte1;
	wire [7:0] paramByte2;
	wire [7:0] paramByte3;
	wire [7:0] paramByte4;
	
	/**************************************************************************************************************
	* \brief 
	* Signals used to get the control register values. 
	* 
	***************************************************************************************************************/
	wire [7:0] totalParam;
	wire [7:0] command;
	
	/*************************************************************************************************
	* \brief 
	* Registers used to store the current and next state of FSMs. 
	* 
	*************************************************************************************************/
	reg [3:0] currStCmd;
	reg [3:0] nextStCmd;
	
	/*************************************************************************************************
	* \brief 
	* Registers used to implement counters. 
	* 
	*************************************************************************************************/
	reg [6:0] parameterCnt;			// Counter used to count the parameter transmitted to the display.
	
	/*************************************************************************************************
	* \brief 
	* Signals used for miscellaneous purpouses.
	* 
	*************************************************************************************************/
	wire txParamDone;					// Asserted when parameter transmission is done.
	
	/**************************************************************************************************************
	* \brief 
	* Signals used to get the parameter values (from the parameter memory) to transmit to the display according. 
	* the command previously transmitted.
	***************************************************************************************************************/
	assign paramByte1 = paramMemIn[7:0];
	assign paramByte2 = paramMemIn[15:8];
	assign paramByte3 = paramMemIn[23:16];
	assign paramByte4 = paramMemIn[31:24];
	
	/**************************************************************************************************************
	* \brief 
	* Signals used to get the control register values. 
	* 
	***************************************************************************************************************/
	assign totalParam = ctrlReg[15:8];
	assign command = ctrlReg[7:0];
	
	/*************************************************************************************************************************
	* \brief 
	* Combinational logic.
	*
	**************************************************************************************************************************/	
	assign done = (currStCmd == END_TX_PARAMETER);		// Asserted when command and parameters transmission is done.
	assign txParamDone = (parameterCnt == totalParam) & ready;		// Asseretd when parameter transmission is done.
	
	/*************************************************************************************************************
	* \brief 
	* The "cmdTxStart" signal is asserted when command data transmission to the display is in progress.
	*
	***************************************************************************************************************/																
	assign cmdTxStart = (startIP & ~(command == ILI9327_WR_MEMORY_START) & ~(command == ILI9327_WR_MEMORY_CONTINUE) & ~(command == ILI9327_CONFIG_DISPLAY) & ~busy);
	
	/*************************************************************************************************************
	* \brief 
	* The "addrParamMem" counter is used for addressing for the parameter memory.
	* 
	***************************************************************************************************************/
	always @(posedge clk) begin	
		if (currStCmd == WAIT_COMMAND)
			addrParamMem <= 0;
		else if (currStCmd == PARAM_ADDR_INC)
			addrParamMem <= addrParamMem + 1'b1;
	end	
	
	/*************************************************************************************************************
	* \brief 
	* The "parameterCnt" counter counts the parameters already transmitted to the display.
	*
	***************************************************************************************************************/
	always @(posedge clk) begin
		if (currStCmd == WAIT_COMMAND) 			
			parameterCnt <= RESET;
		else if (ready) begin
			if (parameterCnt == totalParam) 
				parameterCnt <= RESET;
			else 
				parameterCnt <= parameterCnt + 1'b1;
		end
	end
	
	
	/*************************************************************************************************************
	* \brief 
	* FSM code used to transmit control (writing) or status (reading) command to the display.
	* 
	***************************************************************************************************************/
	always @(posedge clk, negedge reset) begin
		if(~reset) 
			currStCmd <= WAIT_COMMAND;					//FSM Current state.
		else                                            
			currStCmd <= nextStCmd;                     //FSM Next state.
	end
	
	always @* begin
		nextStCmd = currStCmd;
		case (currStCmd)
			WAIT_COMMAND:								//Wait for command ready to transmit to the display.
				if (cmdTxStart)
					nextStCmd = TX_COMMAND;
			TX_COMMAND:									//Transmit command to the display.	
				if (txParamDone) 
					nextStCmd = END_TX_PARAMETER;
				else if (ready) 
					nextStCmd = TX_PARAM_BYTE1;
			TX_PARAM_BYTE1:								//Transmit parameter to the display.
				if (txParamDone) 
					nextStCmd = END_TX_PARAMETER;
				else if (ready) 
					nextStCmd = TX_PARAM_BYTE2;
			TX_PARAM_BYTE2:								//Transmit parameter to the display.
				if (txParamDone) 
					nextStCmd = END_TX_PARAMETER;
				else if (ready) 
					nextStCmd = TX_PARAM_BYTE3;
			TX_PARAM_BYTE3:								//Transmit parameter to the display.
				if (txParamDone) 
					nextStCmd = END_TX_PARAMETER;
				else if (ready) 
					nextStCmd = TX_PARAM_BYTE4;
			TX_PARAM_BYTE4:								//Transmit parameter to the display.
				if (txParamDone)
					nextStCmd = END_TX_PARAMETER;
				else if (ready) 
					nextStCmd = PARAM_ADDR_INC;
			PARAM_ADDR_INC:								//Transmit parameter to the display.
				nextStCmd = TX_PARAM_BYTE1;
			END_TX_PARAMETER: 							//Parameter transmission to the display is done.
				nextStCmd = WAIT_COMMAND;
			default:
				nextStCmd = WAIT_COMMAND;	
		endcase
	end
	
	/***************************************************************************************************************************************
	* \brief 
	* The "dataToTx" register contains the command or parameter data to be trasmitted to the display.
	****************************************************************************************************************************************/
	always @* begin
		if (currStCmd == TX_COMMAND)											//Data to be transmitted to the display is a command (video, control or status).
			dataToTx = {CMD,command};
		else if (currStCmd == TX_PARAM_BYTE1)									//Data to be transmitted to the display is a parameter byte-1.
			dataToTx = {DAT,paramByte1};
		else if (currStCmd == TX_PARAM_BYTE2)									//Data to be transmitted to the display is a parameter byte-2.
			dataToTx = {DAT,paramByte2};
		else if (currStCmd == TX_PARAM_BYTE3)									//Data to be transmitted to the display is a parameter byte-3.
			dataToTx = {DAT,paramByte3};
		else if (currStCmd == TX_PARAM_BYTE4)									//Data to be transmitted to the display is a parameter byte-4.
			dataToTx = {DAT,paramByte4};					
		else dataToTx = FIX_TO_FF;
	end
	
endmodule