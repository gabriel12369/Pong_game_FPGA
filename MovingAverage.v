module MovingAverage (
    input clk,
    input rst,
    input [15:0] data_in,
    output reg [15:0] promedio_out
);

parameter N = 32;  

reg [15:0] sum = 0;
reg [5:0] counter = 0;

always @(posedge clk or negedge rst) 
begin
    if (!rst) 
    begin
        sum <= 0;
        counter <= 0;
    end 
    else 
    begin
        // Si el bit más significativo (MSB) es 1, es un número negativo, asigna 0 a sum
        // Si el MSB es 0, es un número positivo, asigna 1 a sum
        sum <= sum + ((data_in[15] == 1) ? 0 : 1);
        if (counter == N-1)
        begin
            promedio_out <= sum >> $clog2(N);  
            sum <= 0;
        end
        counter <= counter + 1;
    end
end

endmodule
