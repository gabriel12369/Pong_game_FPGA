module top_wr(
	input ADC_CLK_10,
	input MAX10_CLK1_50,
	input [1:0] KEY,
	input [1:0] SW,
	input [9:0] ARDUINO_IO,
	output [1:0] LEDR,
	output [0:6] HEX0, HEX3,
	output VGA_HS, VGA_VS,
	output [11:0] rgb,
	
	//Acelerometro
	output		          		GSENSOR_CS_N,
   input 		     [2:1]		GSENSOR_INT,
   output		          		GSENSOR_SCLK,
   inout 		          		GSENSOR_SDI,
   inout 		          		GSENSOR_SDO
);

top WRAPPER(
.clk_50(MAX10_CLK1_50),
.clk_10(ADC_CLK_10),
.reset(KEY[0]),
.rx_serial(ARDUINO_IO[0]),
.rgb(rgb),
.hsync(VGA_HS), 
.vsync(VGA_VS), 
.rx_dv(LEDR[0]),
.seg1(HEX3), 
.seg2(HEX0),
.SPI_SDI    (GSENSOR_SDI),
.SPI_SDO    (GSENSOR_SDO),
.SPI_CSN    (GSENSOR_CS_N),
.SPI_CLK    (GSENSOR_SCLK),
.interrupt  (GSENSOR_INT),
.k1(KEY[1])
);

endmodule 