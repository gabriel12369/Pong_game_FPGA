module top_uart_tx #(parameter CLKS_PER_BIT = 87)(
	input       clk_50, clk_10,
   input       i_Tx_DV,
   //input [7:0] i_Tx_Byte, 
   output      o_Tx_Active,
   output      o_Tx_Serial,
   output      o_Tx_Done,
	//Acelerometro
	inout SPI_SDI,
   inout SPI_SDO,
   output SPI_CSN,
   output SPI_CLK,
   input interrupt,
	//Debouncer
	input k1
);

//Entrada uart
wire [7:0] uart_in;

//Acelerometro
	
	
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;
   wire [15:0] data_x, data_y;
	wire [16:0] data_x2, data_y2;
	
	assign reset_n = k1;
	
	wire enable_debounced; 
	
	////////////////Debouncer
	PB_Debouncer debouncer (
    .clk(clk),
    .PB(k1),
    .PB_down(),
    .PB_up(),
    .PB_state(enable_debounced)
);

	
	////////////////Acelerometro
	
	PLL ip_inst (
   .inclk0 ( clk_10 ),
   .c0 ( clk ),                 // 25 MHz, phase   0 degrees
   .c1 ( spi_clk ),             //  2 MHz, phase   0 degrees
   .c2 ( spi_clk_out )          //  2 MHz, phase 270 degrees
   );
	

//===== Instantiation of the spi_control module which provides the logic to 
//      interface to the accelerometer.
spi_control #(     // parameters
      .SPI_CLK_FREQ   (SPI_CLK_FREQ),
      .UPDATE_FREQ    (UPDATE_FREQ))
   spi_ctrl (      // port connections
      .reset_n    (reset_n),
      .clk        (clk),
      .spi_clk    (spi_clk),
      .spi_clk_out(spi_clk_out),
      .data_update(data_update),
      .data_x     (data_x),
      .data_y     (data_y),
      .SPI_SDI    (SPI_SDI),
      .SPI_SDO    (SPI_SDO),
      .SPI_CSN    (SPI_CSN ),
      .SPI_CLK    (SPI_CLK),
      .interrupt  (interrupt)
   );
	

wire clk_div;

CLK_Div CLK(
	.clk(clk_50),
   .rst(enable_debounced),
   .clk_div(clk_div)
);
	
MovingAverage movAvgX1 (
    .rst(reset_n),
    .clk(clk_div),
    .data_in(data_x),
    .promedio_out(data_x2)
);

MovingAverage movAvgY1 (
    .rst(reset_n),
    .clk(clk_div),
    .data_in(data_y),
    .promedio_out(data_y2)
);

///////////////////////////////
assign uart_in[0] = data_x2;
assign uart_in[1] = data_y2;

uart_tx u0(
.i_Clock(clk_10),
.i_Tx_DV(i_Tx_DV),
.i_Tx_Byte(uart_in),
.o_Tx_Active(o_Tx_Active),
.o_Tx_Done(o_Tx_Done),
.o_Tx_Serial(o_Tx_Serial)
);

endmodule 
