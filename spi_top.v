module spi_top_module

#(parameter width=8, bit_width=width/2)
(

input clk,
input cpol,
input cpha,
input ready_n,
input [width-1:0] data_in, //master
input [width-1:0] data_in_slave,
output [width-1:0] data_out,// from master by slave
output [width-1:0] data_out_slave);



wire mosi;
wire miso;
wire sclk;
wire cs_n;


master m1(

.clk(clk),
.cpol(cpol),
.cpha(cpha),
.ready_n(ready_n),
.data_in(data_in),
.sclk(sclk),
.mosi(mosi),
.miso(miso),
.cs_n(cs_n),
.data_out(data_out)
);


slave s1(
.data_in_slave(data_in_slave),
.cpha(cpha),
.sclk(sclk),
.mosi(mosi),
.miso(miso),
.data_out_slave(data_out_slave),
.cs_n(cs_n)
);

endmodule



