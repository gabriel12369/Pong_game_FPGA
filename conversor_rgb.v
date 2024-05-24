module conversor_rgb(
	input [11:0] rgb,
	output [3:0] red, green, blue
);

assign red = rgb[3:0]; //Extrayendo color rojo de rgb
assign green = rgb[7:4]; //Extrayendo color verde de rgb
assign blue = rgb[11:8]; //Extrayendo color azul de rgb

endmodule 