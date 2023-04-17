`timescale 1ns / 1ps

module fsmd_bit_counting(CLK100MHZ,reset,command,dataA,done,AN,CX,clock);
input CLK100MHZ, reset, command;
input [3:0] dataA;
reg [2:0] ones;
output reg done;
output wire clock;
reg [1:0] state_reg;
output reg [7:0] AN,CX;
localparam [1:0] s1=2'b01, s2=2'b10, s3=2'b11;
reg [1:0] state_next;
reg [3:0] registerA,registerA_next;
reg [7:0] ones_next;
reg done_next;
wire seg;
wire [3:0] segcount;
wire [7:0] C0,C2;
assign E=1;

slowerClkGen two_sec_cycle(CLK100MHZ,clock,seg);
segmentcounter loop_seg(seg,E,segcount);

Pattern0_Gen ones_count(ones,C0);
Pattern2_Gen state(state_reg,C2);

always @(posedge clock)
    if (reset)
    begin
        state_reg <= s1;
        ones<=0;
        registerA<=0;
        done=0;
    end
    else
    begin
        state_reg <= state_next;
        ones<=ones_next;
        registerA<=registerA_next;
        done<= done_next;
    end
always @*
begin
    state_next = state_reg;
    ones_next=ones;
    registerA_next=registerA;
    done_next=done;
    case (state_reg)
    s1:
    begin
        if (command==1)
        begin
            state_next=s2;
            done_next=0;
        end
        else
        begin
            registerA_next ={4'b0, dataA};
        end
    end
    s2:
    begin
        if (registerA==0)
        begin
            state_next=s3;
        end
        else
        begin
            if (registerA_next[0]==1'b1)
            begin
                ones_next<= ones + 1;
            end
            else //can be omitted
            begin
                ones_next = ones;
            end
        end
        registerA_next=registerA>>1;
    end   
    s3:
    begin
        done_next=1;
        if (command==0)
            state_next=s1;
    end
    default:
    begin
        state_next = s1;
        done_next=0;
    end
    endcase
end
always@*
begin
    case(segcount)
        0:  begin
                AN = 8'hFE;
                CX = C0; // One's count
            end
        1:  begin
                AN = 8'hFD;
                CX = 8'hB1; // C
            end
        2:  begin
                AN = 8'hFB;
                CX = C2; // State number
            end
        3:  begin
                AN = 8'hF7;
                CX = 8'hB0; // E
            end
        4:  begin
                AN = 8'hEF;
                CX = 8'hF0; // t
            end
        5:  begin
                AN = 8'hDF;
                CX = 8'h88; // A
            end
        6:  begin
                AN = 8'hBF;
                CX = 8'hF0; // t
            end
        7:  begin
                AN = 8'h7F;
                CX = 8'hA4; // S
            end
    endcase
end
endmodule

module slowerClkGen(clk,out2sec,out400Hz);
input clk;
reg [26:0] count;
output reg out2sec, out400Hz;
reg [26:0] counter2sec,counter400Hz;
always @ (posedge clk)
begin
    counter2sec = counter2sec +1;
    counter400Hz = counter400Hz +1;
    if (counter2sec == 100_000_000)
    begin
        out2sec=~out2sec;
        counter2sec =0;
    end
    if (counter400Hz == 125_000)
    begin
        out400Hz=~out400Hz;
        counter400Hz =0;
    end
end
endmodule

module segmentcounter (Clock, E, Q);
input E;
input wire Clock;
output reg [2:0] Q;

always @(posedge Clock)
if (E)
    Q <= Q + 1;
endmodule

module Pattern0_Gen(ones,CX);
input wire [2:0] ones;
output reg [7:0] CX;
always@*
begin
    case(ones)
        0: CX = 8'h81;
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        4: CX = 8'hCC;
        default: CX = 8'hfF;
    endcase
end
endmodule

module Pattern2_Gen(state,CX);
input wire [1:0] state;
output reg [7:0] CX;
always@*
begin
    case(state)
        1: CX = 8'hCF;
        2: CX = 8'h92;
        3: CX = 8'h86;
        default: CX = 8'hfF;
    endcase
end
endmodule