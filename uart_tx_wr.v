module uart_tx_wr(
	input ADC_CLK_10,
	input MAX10_CLK1_50,
	input [1:0] KEY,
	//input [7:0] SW,
	output [1:0] LEDR,
	output [9:0] ARDUINO_IO,
	//Acelerometro
	output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO
);

top_uart_tx WRAPPER(
.clk_50(MAX10_CLK1_50),
.clk_10(ADC_CLK_10),
.i_Tx_DV(KEY[0]),
//.i_Tx_Byte(SW),
.o_Tx_Active(LEDR[0]),
.o_Tx_Done(LEDR[1]),
.o_Tx_Serial(ARDUINO_IO[1]),
.SPI_SDI    (GSENSOR_SDI),
.SPI_SDO    (GSENSOR_SDO),
.SPI_CSN    (GSENSOR_CS_N),
.SPI_CLK    (GSENSOR_SCLK),
.interrupt  (GSENSOR_INT),
.k1(KEY[1])
);

endmodule 