module CLK_Div #(parameter Frecuencia = 2500)(
    input clk,
    input rst,
    output reg clk_div
);

localparam Frec_clk_interno = 50_000_000;

localparam ConstNumb = (2 * Frec_clk_interno)/Frecuencia;

reg [31:0] count;

always @(posedge clk or negedge rst)
begin
    if(rst == 1'b0)
        count <= 32'b0;
    else if(count == ConstNumb - 1)
        count <= 32'b0;
    else 
        count <= count + 1;
end

always @(posedge clk or negedge rst)
begin 
    if(rst == 1'b0)
        clk_div <= 1'b0;
    else if(count == ConstNumb - 1)
        clk_div <= ~clk_div;
end

endmodule 