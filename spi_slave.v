module slave
#(parameter width=8, bit_width=width/2)
(
    input [width-1:0] data_in_slave,
    input cpha,
    input sclk,
    input mosi,
    output reg miso,
    output reg [width-1:0] data_out_slave,
    input cs_n
);

    parameter IDLE=0, DATA=1, STOP =2, WAIT =3;

    reg [1:0] state;
    reg [width-1:0] rx_data;      // to store from MOSI
    reg [bit_width:0] bit_pos;
    reg [width-1:0] store_slave;  // to transfer serially over MISO line

    initial begin 
        bit_pos = 0; 
        state = IDLE; 
        rx_data = 4'h0; 
        data_out_slave = 4'h0; 
        store_slave = 4'h0; 
        miso = 1'b0; 
    end

    // MISO Drive Logic
   always @(negedge sclk or negedge cs_n) begin

    if (!cs_n) begin

        // CPHA = 0
        if (!cpha) begin

            if (state == IDLE)
                miso <= data_in_slave[0];

             else if (state == DATA && bit_pos <= width-1)
                miso <= store_slave[bit_pos+1];

        end

        // CPHA = 1
        else if(cpha) begin

            if (state == WAIT)
                miso <= data_in_slave[0]; 

             else if (state == DATA && bit_pos <= width-1)
                miso <= store_slave[bit_pos +1];

        end

    end

    else begin
        miso <= 1'b0;
    end

end

    // MOSI Sample Logic & State Machine
    always @(posedge sclk) begin
        case(state) 
            IDLE: 
                if(!cs_n && !cpha) begin
                    rx_data <= 4'h0;
                    data_out_slave <= 4'h0;
                    store_slave <= data_in_slave; 
                    state <= DATA;
                end
		else if(!cs_n && cpha) begin
			store_slave<= data_in_slave;
			state<= WAIT;
			end

	    WAIT: 
		
		begin state<= DATA; end 

            DATA:
                if(bit_pos <= width-1) begin
                    rx_data[bit_pos] <= mosi;
                    bit_pos <= bit_pos + 1;    
                end
                else if(bit_pos > (width-1) || cs_n) begin 
                    state <= STOP; 
                    data_out_slave <= rx_data; 
                    bit_pos <= 0; 
                end

            STOP: 
                begin 
                    state <= IDLE; 
                    rx_data <= 4'h0; 
                end
        endcase
    end

endmodule
