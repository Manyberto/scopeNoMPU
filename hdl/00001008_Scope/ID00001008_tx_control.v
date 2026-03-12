/*************************************************************************************************************
* \brief 
* Mario Munoz
* 15/06/2021
* Block used to transmit command, parameter and video data to the ILI9327 chip driver.
* 
***************************************************************************************************************/

module ID00001008_TxCntrl
#(	
	parameter SCL_HIGH = 2,  		// Indicates the clock cycles the SCL clock is high.
	parameter SCL_LOW = 1, 			// Indicates the clock cycles the SCL clock is low.
	parameter SCL_CNT_BIT = 2,		// SCL counter width	
	parameter TX_CNT_BIT = 4,		// Transmit counter width 
	parameter [TX_CNT_BIT-1:0] TX_DATA_WIDTH = 9  	// Transmit data width
)
(	/*Global signals*/
	input reset,					// Global reset 
	input clk,						// Global clock 
	
	/*Data to transmit signals*/
	input [8:0]videoToTx,			// Video data to transmit to the display comming from the "TxVideo" block.
	input [8:0]cmdToTx,				// Command/parameter data to transmit to the display comming from the "TxCmd" block.
	input [8:0]configToTx,			// Config data to transmit to the display comming from the "TxConfig" block.
	
	/*Control signals*/
	input cfgTxStart,				// Indicates display configuration starts.
	input cmdTxStart,				// Indicates command/parameter transmission to the display starts.
	input videoTxStart,				// Indicates video data transmission to the display starts.
	input txInProgress,				// Indicates data config is been transmitted.
	input videoTxDone,				// Asserted when video data transmission is done.
	input cmdTxDone,				// Asserted when command/parameter data transmission is done.
	input cfgTxDone,				// Asserted when config data transmission is done.
	
	output reg ready,				// Indicates data (video, command or parameter) transmission is done.
	
	/*IPDI interface signals*/
	output reg done,				// Asserted when the IP core is ready to execute other task.
	output reg busy,				// Asserted when the IP core is busy executing a task.
	
	/*ILI9327 signals*/	
	output SDA,						// Serial data to the ILI9327 chip driver.
	output SCL,						// Clock to the ILI9327 chip driver.
	output nCS						// Chip select to the ILI9327 chip driver.
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
    localparam ILI93277_CONFIG_DISPLAY			= 8'hFF;

	/*************************************************************************************************
	* \brief 
	* Parameters for miscellaneous purposes. 
	* 
	*************************************************************************************************/
	localparam SCL_PULSE = SCL_HIGH + SCL_LOW;	// Used to generate the SCL clock pulse width.
	
	/*************************************************************************************************
	* \brief 
	* Registers used to implement counters. 
	* 
	*************************************************************************************************/
	reg [TX_CNT_BIT-1:0] cntTx;		// Counter used to get the next bit to transmit to the display.
	reg [SCL_CNT_BIT-1:0] cntScl;	// Counter used to generate the SCL clock to the display.
	
	/*************************************************************************************************
	* \brief 
	* Registers used for miscellaneous purpouses.
	* 
	*************************************************************************************************/
	reg serialTxReg;					// Serial data to/from the display.
	reg sclReg;							// Registered clock signal to the display.
	reg sclOld;							// Contains the delayed value of "sclReg" register.
	reg nCsReg;							// Registered chip select value for the display.
	reg cfgEnable;						// Asserted when cofiguration of the display is in progress.
	wire txDone;						// Set to 1 when data transmission to the display is done.	
	wire [8:0] dataToTx;				// Contains the data to transmit to the display.
	
	
	/*************************************************************************************************************************
	* \brief 
	* Display signals.
	* 
	**************************************************************************************************************************/	
	assign SDA = serialTxReg;		//Serial data to/from the display.
	assign SCL = sclReg;			//Clock signal to the display.
	assign nCS = nCsReg;			//Chip select signal to the display.
	assign dataToTx = videoToTx & cmdToTx  & configToTx;	// The "dataToTx" register contains the data to transmit to the display. 
	assign txDone = videoTxDone || cmdTxDone || cfgTxDone; 	// The "txDone" signal is set to 1 when data transmission to the display is done.
	
	always @(posedge clk) begin 	       
		if (txDone)
			done <= 1'b1;
		else done <= 1'b0; 
	end
	
	always @(posedge clk, negedge reset) begin 	
		if (~reset)                  
			busy <= 1'b0;           
		else if (cfgTxStart || cmdTxStart || videoTxStart)
			busy <= 1'b1;
		else if (txDone)
			busy <= 1'b0; 
	end
	
	always @(posedge clk, negedge reset) begin 
		if (~reset)
			cfgEnable <= 1'b0;
		else if(cfgTxStart)
			cfgEnable <= 1'b1;
		else if (txDone)
			cfgEnable <= 1'b0;
	end
	
	/*************************************************************************************************************
	* \brief 
	* The "ready" signal is asserted when 9-bit data (video or command) transmission is done.
	* 
	***************************************************************************************************************/
	always @(posedge clk)begin	
		if (cntTx == 0 && !sclReg && sclOld) 
			ready <= 1'b1;
		else 
			ready <= 1'b0;		
	end
	
	/*************************************************************************************************************
	* \brief 
	* The "cntTx" counter is decremented by 1 every time a data bit is transmitted to the display.
	* 
	***************************************************************************************************************/
	always @(posedge clk)begin
		if ((cntTx == 0 && sclReg && !sclOld) || (!busy) || (cfgEnable && !txInProgress)) 
			cntTx <= TX_DATA_WIDTH-1'b1;
		else if (sclReg && !sclOld)   //If SCL falling edge and transmission in progress
			cntTx <= cntTx - 1'b1;
	end
	                                         	
	always @(posedge clk) begin
		serialTxReg <= dataToTx[cntTx];
	end
      
	/***************************************************************************************************************************************
	* \brief 
	* The "cntScl" counter is used to generate the "SCL" clock to the display.
	* The "sclReg" signal contains the register value of the "SCL" clock signal.
	* The "sclOld" signal contains the delayed value of "sclReg" signal.
	****************************************************************************************************************************************/
	always @(posedge clk) begin
		if ((!busy) || (cntScl == SCL_PULSE-1)) 
			cntScl <= 0;
		else 
			cntScl <= cntScl + 1'b1;
	end
	
	always @(posedge clk) begin
		if (!busy || (cfgEnable && !txInProgress)) 
			sclReg <= 1'b1;
		else if (cntScl == 0) 
			sclReg <= 1'b0;
		else if (cntScl == SCL_LOW) 
			sclReg <= 1'b1;
			
		sclOld <= sclReg;
	end
	 
	/***************************************************************************************************************************************
	* \brief 
	* The "nCsReg" contains the register value of "nCS" chip select signal to the display.
	* 
	****************************************************************************************************************************************/
	always @(posedge clk, negedge reset) begin
		if (~reset) 
			nCsReg <= 1'b1;
		else if (txDone || (cfgEnable && !txInProgress)) 
			nCsReg <= 1'b1;
		else if (busy) 
			nCsReg <= 1'b0;
	end	
	
endmodule