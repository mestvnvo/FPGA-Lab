`timescale 1ns / 1ps

module set_alarm(input [5:0]sec, min, input CLK100MHZ, reset_ALRM, reset_CLK, alarm_SW,
a_inc_SW, output reg alarm_LED, output wire [5:0] a_sec, a_min, output reg weewoo, input wire alarmoff_BTN);
wire signal400,signal1;

slowerClkGen alarmclk(reset_CLK,a_inc_SW,CLK100MHZ,signal400,signal1);
timecounter alarmtime(reset_ALRM,signal1,a_inc_SW,a_sec,a_min);

always@*
begin
if(alarmoff_BTN)
    begin
    weewoo = 0; 
    end
if(alarm_SW)
    begin
    alarm_LED = 1;
    if(min==a_min && sec==a_sec)
        begin
        weewoo = 1;    
        end
    end
else
    begin
    alarm_LED = 0;
    end
end
endmodule

module alarm_clock(input reset_CLK, reset_CNT, reset_ALRM, inc_SW, a_inc_SW, alarm_SW, CLK100MHZ, alarmoff_BTN,
output [7:0] AN, output [7:0] CX, output wire audioOut, output wire aud_sd, output wire alarm_LED,output reg weewoo_LED);
wire signal400, signal1,weewoo;
wire [2:0] segcount;
wire [2:0] min_ten_count, sec_ten_count, a_min_ten_count, a_sec_ten_count;
wire [3:0] min_one_count, sec_one_count, a_min_one_count, a_sec_one_count;
wire [5:0] sec, min, a_sec, a_min;
wire [7:0] C0, C1, C2, C3, C4, C5, C6, C7;

reg [7:0] AN, CX;

assign E = 1;

slowerClkGen clocks(reset_CLK,inc_SW,CLK100MHZ,signal400,signal1);
segmentcounter loopsegment(reset_CLK,signal400,E,segcount);
timecounter digitaltime(reset_CNT,signal1,E,sec,min);
set_alarm alarm(sec,min,CLK100MHZ,reset_ALRM,reset_CLK,alarm_SW,a_inc_SW,alarm_LED,a_sec,a_min,weewoo,alarmoff_BTN);
digits alarm_separator(a_sec,a_min,a_min_ten_count,a_min_one_count,a_sec_ten_count,a_sec_one_count);
digits separator(sec,min,min_ten_count,min_one_count,sec_ten_count,sec_one_count);
SongPlayer alarm_sound(CLK100MHZ,alarmoff_BTN,weewoo,audioOut,aud_sd);

Pattern0_Gen clock0(sec_one_count,C0);
Pattern1_Gen clock1(sec_ten_count,C1);
Pattern2_Gen clock2(min_one_count,C2);
Pattern3_Gen clock3(min_ten_count,C3);
Pattern4_Gen alarm0(a_sec_one_count,C4);
Pattern5_Gen alarm1(a_sec_ten_count,C5);
Pattern6_Gen alarm2(a_min_one_count,C6);
Pattern7_Gen alarm3(a_min_ten_count,C7);
always@*
begin        
    if (weewoo)
        begin
        weewoo_LED=1;
        end
    else
        begin
        weewoo_LED=0;
        end
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
output reg [2:0] Q;

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

module Pattern4_Gen(sec_one_count,CX);
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

module Pattern5_Gen(sec_ten_count,CX);
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

module Pattern6_Gen(min_one_count,CX);
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

module Pattern7_Gen(min_ten_count,CX);
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

module MusicSheet( input [9:0] number,
output reg [19:0] note,//what is the max frequency
output reg [4:0] duration);
parameter QUARTER = 5'b00100;
parameter EIGHTH = 5'b00010;
parameter SIXTH = 5'b00001;
parameter WHOLE = 5'b10000;

parameter 
C4= 50_000_000/261.63,
C5 = 50_000_000/523.25,
Eb5 = 50_000_000/622.25, 
F5= 50_000_000/698.46, 
Gb5 = 50_000_000/739.99,
Bb5= 50_000_000/466.16, 
D5 = 50_000_000/587.33,
G4 = 50_000_000/392,
REST = 1;
always @ (number) begin
case(number) // Among Us (trap remix) - Leonz
    0: begin note = C4; duration = QUARTER; end // First Bar
    1: begin note = C5; duration = EIGHTH; end 
    2: begin note = Eb5; duration = EIGHTH; end 
    3: begin note = F5; duration = EIGHTH; end 
    4: begin note = Gb5; duration = EIGHTH; end 
    5: begin note = F5; duration = EIGHTH; end 
    6: begin note = Eb5; duration = EIGHTH; end
    
    7: begin note = C5; duration = QUARTER; end  // Second Bar 
    8: begin note = REST; duration = EIGHTH; end  
    9: begin note = Bb5; duration = SIXTH; end 
    10: begin note = D5; duration = SIXTH; end
    11: begin note = C5; duration = QUARTER; end 
    12: begin note = REST; duration = EIGHTH; end  
    13: begin note = G4; duration = EIGHTH; end 
    
    14: begin note = C4; duration = QUARTER; end // Third Bar
    15: begin note = C5; duration = EIGHTH; end 
    16: begin note = Eb5; duration = EIGHTH; end 
    17: begin note = F5; duration = EIGHTH; end 
    18: begin note = Gb5; duration = EIGHTH; end 
    19: begin note = F5; duration = EIGHTH; end 
    20: begin note = Eb5; duration = EIGHTH; end
    
    21: begin note = Gb5; duration = QUARTER; end // Fourth Bar
    22: begin note = REST; duration = QUARTER; end
    23: begin note = Gb5; duration = SIXTH; end 
    24: begin note = F5; duration = SIXTH; end 
    25: begin note = Eb5; duration = SIXTH; end
    26: begin note = REST; duration = SIXTH; end 
    27: begin note = Gb5; duration = SIXTH; end 
    28: begin note = F5; duration = SIXTH; end 
    29: begin note = Eb5; duration = SIXTH; end
    30: begin note = REST; duration = SIXTH; end 
    
    default: begin note = C5; duration = QUARTER; end
endcase
end
endmodule

module SongPlayer( input clock, input wire reset, input playSound, 
output reg audioOut, output wire aud_sd);
reg [19:0] counter;
reg [31:0] time1, noteTime;
reg [9:0] msec, number; //millisecond counter, and sequence number of musical note.
wire [4:0] note, duration;
wire [19:0] notePeriod;
parameter clockFrequency = 100_000_000;
assign aud_sd = 1'b1;
MusicSheet mysong(number, notePeriod, duration );
always @ (posedge clock)
begin
if(reset | ~playSound)
    begin
    counter <=0;
    time1<=0;
    number <=0;
    audioOut <=1;
    end
else
    begin
    counter <= counter + 1;
    time1<= time1+1;
    if( counter >= notePeriod)
        begin
        counter <=0;
        audioOut <= ~audioOut;
        end //toggle audio output
    if( time1 >= noteTime)
        begin
        time1 <=0;
        number <= number + 1;
        end //play next note
    if(number == 30) number <=0; // Make the number reset at the end of the song
    end
end
    always @(duration) noteTime = duration * clockFrequency/8;
//number of FPGA clock periods in one note.
endmodule