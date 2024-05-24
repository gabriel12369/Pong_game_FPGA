module PB_Debouncer(
	input clk,
	input PB,
	output reg PB_state = 0,
	output PB_down, PB_up);

reg PB_sync_0;
reg PB_sync_1;

always @(posedge clk) PB_sync_0 <= PB;
always @(posedge clk) PB_sync_1 <= PB_sync_0;

reg [15:0] PB_count;

wire PB_idle = (PB_state == PB_sync_1);
wire PB_count_max = &PB_count;

always @(posedge clk)
	begin
		if(PB_idle)
			PB_count <= 0;
		else
		begin
			PB_count <= PB_count +16'd1;
			if(PB_count_max)
				PB_state <= ~PB_state;
		end
	end
assign PB_down = ~PB_idle & PB_count_max & ~PB_state;
assign PB_up = ~PB_idle & PB_count_max & PB_state;
	
endmodule 