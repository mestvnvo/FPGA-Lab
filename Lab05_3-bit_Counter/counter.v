`timescale 1ns / 1ps

module counter(input reset_CLK, input reset_CNT, input CLK100MHZ, output [7:0] AN, output [7:0] CX, output signal, output [2:0] count);
    wire [7:0] z;
    assign E = 1;
    assign AN = 8'hFE;
    slowerClkGen stage0(reset_CLK,CLK100MHZ,signal);
    upcounter stage1(reset_CNT,signal,E,count);
    decoder stage2(count,z);
    Seven_Seg stage3(z,CX);
endmodule

module slowerClkGen(resetSW, clk, outsignal);
    input clk;
    input resetSW;
    output reg outsignal;
    reg [26:0] counter;
    always @ (posedge clk)
    begin
    if (resetSW)
    begin
        counter=0;
        outsignal=0;
    end
    else
    begin
        counter = counter +1;
        if (counter == 50_000_000)
        begin
            outsignal=~outsignal;
            counter =0;
        end
    end
end
endmodule

module upcounter (Resetn, Clock, E, Q);
    input Resetn, E;
    input wire Clock;
    output reg [2:0] Q;
    always @(posedge Resetn, posedge Clock)
    if (Resetn)
        Q <= 0;
    else if (E)
        Q <= Q + 1;
endmodule

module decoder (input wire [2:0] data,  output reg [7:0] y); 
always @(data)
begin
       y=0; 
       y[data]=1; 
end
endmodule

module Seven_Seg (input wire [7:0]z, output reg [7:0]CX);
always@*
begin
    case(z)
        8'b00000001: CX = 8'h81;
        8'b00000010: CX = 8'hCF;
        8'b00000100: CX = 8'h92;
        8'b00001000: CX = 8'h86;
        8'b00010000: CX = 8'hCC;
        8'b00100000: CX = 8'hA4;
        8'b01000000: CX = 8'hA0;
        8'b10000000: CX = 8'h8F;
        default: CX = 8'hFF;
    endcase            
end
endmodule
