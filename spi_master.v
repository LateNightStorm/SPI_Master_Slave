module master
#(parameter width=8, bit_width=width/2)

( input clk,
input cpol, 
input cpha,
input ready_n,
input [width-1:0] data_in,
output reg sclk,
output reg mosi,
input miso,
output reg cs_n,
output reg [width-1:0] data_out);

parameter IDLE=0, DATA=1, STOP=2, WAIT=3;

reg [width-1:0] store;
reg [2:0] count;
reg [bit_width:0] bit_pos;
reg [1:0] state;
reg complete;
reg [width-1:0]slave_data;

initial begin count= 3'h0; 
	bit_pos=0; 
	state= IDLE; 
	cs_n= 1'b1; 
	store= 4'h0; 
	sclk= 1'b0;
	complete=0; 
	slave_data=4'h0; 
	mosi= 1'b0;
	data_out= 4'h0;
end

always @(posedge clk ) begin

if(!ready_n || state == DATA ) begin 
  	if(count == 7) begin

			count <= 0; sclk<= !cpol; end

		else begin count<= count + 1'b1; sclk <= cpol; end
        end

end


always @(posedge sclk) begin

  case(state)
	IDLE: if(!ready_n && !complete && !cpha)begin 
		store <= data_in;
		state<= DATA;
		cs_n<= 1'b0;
	      end
	      else if(!ready_n && !complete && cpha) begin
		store <= data_in;
		state<= WAIT;
		cs_n<= 1'b0;
		end



	WAIT: begin
		
			state<= DATA;
	     end

	DATA: begin
		if(bit_pos <= width-1) begin
			mosi<= store[bit_pos];
			slave_data[bit_pos]<= miso;
			bit_pos <= bit_pos + 1'b1;
			end

		else if(bit_pos > width-1) begin 
				bit_pos<= 4'h0; 
				cs_n<= 1'b1; 
				data_out<=slave_data; 
				state <= STOP; end
	end
 
	STOP: 
		begin 
			state<= IDLE; 
			complete<= 1'b1; 
			slave_data<= 4'h0; 
			store<= 4'h0;
		end

endcase

end

endmodule
