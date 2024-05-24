//Limits might get cut sometimes. If that happens click on Auto Adjust.

module top #(parameter CLKS_PER_BIT = 87)(
	input clk_50, clk_10, reset, button, button1, rx_serial,
	output [11:0] rgb,
	output hsync, vsync, rx_dv, 
	output [6:0] seg1, seg2,
	//output [3:0] red, green, blue
	//Acelerometro
	inout SPI_SDI,
   inout SPI_SDO,
   output SPI_CSN,
   output SPI_CLK,
   input interrupt,
	input k1
	);
	
	//Acelerometro
	
	
   localparam SPI_CLK_FREQ  = 200;  // SPI Clock (Hz)
   localparam UPDATE_FREQ   = 1;    // Sampling frequency (Hz)

   // clks and reset
   wire reset_n;
   wire clk, spi_clk, spi_clk_out;

   // output data
   wire data_update;
   wire [15:0] data_x, data_y;
	wire [16:0] data_x1, data_y1;
	
	assign reset_n = k1;

	
	//wire [11:0] rgb;
	
	wire [9:0] x,y;
	
	wire [7:0] rx_byte;
	
	wire video_on;
	wire clk_1ms;
	
	wire [11:0] rgb_paddle1, rgb_paddle2, rgb_ball;
	wire ball_on, paddle1_on, paddle2_on;
	wire [9:0] x_paddle1, x_paddle2, y_paddle1, y_paddle2;
	wire [3:0] p1_score, p2_score;
	wire [1:0] game_state;
	
	////////////////Debouncer
	wire enable_debounced; 
	
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
    .promedio_out(data_x1)
);

MovingAverage movAvgY1 (
    .rst(reset_n),
    .clk(clk_div),
    .data_in(data_y),
    .promedio_out(data_y1)
);

///////////////////////////////
	
	vga_sync v1	(.clk(clk_50), .hsync(hsync), .vsync(vsync), .x(x), .y(y), .video_on(video_on));
	
	//conversor_rgb c0(.rgb(rgb), .red(red), .green(green), .blue(blue));
	
	render r1	(.clk(clk_50), .reset(reset), .x(x), .y(y), .video_on(video_on), .rgb(rgb), .clk_1ms(clk_1ms),
					.paddle1_on(paddle1_on), .paddle2_on(paddle2_on), .ball_on(ball_on), 
					.rgb_paddle1(rgb_paddle1), .rgb_paddle2(rgb_paddle2), .rgb_ball(rgb_ball),
					.game_state(game_state));
				
	clock_divider c1 (.clk(clk_50), .clk_1ms(clk_1ms));
	
	uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) u0(.i_Clock(clk_10), .i_Rx_Serial(rx_serial), .o_Rx_DV(rx_dv), .o_Rx_Byte(rx_byte));
	
	ball b1 	(.clk(clk_50), .clk_1ms(clk_1ms), .reset(reset), .x(x), .y(y),  .ball_on(ball_on), .rgb_ball(rgb_ball),
				.x_paddle1(x_paddle1), .x_paddle2(x_paddle2), .y_paddle1(y_paddle1), .y_paddle2(y_paddle2),
				.p1_score(p1_score), .p2_score(p2_score), .game_state(game_state));
	
	paddle p1	(.clk_1ms(clk_1ms), .reset(reset), .x(x), .y(y),
					 .button(data_x1), .button1(data_y1),  .button2(rx_byte[1]), .button3(rx_byte[0]),
					.paddle1_on(paddle1_on), .rgb_paddle1(rgb_paddle1), .paddle2_on(paddle2_on), .rgb_paddle2(rgb_paddle2),
					.x_paddle1(x_paddle1), .x_paddle2(x_paddle2), .y_paddle1(y_paddle1), .y_paddle2(y_paddle2) );

	game_state(.clk(clk_50), .clk_1ms(clk_1ms), .reset(reset), .p1_score(p1_score), .p2_score(p2_score), .game_state(game_state));
	
	seven_seg (.clk(clk_50), .clk_1ms(clk_1ms), .reset(reset), .p1_score(p1_score), .p2_score(p2_score), .seg1(seg1), .seg2(seg2));
	
	
endmodule
