`timescale 1ns / 1ps

module data_transmission(CLK100MHZ,R,load,serial_out,parity,two_sec,count);
input CLK100MHZ,load;
input [7:0] R;
output reg serial_out;
output parity,two_sec;
output [2:0] count;
wire [7:0] Q;

slowerClkGen one_sec_cycle(CLK100MHZ,two_sec);
pasr eight_bit_shift(R,load,two_sec,Q);
upCounter three_bit(load,two_sec,count);
oddParityGen odd(two_sec,load,Q[0],parity);
always@*
begin
    if(count==7) serial_out <= parity;
    else serial_out <= Q[0];
end
endmodule

module slowerClkGen(clk,out2sec);
input clk;
reg [26:0] count;
output reg out2sec;
reg [26:0] counter2sec;

always @ (posedge clk)
begin
    counter2sec = counter2sec +1;
    if (counter2sec == 100_000_000)
    begin
        out2sec=~out2sec;
        counter2sec =0;
    end
end
endmodule

module pasr (R,L,Clock,Q);
input [7:0] R;
input L,Clock;
output reg [7:0] Q;

always @(posedge Clock)
if (L) Q <= R;
else
begin
    Q[0] <= Q[1];
    Q[1] <= Q[2];
    Q[2] <= Q[3];
    Q[3] <= Q[4];
    Q[4] <= Q[5];
    Q[5] <= Q[6];
    Q[6] <= Q[7];
//    Q[7] <= w; don't need to load w
end
endmodule

module oddParityGen(Clock,L,Q0,parity);
input Clock,L,Q0;
output reg parity;
reg [2:0] bit_count;

always@(posedge Clock)
begin
    if (L) 
    begin
        bit_count <= 0;
        parity <= 0;
    end
    else if (Q0 == 1) bit_count <= bit_count + 1;
    if (bit_count%2 == 0) parity <= 1;
    else parity <= 0;
end
endmodule

module upCounter(Resetn,Clock,Q);
input Resetn; // (Load)
input wire Clock;
output reg [2:0] Q;

always @(posedge Clock)
begin
    if (Resetn) Q <= 0;
    else Q <= Q + 1;
end
endmodule