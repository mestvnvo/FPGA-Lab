`timescale 1ns / 1ps

module pov_extra(input reset_CLK, input reset_CNT, input CLK100MHZ, output [7:0] AN, 
    output [7:0] CX);
    wire signal400, signal5;
    wire [2:0] lcount;
    wire [4:0] wcount;
    wire [7:0] C0, C1, C2, C3, C4, C5, C6, C7;
    
    reg [7:0] AN, CX;
    
    assign E = 1;
    
    slowerClkGen clocks(reset_CLK,CLK100MHZ,signal400,signal5);
    lettercounter loopletter(reset_CNT,signal400,E,lcount);
    wordcounter changeword(reset_CNT,signal5,E,wcount);
    
    Pattern0_Gen letter0(wcount,C0);
    Pattern1_Gen letter1(wcount,C1);
    Pattern2_Gen letter2(wcount,C2);
    Pattern3_Gen letter3(wcount,C3);
    Pattern4_Gen letter4(wcount,C4);
    Pattern5_Gen letter5(wcount,C5);
    Pattern6_Gen letter6(wcount,C6);
    Pattern7_Gen letter7(wcount,C7);
    always@*
    begin        
        case(lcount)
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
            4:  begin
                    AN = 8'hEF;
                    CX = C4;
                end
            5:  begin
                    AN = 8'hDF;
                    CX = C5;
                end
            6:  begin
                    AN = 8'hBF;
                    CX = C6;
                end
            7:  begin
                    AN = 8'h7F;
                    CX = C7;
                end
        endcase
    end
endmodule

module slowerClkGen(resetSW, clk, out400Hz,out5Hz);
input clk;
input resetSW;
output reg out400Hz;
output reg out5Hz;
reg [26:0] counter400Hz;
reg [26:0] counter5Hz;
always @ (posedge clk)
begin
    if (resetSW)
    begin
        counter400Hz=0;
        counter5Hz=0;
        out400Hz=0;
        out5Hz=0;
    end
    else
    begin
        counter5Hz = counter5Hz +1;
        counter400Hz = counter400Hz +1;
        if (counter5Hz == 10_000_000)
        begin
            out5Hz=~out5Hz;
            counter2sec =0;
        end
        if (counter400Hz == 125_000)
        begin
            out400Hz=~out400Hz;
            counter400Hz =0;
        end
    end
end
endmodule

module lettercounter (Resetn, Clock, E, Q);
input Resetn, E;
input wire Clock;
output reg [2:0] Q;

always @(posedge Resetn, posedge Clock)
if (Resetn)
    Q <= 0;
else if (E)
    Q <= Q + 1;
endmodule

module wordcounter (Resetn, Clock, E, Q);
input Resetn, E;
input wire Clock;
output reg [4:0] Q;

always @(posedge Resetn, posedge Clock)
if (Resetn)
    Q <= 0;
else if (E)
    Q <= Q + 1;
endmodule

module Pattern0_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        1: CX = 8'hA4; // S
        2: CX = 8'hF0; // T
        3: CX = 8'hB0; // E
        4: CX = 8'hC1; // V
        5: CX = 8'hB0; // E
        6: CX = 8'h89; // N
        
        8: CX = 8'hC1; // V
        9: CX = 8'hE2; // o

        11: CX = 8'hB8; // F
        12: CX = 8'h98; // P
        13: CX = 8'hA1; // G
        14: CX = 8'h88; // A
        
        16: CX = 8'hF1; // L
        17: CX = 8'h88; // A
        18: CX = 8'hE0; // B
        19: CX = 8'hA0; // 6
        default: CX = 8'hfF;
    endcase
end
endmodule
module Pattern1_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        2: CX = 8'hA4; // S
        3: CX = 8'hF0; // T
        4: CX = 8'hB0; // E
        5: CX = 8'hC1; // V
        6: CX = 8'hB0; // E
        7: CX = 8'h89; // N
        
        9: CX = 8'hC1; // V
        10: CX = 8'hE2; // o

        12: CX = 8'hB8; // F
        13: CX = 8'h98; // P
        14: CX = 8'hA1; // G
        15: CX = 8'h88; // A
        
        17: CX = 8'hF1; // L
        18: CX = 8'h88; // A
        19: CX = 8'hE0; // B
        20: CX = 8'hA0; // 6
        default: CX = 8'hfF;
    endcase
end
endmodule
module Pattern2_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        3: CX = 8'hA4; // S
        4: CX = 8'hF0; // T
        5: CX = 8'hB0; // E
        6: CX = 8'hC1; // V
        7: CX = 8'hB0; // E
        8: CX = 8'h89; // N
        
        10: CX = 8'hC1; // V
        11: CX = 8'hE2; // o

        13: CX = 8'hB8; // F
        14: CX = 8'h98; // P
        15: CX = 8'hA1; // G
        16: CX = 8'h88; // A
        
        18: CX = 8'hF1; // L
        19: CX = 8'h88; // A
        20: CX = 8'hE0; // B
        21: CX = 8'hA0; // 6
        default: CX = 8'hfF;
    endcase
end
endmodule
module Pattern3_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        4: CX = 8'hA4; // S
        5: CX = 8'hF0; // T
        6: CX = 8'hB0; // E
        7: CX = 8'hC1; // V
        8: CX = 8'hB0; // E
        9: CX = 8'h89; // N
        
        11: CX = 8'hC1; // V
        12: CX = 8'hE2; // o

        14: CX = 8'hB8; // F
        15: CX = 8'h98; // P
        16: CX = 8'hA1; // G
        17: CX = 8'h88; // A
        
        19: CX = 8'hF1; // L
        20: CX = 8'h88; // A
        21: CX = 8'hE0; // B
        22: CX = 8'hA0; // 6
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern4_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        5: CX = 8'hA4; // S
        6: CX = 8'hF0; // T
        7: CX = 8'hB0; // E
        8: CX = 8'hC1; // V
        9: CX = 8'hB0; // E
        10: CX = 8'h89; // N
        
        12: CX = 8'hC1; // V
        13: CX = 8'hE2; // o

        15: CX = 8'hB8; // F
        16: CX = 8'h98; // P
        17: CX = 8'hA1; // G
        18: CX = 8'h88; // A
        
        20: CX = 8'hF1; // L
        21: CX = 8'h88; // A
        22: CX = 8'hE0; // B
        23: CX = 8'hA0; // 6
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern5_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        6: CX = 8'hA4; // S
        7: CX = 8'hF0; // T
        8: CX = 8'hB0; // E
        9: CX = 8'hC1; // V
        10: CX = 8'hB0; // E
        11: CX = 8'h89; // N
        
        13: CX = 8'hC1; // V
        14: CX = 8'hE2; // o

        16: CX = 8'hB8; // F
        17: CX = 8'h98; // P
        18: CX = 8'hA1; // G
        19: CX = 8'h88; // A
        
        21: CX = 8'hF1; // L
        22: CX = 8'h88; // A
        23: CX = 8'hE0; // B
        24: CX = 8'hA0; // 6
        default: CX = 8'hFF;
    endcase
end
endmodule

module Pattern6_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        7: CX = 8'hA4; // S
        8: CX = 8'hF0; // T
        9: CX = 8'hB0; // E
        10: CX = 8'hC1; // V
        11: CX = 8'hB0; // E
        12: CX = 8'h89; // N
        
        14: CX = 8'hC1; // V
        15: CX = 8'hE2; // o

        17: CX = 8'hB8; // F
        18: CX = 8'h98; // P
        19: CX = 8'hA1; // G
        20: CX = 8'h88; // A
        
        22: CX = 8'hF1; // L
        23: CX = 8'h88; // A
        24: CX = 8'hE0; // B
        25: CX = 8'hA0; // 6
        default: CX = 8'hFF;
    endcase
end
endmodule

module Pattern7_Gen(wcount,CX);
input wire [4:0] wcount;
output reg [7:0] CX;
always@(wcount)
begin
    case(wcount)
        8: CX = 8'hA4; // S
        9: CX = 8'hF0; // T
        10: CX = 8'hB0; // E
        11: CX = 8'hC1; // V
        12: CX = 8'hB0; // E
        13: CX = 8'h89; // N
        
        15: CX = 8'hC1; // V
        16: CX = 8'hE2; // o

        18: CX = 8'hB8; // F
        19: CX = 8'h98; // P
        20: CX = 8'hA1; // G
        21: CX = 8'h88; // A
        
        23: CX = 8'hF1; // L
        24: CX = 8'h88; // A
        25: CX = 8'hE0; // B
        26: CX = 8'hA0; // 6
        default: CX = 8'hFF;
    endcase
end
endmodule