`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: vtf_led_test
//////////////////////////////////////////////////////////////////////////////////

module vtf_uart_rx;
	// Inputs
	reg sys_clk;
	reg rst_n;
	reg rx_pin;
	reg rx_data_ready;

	// Outputs
    wire [7:0] rx_data;
    wire rx_data_valid;

	// Instantiate the Unit Under Test (UUT)
    uart_rx uut (
        .clk                        (sys_clk                  ),
        .rst_n                      (rst_n                    ),
        .rx_data                    (rx_data                  ),
        .rx_data_valid              (rx_data_valid            ),
        .rx_data_ready              (rx_data_ready            ),
        .rx_pin                     (uart_rx                  )
    );

	initial begin
		// Initialize Inputs
		sys_clk = 0;
		rst_n = 0;

		// Wait 1000 ns for global reset to finish
		#1000;
          rst_n = 1;        
		// Add stimulus here
		#20000;
      //  $stop;
	 end
   
    always #10 sys_clk = ~ sys_clk;   //20ns一个周期，产生50MHz时钟源
   
    parameter                        BPS_115200 = 50;//Mhz
    parameter                        SEND_DATA = 8'b1010_0011;//      
    
    integer i;
       
      initial begin
       rx_data_ready = 1'b1;
     
        rx_pin = 1'b1;    //bus idle
        #1000 rx_pin = 1'b0;     //stranmit start bit
        
        for (i=0;i<8;i=i+1)
          #BPS_115200 rx_pin = SEND_DATA[i];     //stranmit data bit
      
        #BPS_115200 rx_pin = 1'b0;     //stranmit stop bit
        #BPS_115200 rx_pin = 1'b1;     //bus idle
        
       end   
   	  
   	      
endmodule

