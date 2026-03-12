/*************************************************************************************************************
* \brief 
* Mario Munoz
* 15/06/2021
* Block used to set the config data in order the "TxControl" reads the data and
* send it to the ILI9327 chip driver.
* 
***************************************************************************************************************/

module ID00001008_TxConfig
#(parameter ONE_mS = 50000/* One miliseconds parameter, the value is equal to Clock Frequency/1000*/, 
  parameter CNT_1mS_WIDTH = 16 /*Milisecond counter width*/)
(	/*Global signals*/
	input reset,				// Global reset signal
	input clk,					// Global clock signal
	
	/*IPDI interface signals*/
	input startIP,				// Asserted to start IP Core.
	input [7:0] ctrlReg,		// Control register.
	output done,				// Asserted when config data transmission is done.
	
	/*Control signals*/
	input ready,				// Indicates the data/command transmission is done.
	input busy,					// Asserted when the IP core is busy executing a task.
	output cfgTxStart, 			// Asserted when configuration of the display starts.
	output txInProg,    		// Asserted when data transmission to the display is in progress.
	output nRST,         		// ILI9327 controller reset signal
	output [8:0]dataToTx		// Contains the command/parameter to transmit
	
);
	/*****************************************************************************************
	* \brief 
	* Misscellaneous parameters. 
	*
	*******************************************************************************************/
	localparam CMD = 1'b0;					// Indicates the data transmission is a command.
	localparam DAT = 1'b1;					// Indicates the data transmission is a localparam.
	localparam TOTAL_DATA = 56;				// Indicates the total 9-bit data transmitted to the display
	//parameter TOTAL_DATA = 1;
	/*****************************************************************************************
	* \brief 
	* Inckude files. 
	*
	*******************************************************************************************/
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

	//`include "ILI9327_config.v"
			
		//VCOM Control
	localparam SELVCM = 8'h00;			// Register D1h for VCM setting 
	localparam VCM = 7'h58;				// Factor to generate VCOMH voltage from the reference voltage VREG1OUT
	localparam VDV = 5'h15;				// Sets the VCOM alternating amplitude in the range of VREG1OUT x 0.70 to VREG1OUT x 1.32
	
		//Power Setting
	localparam VC = 3'h7; 				// Sets the ratio factor of Vci to generate the reference voltages Vci1
	localparam BT = 3'h1;				// Sets the Step up factor and output voltage level from the reference voltages Vci1
	localparam VCIRE = 1'b0;				// Selects the external reference voltage VciLVL or internal reference voltage VCIR
	localparam VRH = 5'h04;				// Sets the factor to generate VREG1OUT from VCI
	
		//Address mode
	localparam ADDR_MODE = 8'h60;		//8'd20// This command defines read/write scanning direction of frame memory
	
		//Pixel format
	localparam PIXEL_FORMAT = 8'h11;		//  Sets the pixel format for the RGB image data used by the interface
		
		// Display Timing
	localparam BC0 = 1'b1;				// BC0 is used to select VDV liquid crystal drive waveform
	localparam DIV0 = 2'h0;  			// DIV0[1:0] is used to set division ratio of internal clock frequency
	localparam RTN0 = 5'h10;				// RTN0[4:0] is used to set 1H (line) period 
	localparam BP0 = 8'h02;				// BP0[7:0] is used to set the number of lines for a back porch period (a blank period made before the beginning of display). 
	localparam FP0 = 8'h02;				// FP0[7:0] is used to set the number of lines for a front porch period (a blank period following the end of display). 
	
		 // Panel Driving Setting (C0h)
	localparam REV = 1'b0;				// REV: Enables the grayscale inversion of the image by setting REV=1. 
	localparam SM = 1'b0;				// SM: Sets the gate driver pin arrangement in combination with the GS bit to select the optimal scan mode for the module
	localparam GS = 1'b0;				// GS: Sets the gate driver pin arrangement in combination with the SM bit to select the optimal scan mode for the module
	localparam BGR = 1'b0;				// The bit is used to reverse 18-bit write data in the Frame Memory from RGB to BGR. Set in accordance with arrangement of color filters.
	localparam SS = 1'b0;				// The bit is used to select the shifting direction of the source driver output
	localparam NL = 6'h35;				// NL[5:0]: Sets the number of lines to drive the LCD at an interval of 8 lines. The GRAM address mapping is not affected by the number of lines set by NL[5:0]. The number of lines must be the same or more than the number of lines necessary for the size of the liquid crystal panel. 
	localparam SCN = 7'h00;				// SCN[6:0]: Specifies the gate line where the gate driver starts scan
	localparam PTS = 2'b00;				// Set the source output level in non-display area drive period (front/back porch period and blank area between partial displays). 
	localparam PTG = 1'b0;				// PTG: Sets the scan mode in non-display area. Select frame-inversion when interval-scan is selected
	localparam ISC = 4'h0;				// ISC[3:0]: Set the scan cycle when PTG selects interval scan in non-display area drive period. The scan cycle is defined by n frame periods, where n is an odd number from 3 to 31. The polarity of liquid crystal drive voltage from the gate driver is inverted in the same timing as the interval scan cycle. 
	localparam DIVE = 2'h0;				// DIVE[1:0] is used to set division ratio of PCLK clock frequency when the DPI interface is selected. The divided PCLK will be used as internal clock for the source driver pre-charge, VDV equalizing, etc. 
	
		// Frame Rate Control (C5h)
	localparam FRA = 3'h2;				// Set the frame frequency of display. 
	
	localparam AP0 = 3'h1;				// AP0[2:0] bit is used to adjust the constant current in the operational amplifier circuit in the LCD power supply circuit. 
	localparam DC10 = 3'h3;				// DC00/DC10 are used to select the charge-pump frequency of circuit and circuit2
	localparam DC00 = 3'h3;
	
		// Gamma Setting (C8h)
	localparam KP1 = 3'h0;				// KP5-0[2:0]: γ fine adjustment register for positive polarity
	localparam KP0 = 3'h2;
	localparam KP3 = 3'h7;
	localparam KP2 = 3'h7;
	localparam KP5 = 3'h4;				
	localparam KP4 = 3'h7;
	localparam RP1 = 3'h0;				// RP1-0[2:0 : γ gradient adjustment register for positive polarity
	localparam RP0 = 3'h1;				
	localparam VRP0 = 4'h9;				// VRP1-0[4:0]: γ amplitude adjustment register for positive polarity
	localparam VRP1 = 5'h00;				
	localparam KN1 = 3'h0;				// KN5-0[2:0]: γ fine adjustment register for negative polarity 
	localparam KN0 = 3'h3;
	localparam KN3 = 3'h0;
	localparam KN2 = 3'h0;
	localparam KN5 = 3'h5;
	localparam KN4 = 3'h7;
	localparam RN1 = 3'h5;				// RN1-0[2:0] : γ gradient adjustment register for negative polarity 
	localparam RN0 = 3'h0;
	localparam VRN0 = 4'h0;				// VRN1-0[4:0] : γ amplitude adjustment register for negative polarity
	localparam VRN1 = 5'h10;
	localparam VREP1 = 4'h0;
	localparam VREP0 = 4'h8;
	localparam VREN0 = 4'h8;
	localparam VREP2 = 4'h0;
	localparam VREN2 = 4'h0;
	localparam VREN1 = 4'h0;
	
		// 3-Gamma Function Control (EAh)
	localparam GAM_EN = 1'b0;			// This bit is used to control the digital 3-gamma function
	
		// Set_column_address (2Ah)
	localparam SC1 = 8'h00;
	localparam SC2 = 8'h00;
	localparam EC1 = 8'h01;
	localparam EC2 = 8'h8F;
	
		// Set_page_address (2Bh)
	localparam SP1 = 8'h00;
	localparam SP2 = 8'h00;
	localparam EP1 = 8'h00;
	localparam EP2 = 8'hEF;
	
	
	
	/*************************************************************************************************************
	* \brief 
	* States used in FSM used to transmit config data to the display.
	* 
	***************************************************************************************************************/
	localparam WAIT_FOR_CONFIG 			= 0;
	localparam SET_RST1					= 1;
	localparam RST_DELAY1				= 2;
	localparam CLR_RST 					= 3;
	localparam RST_DELAY2                = 4;
	localparam SET_RST2 					= 5;
	localparam EXIT_SLEEP 				= 6;
	localparam WAIT_STATE1 				= 7;	
	localparam TX_SOME_COMMANDS			= 8;		
	localparam WAIT_STATE2			    = 9;
	localparam GAMMA3_FUNCTION_CONTROL	= 10;
	localparam GAMMA3_FUNCT_CONTROL_PAR1	= 11;	
	localparam CONFIG_END				= 12;
	
	/*****************************************************************************************
	* \brief 
	* Misscellaneous parameters. 
	*
	*******************************************************************************************/
	wire [7:0] command;	// Used to get the command.
	wire [8:0] configArray [0:58]; //Contains the configuration values for the display. 
	//wire [8:0] configArray [0:1]; //Contains the configuration values for the display. 
	
	/*****************************************************************************************
	* \brief 
	* Delay signals. 
	*
	*******************************************************************************************/
	wire delay1ms;		/*Asserted when the "msCnt" counter is equal to 1.*/ 
	wire delay10ms;		/*Asserted when the "msCnt" counter is equal to 10.*/ 
	wire delay25ms;		/*Asserted when the "msCnt" counter is equal to 25.*/ 
	wire delay120ms;    /*Asserted when the "msCnt" counter is equal to 120.*/
	
	/*****************************************************************************************
	* \brief 
	* Commands counter. 
	*******************************************************************************************/
	reg [5:0] commandCnt;
	wire txCommandEnd;
	
	/*****************************************************************************************
	* \brief 
	* Delay counters. 
	*******************************************************************************************/
	reg [CNT_1mS_WIDTH-1:0] cnt1ms; /*"cnt1ms" counter is reset every ms.*/ 
	reg [6:0] msCnt;			  /*Counter is incremented each milisecond.*/
	wire cnt1msEn;				  /*"cnt1msEn" is the "cnt1ms" counter enable.*/
	
	/*****************************************************************************************
	* \brief 
	* FSM next and current states. 
	*******************************************************************************************/
	reg [3:0] currState;		/*Current state.*/
	reg [3:0] nextState;        /*Next state.*/
    
    wire oneMsFlag;

	/*****************************************************************************************
	* \brief 
	* Configuration values for the display . 
	*******************************************************************************************/	
	assign configArray[0] = {CMD, ILI9327_EXIT_SLEEP}; 
	assign configArray[1] =	{CMD, ILI9327_VCOM_CONTROL};
	assign configArray[2] =	{DAT, SELVCM};
	assign configArray[3] =	{DAT, 1'b0, VCM};
	assign configArray[4] =	{DAT, 3'h0,VDV};
	assign configArray[5] =	{CMD, ILI9327_POWER_SETTING_NORMAL};
	assign configArray[6] =	{DAT, 5'h00,VC};
	assign configArray[7] =	{DAT, 5'h00,BT};
	assign configArray[8] =	{DAT, VCIRE,2'h0, VRH};
	assign configArray[9] =	{CMD,ILI9327_SET_ADDR_MODE};
	assign configArray[10] = {DAT, ADDR_MODE};
	assign configArray[11] = {CMD,ILI9327_SET_PIXEL_FORMAT};
	assign configArray[12] = {DAT, PIXEL_FORMAT};
	assign configArray[13] = {CMD,ILI9327_DISPLAY_TIMING};
	assign configArray[14] = {DAT, 3'h0, BC0, 2'h0, DIV0};
	assign configArray[15] = {DAT, 3'h0, RTN0};
	assign configArray[16] = {DAT, BP0};
	assign configArray[17] = {DAT, FP0};
	assign configArray[18] = {CMD,ILI9327_PANEL_DRIVE_SETTING};
	assign configArray[19] = {DAT, 3'h0, REV, SM, GS, BGR, SS};
	assign configArray[20] = {DAT, 2'h0, NL};
	assign configArray[21] = {DAT, 1'b0, SCN};
	assign configArray[22] = {DAT, 6'h00, PTS};
	assign configArray[23] = {DAT, 3'h0, PTG, ISC};
	assign configArray[24] = {DAT, 6'h00, DIVE};
	assign configArray[25] = {CMD,ILI9327_FRAME_RATE_CONTROL};
	assign configArray[26] = {DAT, 5'h00, FRA};
	assign configArray[27] = {CMD,ILI9327_POWER_SETTING_NORMAL};
	assign configArray[28] = {DAT, 5'h00, AP0};
	assign configArray[29] = {DAT, 1'b0, DC10, 1'b0, DC00};
	assign configArray[30] = {CMD,ILI9327_GAMMA_SETTING};
	assign configArray[31] = {DAT, 1'b0, KP1, 1'b0, KP0};
	assign configArray[32] = {DAT, 1'b0, KP3, 1'b0, KP2};
	assign configArray[33] = {DAT, 1'b0, KP5, 1'b0, KP4};
	assign configArray[34] = {DAT, 1'b0, RP1, 1'b0, RP0};
	assign configArray[35] = {DAT, 4'h0, VRP0};
	assign configArray[36] = {DAT, 3'h0, VRP1};
	assign configArray[37] = {DAT, 1'b0, KN1, 1'b0, KN0};
	assign configArray[38] = {DAT, 1'b0, KN3, 1'b0, KN2};
	assign configArray[39] = {DAT, 1'b0, KN5, 1'b0, KN4};
	assign configArray[40] = {DAT, 1'b0, RN1, 1'b0, RN0};
	assign configArray[41] = {DAT, 4'h0, VRN0};
	assign configArray[42] = {DAT, 3'h0, VRN1};
	assign configArray[43] = {DAT, VREP1, VREP0};
	assign configArray[44] = {DAT, VREN0, VREP2};
	assign configArray[45] = {DAT, VREN2, VREN1};
	assign configArray[46] = {CMD, ILI9327_SET_COL_ADDR};
	assign configArray[47] = {DAT, SC1};
	assign configArray[48] = {DAT, SC2};
	assign configArray[49] = {DAT, EC1};
	assign configArray[50] = {DAT, EC2};
	assign configArray[51] = {CMD, ILI9327_SET_PAGE_ADDR};
	assign configArray[52] = {DAT, SP1};
	assign configArray[53] = {DAT, SP2};
	assign configArray[54] = {DAT, EP1};
	assign configArray[55] = {DAT, EP2};
	assign configArray[56] = {CMD,ILI9327_DISPLAY_ON};
	assign configArray[57] = {CMD,ILI9327_3_GAMMA_FUNCTION_CONTROL};
	assign configArray[58] = {DAT, GAM_EN, 7'h00};
	
									
	/*****************************************************************************************
	* \brief 
	* Assigments. 
	*******************************************************************************************/					  
	assign oneMsFlag = (cnt1ms == ONE_mS);     
	assign cnt1msEn = (currState == SET_RST1) | (currState == CLR_RST) | (currState == SET_RST2) | (currState == WAIT_STATE1) | (currState == WAIT_STATE2);
	assign delay1ms = (msCnt == 1);
	assign delay10ms = (msCnt == 10);
	assign delay25ms = (msCnt == 25);
	assign delay120ms = (msCnt == 120);
	assign nRST = (currState != CLR_RST);
	assign done = (currState == CONFIG_END);
	assign command = ctrlReg[7:0];
	assign txCommandEnd = (commandCnt == TOTAL_DATA);
			
	/*************************************************************************************************************
	* \brief 
	* The "cnfTxInProg" signal is asserted when config data transmission to the display is in progress.
	*
	***************************************************************************************************************/																
	assign cfgTxStart = (startIP & (command == ILI9327_CONFIG_DISPLAY) & ~busy);				
	  
	/**************************************************************************************************************
	* \brief 
	* The corresponding value is assigned to the dataToTx according to the FSM current state
	* The "txInProg" signal is set to 1 if it necessary to transmit a command/data to the display controller.
	****************************************************************************************************************/	
	assign dataToTx = txInProg ? configArray[commandCnt] : 9'h1FF; 
	assign txInProg = (currState == EXIT_SLEEP || currState == TX_SOME_COMMANDS || currState == GAMMA3_FUNCTION_CONTROL || currState == GAMMA3_FUNCT_CONTROL_PAR1);
	
	/*******************************************************************************
	* \brief 
	* "commandCnt" counts the commands transmitted.  
	* 
	******************************************************************************/
	always @(posedge clk) begin
		if (!busy) 
			commandCnt <= 0;
		else if (ready) 
			commandCnt <=  commandCnt + 1'b1;
	end
	
	/*******************************************************************************
	* \brief 
	* "cnt1ms" counter is reset each milisecond.  
	* 
	******************************************************************************/
	always @(posedge clk, negedge reset) begin
		if (~reset) 
			cnt1ms <= 0; 
		else if (cnt1msEn) begin
			if (cnt1ms == ONE_mS) 
				cnt1ms <= 0;
			else 
				cnt1ms <= cnt1ms + 1'b1;
		end
	end
	
	/*****************************************************************************************
	* \brief 
	* "msCnt" counter is incremented each milisecond.
	* "cnt1msEn" enables the "msCnt" counter when it is set to 1.
	*******************************************************************************************/
	always @(posedge clk, negedge reset) begin
		if (~reset) 
			msCnt <= 0; 
		else if (!cnt1msEn) 
			msCnt <= 0; 
		else if (oneMsFlag) 
			msCnt <= msCnt + 1'b1;
	end	
	
	/*****************************************************************************************
	* \brief 
	* "nextState" state is assigned to "currState" state.
	* 
	*******************************************************************************************/
	always @(posedge clk, negedge reset) begin
		if (~reset) 
			currState <= WAIT_FOR_CONFIG; 
		else 
			currState <= nextState;
	end
		
	/*****************************************************************************************
	* \brief 
	* FSM used to config the display controller.
	* 
	*******************************************************************************************/
	always @* begin
		nextState = currState;
		case (currState)
			/*Starting state*/
			WAIT_FOR_CONFIG:
				if (cfgTxStart)
					nextState = SET_RST1;
			/*Display controller reset deasserting state*/
			SET_RST1:
				if (delay1ms) 
					nextState = RST_DELAY1;
			/*Delay counter reset state*/
			RST_DELAY1:
					nextState = CLR_RST;
			/*Display controller reset asserting state*/
			CLR_RST:
				if (delay10ms) 
					nextState = RST_DELAY2;
			/*Delay counter reset state*/
			RST_DELAY2:
					nextState = SET_RST2;
			/*Display controller reset deasserting state*/
			SET_RST2:
				if (delay120ms)
					nextState = EXIT_SLEEP;
			/*EXIT SLEEP command state*/
			EXIT_SLEEP:
				if (ready) 
					nextState = WAIT_STATE1;
			/*Waiting state*/
			WAIT_STATE1:		
				if (delay120ms)
					nextState = TX_SOME_COMMANDS;
			/*Command transmission*/
			TX_SOME_COMMANDS:												
				if (ready && txCommandEnd)
					nextState =  /*CONFIG_END;*/ WAIT_STATE2; 		
			WAIT_STATE2:
				if (delay25ms)
					nextState = GAMMA3_FUNCTION_CONTROL;
			/*GAMMA3 FUNCTION CONTROL command state*/		
			GAMMA3_FUNCTION_CONTROL:					//Enable 3 Gamma
				if (ready)
					nextState = GAMMA3_FUNCT_CONTROL_PAR1;
			/*GAMMA3 FUNCTION CONTROL parameter-1 state*/
			GAMMA3_FUNCT_CONTROL_PAR1:					
				if (ready)
					nextState = CONFIG_END;
			/*Config ended state*/
			CONFIG_END:
				nextState = WAIT_FOR_CONFIG;
			default:begin
				nextState = WAIT_FOR_CONFIG;
			end				
		endcase
	end
				
endmodule