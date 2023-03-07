`timescale 1ns / 1ps

module digital_clock(input reset_CLK, input reset_CNT, input CLK100MHZ, input inc_SW, output [7:0] AN, output [7:0] CX);
wire signal400, signal1;
wire [1:0] segcount;
wire [2:0] min_ten_count, sec_ten_count;
wire [3:0] min_one_count, sec_one_count;
wire [5:0] sec, min;
wire [7:0] C0, C1, C2, C3;

reg [7:0] AN, CX;

assign E = 1;

slowerClkGen clocks(reset_CLK,inc_SW,CLK100MHZ,signal400,signal1);
segmentcounter loopsegment(reset_CNT,signal400,E,segcount);
timecounter digitaltime(reset_CNT,signal1,E,sec,min);
digits separator(sec,min,min_ten_count,min_one_count,sec_ten_count,sec_one_count);

Pattern0_Gen letter0(sec_one_count,C0);
Pattern1_Gen letter1(sec_ten_count,C1);
Pattern2_Gen letter2(min_one_count,C2);
Pattern3_Gen letter3(min_ten_count,C3);
always@*
begin        
    case(segcount)
        0:  begin
                AN = 8'hFE;
                CX = C0;
            end
        1:  begin
                AN = 8'hFD;
                CX = C1;
            end
        2:  begin
                AN = 8'hFB;
                CX = C2;
            end
        3:  begin
                AN = 8'hF7;
                CX = C3;
            end
    endcase
end
endmodule

module slowerClkGen(resetSW,inc, clk, out400Hz,out1Hz);
input clk;
input resetSW;
input inc;
reg [26:0] speed;

output reg out400Hz;
output reg out1Hz;
reg [26:0] counter400Hz;
reg [26:0] counter1Hz;
always @ (posedge clk)
begin
if (inc)
    speed = 1_000_000;
else
    speed = 50_000_000;
if (resetSW)
begin
    counter400Hz=0;
    counter1Hz=0;
    out400Hz=0;
    out1Hz=0;
end
else
begin
    counter1Hz = counter1Hz +1;
    counter400Hz = counter400Hz +1;
    if (counter1Hz == speed)
    begin
        out1Hz=~out1Hz;
        counter1Hz =0;
    end
    if (counter400Hz == 125_000)
    begin
        out400Hz=~out400Hz;
        counter400Hz =0;
    end
end
end
endmodule

module segmentcounter (Resetn, Clock, E, Q);
input Resetn, E;
input wire Clock;
output reg [1:0] Q;

always @(posedge Resetn, posedge Clock)
if (Resetn)
    Q <= 0;
else if (E)
    Q <= Q + 1;
endmodule

module timecounter (Resetn, Clock, E, sec, min);
input Resetn, E;
input wire Clock;
output reg [5:0] sec, min;

always @(posedge Resetn, posedge Clock)
if (Resetn)
begin
    sec <= 0;
    min <= 0;
end
else if (E)
begin
    if (sec > 58)
    begin
        sec <= 0;
        min <= min + 1;
    end
    else if (min > 59)
    begin
        sec <= 0;
        min <= 0;
    end
    else
        sec <= sec + 1;
end
endmodule

module digits(sec,min,mTens,mOnes,sTens,sOnes);
input [5:0] sec, min;
output reg [2:0] mTens, sTens;
output reg [3:0] mOnes, sOnes;

always@*
begin
    mTens <= min/10;
    sTens <= sec/10;
    
    mOnes <= min%10;
    sOnes <= sec%10;
end
endmodule

module Pattern0_Gen(sec_one_count,CX);
input wire [3:0] sec_one_count;
output reg [7:0] CX;
always@*
begin
    case(sec_one_count)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        default: CX = 8'hfF;
    endcase
end
endmodule 

module Pattern1_Gen(sec_ten_count,CX);
input wire [2:0] sec_ten_count;
output reg [7:0] CX;
always@*
begin
    case(sec_ten_count)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern2_Gen(min_one_count,CX);
input wire [3:0] min_one_count;
output reg [7:0] CX;
always@*
begin
    case(min_one_count)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        6: CX = 8'hA0;
        7: CX = 8'h8F;
        8: CX = 8'h80;
        9: CX = 8'h84;
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern3_Gen(min_ten_count,CX);
input wire [2:0] min_ten_count;
output reg [7:0] CX;
always@*
begin
    case(min_ten_count)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        5: CX = 8'hA4;
        default: CX = 8'hfF;
    endcase
end
endmodule
